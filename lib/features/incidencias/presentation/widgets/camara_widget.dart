import 'package:boton_panico_app/service/optimizar_imagen_service.dart';
import 'package:boton_panico_app/utils/responsive_helper.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class CamaraWidget extends StatefulWidget {
  final File? imagenSeleccionada;
  final Function(File?) onImageSelected;
  final bool isAutoMode; // Nueva propiedad para identificar modo automático

  const CamaraWidget({
    super.key,
    required this.imagenSeleccionada,
    required this.onImageSelected,
    this.isAutoMode = false, // Por defecto false
  });

  @override
  State<CamaraWidget> createState() => _CamaraWidgetState();
}

class _CamaraWidgetState extends State<CamaraWidget> {
  Future<void> _seleccionarImagen() async {
    final picker = ImagePicker();

    // Si está en modo automático, usar directamente la cámara
    if (widget.isAutoMode) {
      final imagen = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );
      if (imagen != null) {
        // Optimizar la imagen antes de asignarla
        final imageFile = File(imagen.path);
        final optimizedImage =
            await ImageOptimizationService.optimizeImage(imageFile);
        widget.onImageSelected(optimizedImage);
      }
      return;
    }

    // Comportamiento normal: mostrar diálogo para elegir entre cámara o galería
    final opcion = await showDialog<ImageSource>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Seleccionar imagen'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Cámara'),
                onTap: () => Navigator.of(context).pop(ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galería'),
                onTap: () => Navigator.of(context).pop(ImageSource.gallery),
              ),
            ],
          ),
        );
      },
    );

    if (opcion != null) {
      final imagen = await picker.pickImage(source: opcion);
      if (imagen != null) {
        widget.onImageSelected(File(imagen.path));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
        Row(
          children: [
            Text(
              'Evidencia',
              style: TextStyle(
                fontSize: ResponsiveHelper.getTitleFontSize(context, base: 18),
                fontWeight: FontWeight.w500,
                color: const Color(0xFF333333),
              ),
            ),
            // Mostrar indicador de modo automático si aplica
            if (widget.isAutoMode && widget.imagenSeleccionada != null) ...[
              SizedBox(width: 8),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'AUTO',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
        SizedBox(height: ResponsiveHelper.getFormFieldSpacing(context)),
        GestureDetector(
          onTap: widget.isAutoMode
              ? null
              : _seleccionarImagen, // Deshabilitar tap en modo auto
          child: AnimatedContainer(
            duration: ResponsiveHelper.getAnimationDuration(),
            curve: ResponsiveHelper.getAnimationCurve(),
            height: imageHeight,
            width: double.infinity,
            decoration: BoxDecoration(
              color: widget.isAutoMode
                  ? Colors.grey.shade100
                  : Colors.grey.shade50,
              border: Border.all(
                color: widget.imagenSeleccionada != null
                    ? const Color(0xFF099AD7)
                    : (widget.isAutoMode
                        ? const Color(0xFFAFB5B3)
                        : const Color(0xFFAFB5B3)),
                width: widget.imagenSeleccionada != null ? 2.0 : 1.5,
              ),
              borderRadius: ResponsiveHelper.getImageBorderRadius(context),
              boxShadow: widget.imagenSeleccionada != null
                  ? [
                      BoxShadow(
                        color: Color(0xFF099AD7),
                        blurRadius:
                            ResponsiveHelper.getElevation(context, base: 8),
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: widget.imagenSeleccionada == null
                ? _buildImagePlaceholder()
                : _buildImagePreview(),
          ),
        ),
      ],
    );
  }

  Widget _buildImagePlaceholder() {
    if (widget.isAutoMode) {
      // Placeholder especial para modo automático
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(
              ResponsiveHelper.getSpacing(context, base: 16),
            ),
            decoration: BoxDecoration(
              color: Color(0xFFAFB5B3),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.camera_alt,
              size: ResponsiveHelper.getIconSize(context, base: 32),
              color: Color(0xFF4C4547),
            ),
          ),
          SizedBox(height: ResponsiveHelper.getFormFieldSpacing(context)),
          Text(
            "Foto capturada automáticamente",
            style: TextStyle(
              fontSize: ResponsiveHelper.getBodyFontSize(context),
              color: const Color(0xFF666666),
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            "Modo emergencia activado",
            style: TextStyle(
              fontSize: ResponsiveHelper.getBodyFontSize(context, base: 12),
              color: const Color(0xFF999999),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      );
    }

    // Placeholder normal
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.all(
            ResponsiveHelper.getSpacing(context, base: 16),
          ),
          decoration: BoxDecoration(
            color: const Color(0xFF099AD7),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.add_photo_alternate_outlined,
            size: ResponsiveHelper.getIconSize(context, base: 32),
            color: Colors.white,
          ),
        ),
        SizedBox(height: ResponsiveHelper.getFormFieldSpacing(context)),
        Text(
          "Seleccionar imagen",
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
              "Haz clic para elegir una opción",
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
            widget.imagenSeleccionada!,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
        ),
        // Solo mostrar botón de editar si NO está en modo automático
        if (!widget.isAutoMode)
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
        // Mostrar indicador de modo automático en la esquina superior izquierda
        if (widget.isAutoMode)
          Positioned(
            top: ResponsiveHelper.getSpacing(context, base: 12),
            left: ResponsiveHelper.getSpacing(context, base: 12),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF56A049),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: ResponsiveHelper.getElevation(context, base: 4),
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                'EMERGENCIA',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
