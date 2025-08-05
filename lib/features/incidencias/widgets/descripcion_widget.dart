import 'package:flutter/material.dart';
import '../../../utils/responsive_helper.dart';

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Descripción',
          style: TextStyle(
            fontSize: ResponsiveHelper.getFontSize(context, 18),
            fontWeight: FontWeight.w500,
            color: const Color(0xFF4C4547),
          ),
        ),
        SizedBox(height: ResponsiveHelper.getSpacing(context, base: 12)),
        Container(
          height: ResponsiveHelper.responsiveValue(
            context,
            mobile: 120.0,
            tablet: 140.0,
            desktop: 160.0,
          ),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(
              ResponsiveHelper.getBorderRadius(context, base: 12),
            ),
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
              fontSize: ResponsiveHelper.getFontSize(context, 14),
              color: const Color(0xFF4C4547),
              height: ResponsiveHelper.responsiveValue(
                context,
                mobile: 1.3,
                tablet: 1.4,
                desktop: 1.5,
              ),
            ),
            decoration: InputDecoration(
              hintText: hintText ??
                  ResponsiveHelper.responsiveValue(
                    context,
                    mobile: 'Describe la situación...',
                    tablet: 'Describe detalladamente la situación...',
                    desktop: 'Describe detalladamente la situación reportada...',
                  ),
              hintStyle: TextStyle(
                color: const Color(0xFFAFB5B3),
                fontSize: ResponsiveHelper.getFontSize(context, 14),
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