// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import '../../../service/alert_service.dart';
import '../../../utils/responsive_helper.dart';
import '../../../service/user_storage_service.dart';

// Importar los widgets modulares
import 'widgets/camara_widget.dart';
import 'widgets/calificacion_widget.dart';
import 'widgets/descripcion_widget.dart';
import 'widgets/audio_widget.dart';

class IncidenciaFormScreen extends StatefulWidget {
  final String tipo;
  final String idCategoria;

  const IncidenciaFormScreen(
      {super.key, required this.tipo, required this.idCategoria});

  @override
  State<IncidenciaFormScreen> createState() => _IncidenciaFormScreenState();
}

class _IncidenciaFormScreenState extends State<IncidenciaFormScreen> {
  final TextEditingController descripcionController = TextEditingController();
  double gravedad = 0;
  File? _imagenSeleccionada;
  String? _audioPath;
  bool _isLoading = false;
  String? _userId;
  String? _email;
  String? _phone;
  bool _isAutoSending = false;

  @override
  void initState() {
    super.initState();
    _initUserData();
    
    // Si es categoría 1, activar modo automático
    if (widget.idCategoria == '1') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _activarModoAutomatico();
      });
    }
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

  Future<void> _activarModoAutomatico() async {
    setState(() {
      _isAutoSending = true;
    });

    try {
      // Mostrar diálogo de carga
      _showAutoSendingDialog();

      // Activar cámara automáticamente
      await _tomarFotoAutomatica();
      
      if (_imagenSeleccionada != null) {
        // Configurar valores por defecto
        descripcionController.text = "Alerta de emergencia - ${widget.tipo}";
        gravedad = 5.0; // Máxima gravedad por defecto para emergencias
        
        // Enviar automáticamente
        await _enviarAlerta();
      } else {
        // Si no se tomó foto, mostrar formulario normal
        setState(() {
          _isAutoSending = false;
        });
        if (Navigator.canPop(context)) {
          Navigator.pop(context); // Cerrar diálogo de carga
        }
        _showErrorMessage("No se pudo tomar la foto. Completa el formulario manualmente.");
      }
    } catch (e) {
      setState(() {
        _isAutoSending = false;
      });
      if (Navigator.canPop(context)) {
        Navigator.pop(context); // Cerrar diálogo de carga
      }
      _showErrorMessage("Error en envío automático: ${e.toString()}");
    }
  }

  void _showAutoSendingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                color: Color(0xFF1976D2),
              ),
              SizedBox(height: 16),
              Text(
                'Tomando foto y enviando alerta automáticamente...',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.orange,
        duration: Duration(seconds: 4),
      ),
    );
  }

  Future<void> _tomarFotoAutomatica() async {
    final picker = ImagePicker();
    
    try {
      // Intentar abrir la cámara directamente
      final imagen = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 1200,
        maxHeight: 1200,
      );
      
      if (imagen != null) {
        setState(() {
          _imagenSeleccionada = File(imagen.path);
        });
        print('Foto tomada automáticamente: ${imagen.path}');
      }
    } catch (e) {
      print('Error al tomar foto automática: $e');
      throw Exception('Error al acceder a la cámara');
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

  String? _getAudioFileName() {
    if (_audioPath == null) return null;
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'audio_${widget.tipo}_$timestamp.mp3';
  }

  // Función para convertir audio a base64 y crear un File temporal
  Future<File?> _createAudioFileForUpload() async {
    if (_audioPath == null) return null;
    
    try {
      final audioFile = File(_audioPath!);
      final audioBytes = await audioFile.readAsBytes();
      final audioBase64 = base64Encode(audioBytes);
      
      // Crear un archivo temporal con el contenido base64
      final tempDir = Directory.systemTemp;
      final tempFile = File('${tempDir.path}/temp_audio_${DateTime.now().millisecondsSinceEpoch}.mp3');
      
      // Escribir los bytes originales del audio al archivo temporal
      await tempFile.writeAsBytes(audioBytes);
      
      print('Audio convertido para envío - Tamaño: ${audioBase64.length} bytes');
      return tempFile;
    } catch (e) {
      print('Error al procesar audio: $e');
      return null;
    }
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

      // Mapear el tipo de incidencia a categoryId
      final categoryId = widget.idCategoria;

      File? fileToSend;
      String? fileName;

      // Si es categoría 8 (audio), preparar el archivo de audio
      if (widget.idCategoria == '8') {
        fileToSend = await _createAudioFileForUpload();
        fileName = _getAudioFileName();
        
        if (fileToSend == null) {
          throw Exception('Error al procesar el archivo de audio');
        }
      } else {
        // Para otras categorías, usar la imagen
        fileToSend = _imagenSeleccionada;
        fileName = _getImageFileName();
      }

      // Llamar al servicio usando los mismos parámetros imageFile y fileName
      final response = await AlertService.registerAlert(
        context: context,
        categoryId: categoryId,
        description: descripcionController.text,
        latitude: position.latitude,
        longitude: position.longitude,
        userId: _userId!,
        citizenId: _userId!,
        email: _email!,
        phone: _phone!,
        imageFile: fileToSend, // Aquí se envía imagen o audio según la categoría
        fileName: fileName,    // Nombre del archivo (imagen o audio)
      );

      print(response);

      if (response.success) {
        // Cerrar diálogo de carga si está abierto
        if (Navigator.canPop(context) && _isAutoSending) {
          Navigator.pop(context);
        }
        
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
      // Cerrar diálogo de carga si está abierto
      if (Navigator.canPop(context) && _isAutoSending) {
        Navigator.pop(context);
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
        _isAutoSending = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Si está en modo automático, mostrar una pantalla de carga simple
    if (_isAutoSending) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: Color(0xFF1976D2),
              ),
              SizedBox(height: 24),
              Text(
                'Preparando alerta de emergencia...',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF333333),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

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
        backgroundColor: const Color.fromARGB(255, 2, 14, 179),
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
                  height: ResponsiveHelper.getIconSize(context, base: 80),
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
      color: const Color.fromARGB(255, 2, 14, 179),
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
          // Widget de cámara - solo cuando idCategoria no es '8'
          if (widget.idCategoria != '8')
            CamaraWidget(
              imagenSeleccionada: _imagenSeleccionada,
              onImageSelected: (File? image) {
                setState(() {
                  _imagenSeleccionada = image;
                });
              },
            ),

          // Widget de audio - solo cuando idCategoria es '8'
          if (widget.idCategoria == '8')
            AudioWidget(
              audioPath: _audioPath,
              onAudioRecorded: (String? audioPath) {
                setState(() {
                  _audioPath = audioPath;
                });
              },
            ),

          // Widget de descripción
          DescripcionWidget(
            controller: descripcionController,
          ),

          // Widget de calificación
          CalificacionWidget(
            gravedad: gravedad,
            onRatingChanged: (double rating) {
              setState(() {
                gravedad = rating;
              });
            },
          ),
        ],
        spacing: 32,
      ),
    );
  }

  Widget _buildSubmitButton() {
    // Validación del formulario actualizada para considerar audio en categoría 8
    bool hasMediaFile = false;
    if (widget.idCategoria == '8') {
      hasMediaFile = _audioPath != null && _audioPath!.isNotEmpty;
    } else {
      hasMediaFile = _imagenSeleccionada != null;
    }

    final isFormValid = descripcionController.text.isNotEmpty && 
                       gravedad > 0 && 
                       hasMediaFile && 
                       !_isLoading;

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