import 'package:flutter/material.dart';

enum DialogType {
  confirmation,
  loading,
  success,
  error,
  warning,
  info,
}

class CustomDialog extends StatelessWidget {
  final DialogType type;
  final String title;
  final String? message;
  final Widget? customContent;
  final String? primaryButtonText;
  final String? secondaryButtonText;
  final VoidCallback? onPrimaryPressed;
  final VoidCallback? onSecondaryPressed;
  final bool barrierDismissible;
  final IconData? customIcon;
  final Color? customColor;

  const CustomDialog({
    super.key,
    required this.type,
    required this.title,
    this.message,
    this.customContent,
    this.primaryButtonText,
    this.secondaryButtonText,
    this.onPrimaryPressed,
    this.onSecondaryPressed,
    this.barrierDismissible = true,
    this.customIcon,
    this.customColor,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      backgroundColor: Colors.white,
      elevation: 8,
      contentPadding: const EdgeInsets.all(0),
      content: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              _getDialogColor(),
              Colors.white,
            ],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header con color y icono
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
              decoration: BoxDecoration(
                color: _getDialogColor(),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    _getDialogIcon(),
                    size: 48,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            // Contenido
            Padding(
              padding: const EdgeInsets.all(24),
              child: customContent ?? 
                (message != null 
                  ? Text(
                      message!,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF333333),
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    )
                  : const SizedBox.shrink()),
            ),
            
            // Botones (si no es loading)
            if (type != DialogType.loading)
              Padding(
                padding: const EdgeInsets.only(left: 24, right: 24, bottom: 24),
                child: _buildButtons(context),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildButtons(BuildContext context) {
    if (secondaryButtonText != null) {
      // Dos botones
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: onSecondaryPressed ?? () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: _getDialogColor()),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text(
                secondaryButtonText!,
                style: TextStyle(
                  color: _getDialogColor(),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: onPrimaryPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: _getDialogColor(),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
                elevation: 2,
              ),
              child: Text(
                primaryButtonText ?? 'OK',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      );
    } else {
      // Un solo botón
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: onPrimaryPressed ?? () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: _getDialogColor(),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12),
            elevation: 2,
          ),
          child: Text(
            primaryButtonText ?? 'OK',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ),
      );
    }
  }

  Color _getDialogColor() {
    if (customColor != null) return customColor!;
    
    switch (type) {
      case DialogType.confirmation:
        return const Color(0xFF1976D2); // Azul principal
      case DialogType.loading:
        return const Color(0xFF1976D2); // Azul principal
      case DialogType.success:
        return const Color(0xFF4CAF50); // Verde
      case DialogType.error:
        return const Color(0xFFC22725); // Rojo
      case DialogType.warning:
        return const Color(0xFFFF9800); // Naranja
      case DialogType.info:
        return const Color(0xFF0C9BD7); // Azul claro
    }
  }

  IconData _getDialogIcon() {
    if (customIcon != null) return customIcon!;
    
    switch (type) {
      case DialogType.confirmation:
        return Icons.help_outline;
      case DialogType.loading:
        return Icons.hourglass_empty;
      case DialogType.success:
        return Icons.check_circle_outline;
      case DialogType.error:
        return Icons.error_outline;
      case DialogType.warning:
        return Icons.warning_outlined;
      case DialogType.info:
        return Icons.info_outline;
    }
  }

  // Métodos estáticos para facilitar el uso
  static Future<bool?> showConfirmation({
    required BuildContext context,
    required String title,
    required String message,
    String primaryButtonText = 'Confirmar',
    String secondaryButtonText = 'Cancelar',
    Color? color,
    IconData? icon,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => CustomDialog(
        type: DialogType.confirmation,
        title: title,
        message: message,
        primaryButtonText: primaryButtonText,
        secondaryButtonText: secondaryButtonText,
        customColor: color,
        customIcon: icon,
        onPrimaryPressed: () => Navigator.pop(context, true),
        onSecondaryPressed: () => Navigator.pop(context, false),
      ),
    );
  }

  static void showLoading({
    required BuildContext context,
    required String title,
    String? message,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => CustomDialog(
        type: DialogType.loading,
        title: title,
        customContent: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(
              color: Color(0xFF1976D2),
            ),
            if (message != null) ...[
              const SizedBox(height: 16),
              Text(
                message,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF333333),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
        barrierDismissible: false,
      ),
    );
  }

  static void showSuccess({
    required BuildContext context,
    required String title,
    required String message,
    String buttonText = 'OK',
    VoidCallback? onPressed,
  }) {
    showDialog(
      context: context,
      builder: (context) => CustomDialog(
        type: DialogType.success,
        title: title,
        message: message,
        primaryButtonText: buttonText,
        onPrimaryPressed: onPressed ?? () => Navigator.pop(context),
      ),
    );
  }

  static void showError({
    required BuildContext context,
    required String title,
    required String message,
    String buttonText = 'OK',
    VoidCallback? onPressed,
  }) {
    showDialog(
      context: context,
      builder: (context) => CustomDialog(
        type: DialogType.error,
        title: title,
        message: message,
        primaryButtonText: buttonText,
        onPrimaryPressed: onPressed ?? () => Navigator.pop(context),
      ),
    );
  }

  static void showWarning({
    required BuildContext context,
    required String title,
    required String message,
    String buttonText = 'OK',
    VoidCallback? onPressed,
  }) {
    showDialog(
      context: context,
      builder: (context) => CustomDialog(
        type: DialogType.warning,
        title: title,
        message: message,
        primaryButtonText: buttonText,
        onPrimaryPressed: onPressed ?? () => Navigator.pop(context),
      ),
    );
  }

  static void showInfo({
    required BuildContext context,
    required String title,
    required String message,
    String buttonText = 'OK',
    VoidCallback? onPressed,
  }) {
    showDialog(
      context: context,
      builder: (context) => CustomDialog(
        type: DialogType.info,
        title: title,
        message: message,
        primaryButtonText: buttonText,
        onPrimaryPressed: onPressed ?? () => Navigator.pop(context),
      ),
    );
  }
}