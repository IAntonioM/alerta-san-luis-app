import 'package:boton_panico_app/utils/responsive_helper.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class CamaraWidget extends StatefulWidget {
  final File? imagenSeleccionada;
  final Function(File?) onImageSelected;

  const CamaraWidget({
    super.key,
    required this.imagenSeleccionada,
    required this.onImageSelected,
  });

  @override
  State<CamaraWidget> createState() => _CamaraWidgetState();
}

class _CamaraWidgetState extends State<CamaraWidget> {
  Future<void> _seleccionarImagen() async {
    final picker = ImagePicker();
    final imagen = await picker.pickImage(source: ImageSource.camera);

    if (imagen != null) {
      widget.onImageSelected(File(imagen.path));
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
                color: widget.imagenSeleccionada != null
                    ? const Color(0xFF1976D2)
                    : Colors.grey.shade300,
                width: widget.imagenSeleccionada != null ? 2.0 : 1.5,
              ),
              borderRadius: ResponsiveHelper.getImageBorderRadius(context),
              boxShadow: widget.imagenSeleccionada != null
                  ? [
                      BoxShadow(
                        color: const Color(0xFF1976D2).withOpacity(0.3),
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
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.all(
            ResponsiveHelper.getSpacing(context, base: 16),
          ),
          decoration: BoxDecoration(
            color: const Color(0xFF1976D2).withOpacity(0.1),
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
            widget.imagenSeleccionada!,
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
}