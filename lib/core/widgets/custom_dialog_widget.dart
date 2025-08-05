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
        borderRadius: BorderRadius.circular(12),
      ),
      backgroundColor: const Color.fromRGBO(255, 255, 255, 1), // Blanco
      elevation: 4,
      contentPadding: const EdgeInsets.all(0),
      content: Container(
        constraints: const BoxConstraints(maxWidth: 340),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: const Color.fromRGBO(255, 255, 255, 1), // Blanco
          border: Border.all(
            color: const Color.fromRGBO(175, 181, 179, 0.3), // Gris claro con opacidad
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header minimalista
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _getDialogColor(),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      _getDialogIcon(),
                      size: 20,
                      color: _getDialogColor(),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: const Color.fromRGBO(76, 69, 71, 1), // Gris oscuro
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Contenido
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: customContent ?? 
                (message != null 
                  ? Text(
                      message!,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Color.fromRGBO(76, 69, 71, 0.8), // Gris oscuro con opacidad
                        height: 1.5,
                      ),
                      textAlign: TextAlign.left,
                    )
                  : const SizedBox.shrink()),
            ),
            
            // Botones (si no es loading)
            if (type != DialogType.loading)
              Container(
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: const Color.fromRGBO(175, 181, 179, 0.2),
                      width: 1,
                    ),
                  ),
                ),
                padding: const EdgeInsets.all(16),
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
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: onSecondaryPressed ?? () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: const Color.fromRGBO(175, 181, 179, 1), // Gris
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            child: Text(
              secondaryButtonText!,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: onPrimaryPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: _getDialogColor(),
              foregroundColor: const Color.fromRGBO(255, 255, 255, 1), // Blanco
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: Text(
              primaryButtonText ?? 'OK',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        ],
      );
    } else {
      // Un solo botón
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          ElevatedButton(
            onPressed: onPrimaryPressed ?? () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: _getDialogColor(),
              foregroundColor: const Color.fromRGBO(255, 255, 255, 1), // Blanco
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: Text(
              primaryButtonText ?? 'OK',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        ],
      );
    }
  }

  Color _getDialogColor() {
    if (customColor != null) return customColor!;
    
    switch (type) {
      case DialogType.confirmation:
        return const Color.fromRGBO(9, 154, 215, 1); // Azul
      case DialogType.loading:
        return const Color.fromRGBO(9, 154, 215, 1); // Azul
      case DialogType.success:
        return const Color.fromRGBO(86, 160, 73, 1); // Verde
      case DialogType.error:
        return const Color.fromRGBO(205, 32, 54, 1); // Rojo
      case DialogType.warning:
        return const Color.fromRGBO(188, 150, 111, 1); // Marrón/Naranja
      case DialogType.info:
        return const Color.fromRGBO(9, 154, 215, 1); // Azul
    }
  }

  IconData _getDialogIcon() {
    if (customIcon != null) return customIcon!;
    
    switch (type) {
      case DialogType.confirmation:
        return Icons.help_outline_rounded;
      case DialogType.loading:
        return Icons.access_time_rounded;
      case DialogType.success:
        return Icons.check_circle_outline_rounded;
      case DialogType.error:
        return Icons.error_outline_rounded;
      case DialogType.warning:
        return Icons.warning_amber_rounded;
      case DialogType.info:
        return Icons.info_outline_rounded;
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
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                color: const Color.fromRGBO(9, 154, 215, 1), // Azul
                strokeWidth: 2.5,
              ),
            ),
            if (message != null) ...[
              const SizedBox(height: 16),
              Text(
                message,
                style: const TextStyle(
                  fontSize: 15,
                  color: Color.fromRGBO(76, 69, 71, 0.8),
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