// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'dart:io';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:image_picker/image_picker.dart';
import '../../../service/alert_service.dart';
import '../../../utils/responsive_helper.dart';
import '../../../service/user_storage_service.dart';

class IncidenciaFormScreen extends StatefulWidget {
  final String tipo;

  const IncidenciaFormScreen({super.key, required this.tipo});

  @override
  State<IncidenciaFormScreen> createState() => _IncidenciaFormScreenState();
}

class _IncidenciaFormScreenState extends State<IncidenciaFormScreen> {
  final TextEditingController descripcionController = TextEditingController();
  double gravedad = 0;
  File? _imagenSeleccionada;
  bool _isLoading = false;
  String? _userId;
  String? _email;
  String? _phone;

  @override
  void initState() {
    super.initState();
    _initUserData();
  }

  Future<void> _initUserData() async {
    try {
      final user = await UserStorageService.getUser();
      if (user != null) {
        setState(() {
          _userId = user.id;
          _email = user.correo;
          _phone = user.telefono;
        });
        print('Datos de usuario cargados: $_userId, $_email');
      } else {
        print('No se encontró usuario guardado');
      }
    } catch (e) {
      print('Error al cargar datos del usuario: $e');
    }
  }

  Future<void> _seleccionarImagen() async {
    final picker = ImagePicker();
    final imagen = await picker.pickImage(source: ImageSource.camera);

    if (imagen != null) {
      setState(() {
        _imagenSeleccionada = File(imagen.path);
      });
    }
  }

  Future<Position?> _getCurrentLocation() async {
    try {
      // Verificar si el servicio de ubicación está habilitado
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Mostrar diálogo para habilitar ubicación
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Por favor, habilita el servicio de ubicación en la configuración'),
              duration: Duration(seconds: 3),
            ),
          );
        }
        return null;
      }

      // Verificar permisos
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Permisos de ubicación denegados')),
            );
          }
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Permisos de ubicación denegados permanentemente. Ve a configuración para habilitarlos.'),
              duration: Duration(seconds: 4),
            ),
          );
        }
        return null;
      }

      // Obtener posición con configuración específica
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
    } catch (e) {
      print('Error obteniendo ubicación: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error obteniendo ubicación: ${e.toString()}')),
        );
      }
      return null;
    }
  }

  String? _getImageFileName() {
    if (_imagenSeleccionada == null) return null;
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'alerta_${widget.tipo}_$timestamp.jpg';
  }

  Future<void> _enviarAlerta() async {
    if (_isLoading) return;

    // Validar que los datos del usuario estén disponibles
    if (_userId == null || _email == null || _phone == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Datos de usuario no disponibles')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Obtener ubicación actual
      final position = await _getCurrentLocation();
      if (position == null) {
        throw Exception('No se pudo obtener la ubicación');
      }

      // Mapear el tipo de incidencia a categoryId (necesitas definir este mapeo)
      final categoryId = _mapTipoToCategoryId(widget.tipo);

      // Llamar al servicio
      final response = await AlertService.registerAlert(
        context: context,
        categoryId: categoryId, // usar el categoryId mapeado, no hardcodeado
        description: descripcionController.text,
        latitude: position.latitude,
        longitude: position.longitude,
        userId: _userId!,
        citizenId: _userId!, // usar _userId como citizenId ya que son lo mismo
        email: _email!,
        phone: _phone!,
        imageFile: _imagenSeleccionada,
        fileName: _getImageFileName(),
      );

      print(response);

      if (response.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.data ?? 'Alerta enviada exitosamente'),
            backgroundColor: const Color(0xFF4CAF50),
          ),
        );
        Navigator.pop(context);
      } else {
        throw Exception(response.error);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  int _mapTipoToCategoryId(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'alumbrado público':
        return 1;
      case 'limpieza pública':
        return 2;
      case 'seguridad ciudadana':
        return 3;
      // Agrega más casos según tus categorías
      default:
        return 1; // Categoría por defecto
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: Size.fromHeight(
        ResponsiveHelper.getSliverAppBarHeight(context),
      ),
      child: AppBar(
        backgroundColor: const Color(0xFF1976D2),
        elevation: ResponsiveHelper.getElevation(context, base: 0),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
            size: ResponsiveHelper.getIconSize(context, base: 20),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        flexibleSpace: SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              left: ResponsiveHelper.getIconSize(context, base: 60),
              right: ResponsiveHelper.getHorizontalPadding(context),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Image.asset(
                  'assets/imgs/muni_logo.png',
                  height: ResponsiveHelper.getIconSize(context, base: 50),
                ),
                Image.asset(
                  'assets/imgs/logo.png',
                  height: ResponsiveHelper.getIconSize(context, base: 40),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildHeader(),
          _buildFormSection(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      color: const Color(0xFF1976D2),
      child: Column(
        children: [
          SizedBox(height: ResponsiveHelper.getSpacing(context, base: 20)),
          Text(
            widget.tipo,
            style: TextStyle(
              fontSize: ResponsiveHelper.getTitleFontSize(context, base: 26),
              fontWeight: FontWeight.w300,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: ResponsiveHelper.getSpacing(context, base: 30)),
          Container(
            height: ResponsiveHelper.getSpacing(context, base: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(
                  ResponsiveHelper.getBorderRadius(context, base: 30),
                ),
                topRight: Radius.circular(
                  ResponsiveHelper.getBorderRadius(context, base: 30),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormSection() {
    return Container(
      color: Colors.white,
      width: double.infinity,
      child: ResponsiveHelper.centeredContent(
        context,
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: ResponsiveHelper.getFormFieldSpacing(context)),

            // Layout adaptativo basado en el tipo de dispositivo
            if (ResponsiveHelper.shouldStackHorizontally(context) &&
                ResponsiveHelper.getScreenWidth(context) > 800)
              _buildDesktopLayout()
            else
              _buildMobileLayout(),

            SizedBox(height: ResponsiveHelper.getFormSpacing(context)),
            _buildSubmitButton(),
            SizedBox(height: ResponsiveHelper.getFormSpacing(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: ResponsiveHelper.adaptiveColumns(
        context,
        [
          _buildImageSection(),
          _buildDescriptionSection(),
          _buildPrioritySection(),
        ],
        spacing: 32,
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Columna izquierda: Imagen y Prioridad
        Expanded(
          flex: 1,
          child: Column(
            children: [
              _buildImageSection(),
              SizedBox(height: ResponsiveHelper.getFormSpacing(context)),
              _buildPrioritySection(),
            ],
          ),
        ),
        SizedBox(width: ResponsiveHelper.getFormSpacing(context)),
        // Columna derecha: Descripción
        Expanded(
          flex: 1,
          child: _buildDescriptionSection(),
        ),
      ],
    );
  }

  Widget _buildImageSection() {
    final imageHeight = ResponsiveHelper.responsiveValue(
      context,
      mobile: 180.0,
      smallTablet: 200.0,
      largeTablet: 220.0,
      desktop: 250.0,
      largeDesktop: 280.0,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Evidencia',
          style: TextStyle(
            fontSize: ResponsiveHelper.getTitleFontSize(context, base: 18),
            fontWeight: FontWeight.w500,
            color: const Color(0xFF333333),
          ),
        ),
        SizedBox(height: ResponsiveHelper.getFormFieldSpacing(context)),
        GestureDetector(
          onTap: _seleccionarImagen,
          child: AnimatedContainer(
            duration: ResponsiveHelper.getAnimationDuration(),
            curve: ResponsiveHelper.getAnimationCurve(),
            height: imageHeight,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              border: Border.all(
                color: _imagenSeleccionada != null
                    ? const Color(0xFF1976D2)
                    : Colors.grey.shade300,
                width: _imagenSeleccionada != null ? 2.0 : 1.5,
              ),
              borderRadius: ResponsiveHelper.getImageBorderRadius(context),
              boxShadow: _imagenSeleccionada != null
                  ? [
                      BoxShadow(
                        color: const Color(0xFF1976D2),
                        blurRadius:
                            ResponsiveHelper.getElevation(context, base: 8),
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: _imagenSeleccionada == null
                ? _buildImagePlaceholder()
                : _buildImagePreview(),
          ),
        ),
      ],
    );
  }

  Widget _buildImagePlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.all(
            ResponsiveHelper.getSpacing(context, base: 16),
          ),
          decoration: BoxDecoration(
            color: const Color(0xFF1976D2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.camera_alt_outlined,
            size: ResponsiveHelper.getIconSize(context, base: 32),
            color: const Color(0xFF1976D2),
          ),
        ),
        SizedBox(height: ResponsiveHelper.getFormFieldSpacing(context)),
        Text(
          "Tomar fotografía",
          style: TextStyle(
            fontSize: ResponsiveHelper.getBodyFontSize(context),
            color: const Color(0xFF666666),
            fontWeight: FontWeight.w400,
          ),
          textAlign: TextAlign.center,
        ),
        if (ResponsiveHelper.isTablet(context) ||
            ResponsiveHelper.isDesktop(context))
          Padding(
            padding: EdgeInsets.only(
              top: ResponsiveHelper.getSpacing(context, base: 8),
            ),
            child: Text(
              "Haz clic para abrir la cámara",
              style: TextStyle(
                fontSize: ResponsiveHelper.getBodyFontSize(context, base: 12),
                color: const Color(0xFF999999),
              ),
              textAlign: TextAlign.center,
            ),
          ),
      ],
    );
  }

  Widget _buildImagePreview() {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: ResponsiveHelper.getImageBorderRadius(context),
          child: Image.file(
            _imagenSeleccionada!,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
        ),
        Positioned(
          top: ResponsiveHelper.getSpacing(context, base: 12),
          right: ResponsiveHelper.getSpacing(context, base: 12),
          child: Container(
            padding: EdgeInsets.all(
              ResponsiveHelper.getSpacing(context, base: 8),
            ),
            decoration: BoxDecoration(
              color: Colors.black54,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: ResponsiveHelper.getElevation(context, base: 4),
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              Icons.edit,
              color: Colors.white,
              size: ResponsiveHelper.getIconSize(context, base: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionSection() {
    final textFieldHeight = ResponsiveHelper.responsiveValue(
      context,
      mobile: 120.0,
      smallTablet: 140.0,
      largeTablet: 160.0,
      desktop: 180.0,
      largeDesktop: 200.0,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Descripción',
          style: TextStyle(
            fontSize: ResponsiveHelper.getTitleFontSize(context, base: 18),
            fontWeight: FontWeight.w500,
            color: const Color(0xFF333333),
          ),
        ),
        SizedBox(height: ResponsiveHelper.getFormFieldSpacing(context)),
        Container(
          height: textFieldHeight,
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: ResponsiveHelper.getImageBorderRadius(context),
            border: Border.all(
              color: Colors.grey.shade300,
              width: 1.5,
            ),
          ),
          child: TextField(
            controller: descripcionController,
            maxLines: null,
            expands: true,
            textAlignVertical: TextAlignVertical.top,
            style: TextStyle(
              fontSize: ResponsiveHelper.getBodyFontSize(context),
              color: const Color(0xFF333333),
              height: 1.4,
            ),
            decoration: InputDecoration(
              hintText: ResponsiveHelper.responsiveValue(
                context,
                mobile: 'Describe la situación...',
                desktop: 'Describe detalladamente la situación reportada...',
              ),
              hintStyle: TextStyle(
                color: const Color(0xFF999999),
                fontSize: ResponsiveHelper.getBodyFontSize(context),
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(
                ResponsiveHelper.getSpacing(context, base: 16),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPrioritySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Nivel de prioridad',
          style: TextStyle(
            fontSize: ResponsiveHelper.getTitleFontSize(context, base: 18),
            fontWeight: FontWeight.w500,
            color: const Color(0xFF333333),
          ),
        ),
        SizedBox(height: ResponsiveHelper.getFormFieldSpacing(context)),
        Container(
          padding: EdgeInsets.symmetric(
            vertical: ResponsiveHelper.getSpacing(context, base: 20),
            horizontal: ResponsiveHelper.getSpacing(context, base: 16),
          ),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: ResponsiveHelper.getImageBorderRadius(context),
            border: Border.all(
              color: gravedad > 0
                  ? const Color(0xFFFFA726)
                  : Colors.grey.shade300,
              width: gravedad > 0 ? 2.0 : 1.5,
            ),
          ),
          child: ResponsiveHelper.shouldStackVertically(context)
              ? Column(
                  children: [
                    Text(
                      'Seleccionar prioridad:',
                      style: TextStyle(
                        fontSize: ResponsiveHelper.getBodyFontSize(context),
                        color: const Color(0xFF666666),
                      ),
                    ),
                    SizedBox(
                        height: ResponsiveHelper.getFormFieldSpacing(context)),
                    _buildRatingBar(),
                    if (gravedad > 0) ...[
                      SizedBox(
                          height:
                              ResponsiveHelper.getSpacing(context, base: 12)),
                      _buildPriorityLabel(),
                    ],
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Seleccionar prioridad:',
                            style: TextStyle(
                              fontSize:
                                  ResponsiveHelper.getBodyFontSize(context),
                              color: const Color(0xFF666666),
                            ),
                          ),
                          if (gravedad > 0) ...[
                            SizedBox(
                                height: ResponsiveHelper.getSpacing(context,
                                    base: 4)),
                            _buildPriorityLabel(),
                          ],
                        ],
                      ),
                    ),
                    SizedBox(
                        width: ResponsiveHelper.getSpacing(context, base: 16)),
                    _buildRatingBar(),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildPriorityLabel() {
    final labels = ['', 'Muy Baja', 'Baja', 'Media', 'Alta', 'Crítica'];
    final colors = [
      Colors.grey,
      Colors.green,
      Colors.lightGreen,
      Colors.orange,
      Colors.deepOrange,
      Colors.red,
    ];

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveHelper.getSpacing(context, base: 8),
        vertical: ResponsiveHelper.getSpacing(context, base: 4),
      ),
      decoration: BoxDecoration(
        color: colors[gravedad.toInt()],
        borderRadius: BorderRadius.circular(
          ResponsiveHelper.getBorderRadius(context, base: 12),
        ),
        border: Border.all(
          color: colors[gravedad.toInt()],
          width: 1,
        ),
      ),
      child: Text(
        labels[gravedad.toInt()],
        style: TextStyle(
          fontSize: ResponsiveHelper.getBodyFontSize(context, base: 12),
          color: colors[gravedad.toInt()],
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildRatingBar() {
    return RatingBar.builder(
      initialRating: gravedad,
      minRating: 0,
      direction: Axis.horizontal,
      allowHalfRating: false,
      itemCount: 5,
      itemSize: ResponsiveHelper.getIconSize(context, base: 28),
      itemPadding: EdgeInsets.symmetric(
        horizontal: ResponsiveHelper.getSpacing(context, base: 2),
      ),
      itemBuilder: (context, index) => Icon(
        Icons.star_rounded,
        color:
            index < gravedad ? const Color(0xFFFFA726) : Colors.grey.shade300,
      ),
      onRatingUpdate: (rating) {
        setState(() {
          gravedad = rating;
        });
      },
      glow: false,
      unratedColor: Colors.grey.shade300,
    );
  }

  Widget _buildSubmitButton() {
    final isFormValid =
        descripcionController.text.isNotEmpty && gravedad > 0 && !_isLoading;

    return AnimatedContainer(
      duration: ResponsiveHelper.getAnimationDuration(),
      width: double.infinity,
      height: ResponsiveHelper.getButtonHeight(context),
      child: ElevatedButton(
        onPressed: isFormValid ? _enviarAlerta : null,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isFormValid ? const Color(0xFF1976D2) : Colors.grey.shade400,
          foregroundColor: Colors.white,
          elevation:
              isFormValid ? ResponsiveHelper.getElevation(context, base: 4) : 0,
          shape: RoundedRectangleBorder(
            borderRadius: ResponsiveHelper.getImageBorderRadius(context),
          ),
          shadowColor: const Color(0xFF1976D2),
        ),
        child: _isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.send_rounded,
                    size: ResponsiveHelper.getIconSize(context, base: 18),
                  ),
                  SizedBox(
                      width: ResponsiveHelper.getSpacing(context, base: 8)),
                  Text(
                    ResponsiveHelper.responsiveValue(
                      context,
                      mobile: 'Enviar',
                      desktop: 'Enviar Reporte',
                    ),
                    style: TextStyle(
                      fontSize:
                          ResponsiveHelper.getButtonFontSize(context, base: 16),
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  @override
  void dispose() {
    descripcionController.dispose();
    super.dispose();
  }
}
