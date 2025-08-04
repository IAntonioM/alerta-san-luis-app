import 'package:flutter/material.dart';
import '../../../../utils/responsive_helper.dart';

class DescripcionWidget extends StatelessWidget {
  final TextEditingController controller;
  final String? hintText;

  const DescripcionWidget({
    super.key,
    required this.controller,
    this.hintText,
  });

  @override
  Widget build(BuildContext context) {
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
            color: const Color(0xFF4C4547),
          ),
        ),
        SizedBox(height: ResponsiveHelper.getFormFieldSpacing(context)),
        Container(
          height: textFieldHeight,
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: ResponsiveHelper.getImageBorderRadius(context),
            border: Border.all(
              color: controller.text.isNotEmpty
                  ? const Color(0xFF099AD7)
                  : const Color(0xFFAFB5B3),
              width: controller.text.isNotEmpty ? 2.0 : 1.5,
            ),
          ),
          child: TextField(
            controller: controller,
            maxLines: null,
            expands: true,
            textAlignVertical: TextAlignVertical.top,
            style: TextStyle(
              fontSize: ResponsiveHelper.getBodyFontSize(context),
              color: const Color(0xFF4C4547),
              height: 1.4,
            ),
            decoration: InputDecoration(
              hintText: hintText ??
                  ResponsiveHelper.responsiveValue(
                    context,
                    mobile: 'Describe la situación...',
                    desktop:
                        'Describe detalladamente la situación reportada...',
                  ),
              hintStyle: TextStyle(
                color: const Color(0xFFAFB5B3),
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
}
