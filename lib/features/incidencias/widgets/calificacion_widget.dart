import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../../../utils/responsive_helper.dart';

class CalificacionWidget extends StatelessWidget {
  final double gravedad;
  final Function(double) onRatingChanged;

  const CalificacionWidget({
    super.key,
    required this.gravedad,
    required this.onRatingChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Nivel de prioridad',
          style: TextStyle(
            fontSize: ResponsiveHelper.getFontSize(context, 18),
            fontWeight: FontWeight.w500,
            color: const Color(0xFF333333),
          ),
        ),
        SizedBox(height: ResponsiveHelper.getSpacing(context, base: 12)),
        Container(
          padding: EdgeInsets.symmetric(
            vertical: ResponsiveHelper.getSpacing(context, base: 20),
            horizontal: ResponsiveHelper.getSpacing(context, base: 16),
          ),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(
              ResponsiveHelper.getBorderRadius(context, base: 12),
            ),
            border: Border.all(
              color: gravedad > 0
                  ? const Color(0xFFFFA726)
                  : const Color(0xFFAFB5B3),
              width: gravedad > 0 ? 2.0 : 1.5,
            ),
          ),
          child: ResponsiveHelper.isMobile(context)
              ? Column(
            children: [
              Text(
                'Seleccionar prioridad:',
                style: TextStyle(
                  fontSize: ResponsiveHelper.getFontSize(context, 14),
                  color: const Color(0xFF666666),
                ),
              ),
              SizedBox(height: ResponsiveHelper.getSpacing(context, base: 12)),
              _buildRatingBar(context),
              if (gravedad > 0) ...[
                SizedBox(height: ResponsiveHelper.getSpacing(context, base: 12)),
                _buildPriorityLabel(context),
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
                        fontSize: ResponsiveHelper.getFontSize(context, 14),
                        color: const Color(0xFF666666),
                      ),
                    ),
                    if (gravedad > 0) ...[
                      SizedBox(height: ResponsiveHelper.getSpacing(context, base: 8)),
                      _buildPriorityLabel(context),
                    ],
                  ],
                ),
              ),
              SizedBox(width: ResponsiveHelper.getSpacing(context, base: 16)),
              _buildRatingBar(context),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPriorityLabel(BuildContext context) {
    final labels = ['', 'Muy Baja', 'Baja', 'Media', 'Alta', 'Crítica'];
    final colors = [
      const Color(0xFFAFB5B3),
      const Color(0xFF56A049),
      const Color(0xFF56A049),
      Colors.orange,
      Colors.deepOrange,
      const Color(0xFFCD2036),
    ];

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveHelper.getSpacing(context, base: 12),
        vertical: ResponsiveHelper.getSpacing(context, base: 6),
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
          fontSize: ResponsiveHelper.getFontSize(context, 16),
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildRatingBar(BuildContext context) {
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
        color: index < gravedad
            ? const Color(0xFFFFA726)
            : const Color(0xFFAFB5B3),
      ),
      onRatingUpdate: onRatingChanged,
      glow: false,
      unratedColor: const Color(0xFFAFB5B3),
    );
  }
}