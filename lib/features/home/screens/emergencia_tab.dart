import 'dart:async';
import 'package:boton_panico_app/utils/responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import 'package:boton_panico_app/service/boton_de_panico_service.dart';
import 'package:boton_panico_app/service/error_modal_service.dart';
import 'package:boton_panico_app/service/socket_service.dart';
import 'package:boton_panico_app/service/user_storage_service.dart';
import 'package:boton_panico_app/service/menu_service.dart';
import 'package:boton_panico_app/service/alert_service.dart';
import 'package:boton_panico_app/models/menu_model.dart';
import 'package:boton_panico_app/core/widgets/custom_dialog_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';

class EmergenciaTab extends StatefulWidget {
  const EmergenciaTab({super.key});

  @override
  State<EmergenciaTab> createState() => _EmergenciaTabState();
}

class _EmergenciaTabState extends State<EmergenciaTab> {
  // Estado
  List<MenuCategory> _emergenciaMenus = [];
  bool _isLoading = true;
  Timer? _countdownTimer;
  int _remainingSeconds = 20;

  // Constantes
  static const int _emergencyGroupId = 2;
  static const int _panicCategoryId = 22;
  static const int _countdownDuration = 20;
  static const Duration _socketConnectionDelay = Duration(milliseconds: 1500);

  // Colores
  static const Color _primaryColor = Color(0xFF1976D2);
  static const Color _panicButtonColor = Color(0xFFFFD700);
  static const Color _successColor = Color(0xFF4CAF50);
  static const Color _errorColor = Colors.red;
  static const Color _textColor = Color(0xFF333333);

  @override
  void initState() {
    super.initState();
    _loadEmergenciaMenus();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    SocketService.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: ResponsiveHelper.getScreenPadding(context),
      child: _isLoading ? _buildLoadingWidget() : _buildContent(),
    );
  }

  // Widgets principales
  Widget _buildLoadingWidget() {
    return const Center(
      child: CircularProgressIndicator(color: _primaryColor),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      child: ResponsiveHelper.centeredContent(
        context,
        Column(
          children: [
            SizedBox(height: ResponsiveHelper.getSpacing(context, base: 20)),
            _buildEmergencyGrid(),
            SizedBox(height: ResponsiveHelper.getSectionSpacing(context)),
            _buildPanicButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencyGrid() {
    // Determinar número de columnas según el dispositivo
    final columns = ResponsiveHelper.getGridColumns(
      context,
      mobile: 3,
      tablet: 3,
      desktop: 3,
    );

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: ResponsiveHelper.getSpacing(context, base: 12),
        mainAxisSpacing: ResponsiveHelper.getSpacing(context, base: 20),
        childAspectRatio: _getChildAspectRatio(context),
      ),
      itemCount: _emergenciaMenus.length,
      itemBuilder: (context, index) {
        final menu = _emergenciaMenus[index];
        return _buildEmergencyCard(
          iconUrl: MenuService.getIconUrl(menu.iconoCategoria),
          text: menu.nomCategoria,
          color: _getColorForCategory(menu.nomCategoria),
          onTap: () => _handleEmergencyAlert(menu),
        );
      },
    );
  }

  double _getChildAspectRatio(BuildContext context) {
    // Ajustar la proporción según el dispositivo
    if (ResponsiveHelper.isSmallMobile(context)) {
      return 0.65;
    } else if (ResponsiveHelper.isMobile(context)) {
      return 0.7;
    } else if (ResponsiveHelper.isTablet(context)) {
      return 0.75;
    } else {
      return 0.8;
    }
  }

  Widget _buildPanicButton() {
    final buttonHeight = ResponsiveHelper.getResponsiveSize(context, 250.0);
    final iconSize = ResponsiveHelper.getIconSize(context, base: 120);
    final titleFontSize = ResponsiveHelper.getTitleFontSize(context, base: 28);
    final subtitleFontSize = ResponsiveHelper.getBodyFontSize(context, base: 16);
    final borderRadius = ResponsiveHelper.getBorderRadius(context, base: 16);
    final elevation = ResponsiveHelper.getElevation(context, base: 8);

    return GestureDetector(
      onTap: _handlePanicButton,
      child: Container(
        width: double.infinity,
        height: buttonHeight,
        decoration: BoxDecoration(
          color: _panicButtonColor,
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: elevation,
              offset: Offset(0, elevation / 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.phone_in_talk,
              size: iconSize,
              color: _errorColor,
            ),
            SizedBox(height: ResponsiveHelper.getSpacing(context, base: 16)),
            Text(
              'BOTÓN DE PÁNICO',
              style: TextStyle(
                fontSize: titleFontSize,
                fontWeight: FontWeight.bold,
                color: _errorColor,
                letterSpacing: ResponsiveHelper.isMobile(context) ? 0.8 : 1.2,
              ),
            ),
            SizedBox(height: ResponsiveHelper.getSpacing(context, base: 8)),
            Text(
              'Presiona para emergencia',
              style: TextStyle(
                fontSize: subtitleFontSize,
                color: _textColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencyCard({
    required String iconUrl,
    required String text,
    required Color color,
    required VoidCallback onTap,
  }) {
    final cardHeight = ResponsiveHelper.getResponsiveSize(context, 110.0);
    final iconSize = ResponsiveHelper.getIconSize(context, base: 80);
    final fontSize = ResponsiveHelper.getBodyFontSize(context, base: 16);
    final borderRadius = ResponsiveHelper.getBorderRadius(context, base: 16);
    final elevation = ResponsiveHelper.getElevation(context, base: 6);

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: cardHeight,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(borderRadius),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: elevation,
                  offset: Offset(0, elevation / 2),
                ),
              ],
            ),
            child: Center(
              child: CachedNetworkImage(
                imageUrl: iconUrl,
                height: iconSize,
                width: iconSize,
                fit: BoxFit.contain,
                placeholder: (context, url) => SizedBox(
                  width: ResponsiveHelper.getIconSize(context, base: 24),
                  height: ResponsiveHelper.getIconSize(context, base: 24),
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                errorWidget: (context, url, error) => Icon(
                  Icons.emergency,
                  size: ResponsiveHelper.getIconSize(context, base: 50),
                  color: Colors.white,
                ),
              ),
            ),
          ),
          SizedBox(height: ResponsiveHelper.getSpacing(context, base: 12)),
          Flexible(
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: _textColor,
              ),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // Lógica de carga de datos
  Future<void> _loadEmergenciaMenus() async {
    try {
      final response = await MenuService.getMenus(context: context);

      if (response.success && response.data != null) {
        setState(() {
          _emergenciaMenus = response.data!
              .where((menu) => menu.grupo == _emergencyGroupId)
              .toList();
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
        _showErrorSnackBar('Error al cargar menús de emergencia');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('Error: ${e.toString()}');
    }
  }

  // Manejo de alertas de emergencia
  Future<void> _handleEmergencyAlert(MenuCategory menu) async {
    final shouldSend = await _showConfirmationDialog(
      title: '⚠️ ${menu.nomCategoria}',
      message: '¿Confirmas que necesitas ${menu.nomCategoria.toLowerCase()}?',
      color: const Color(0xFFC22725),
    );

    if (shouldSend == true) {
      await _sendEmergencyAlert(menu);
    }
  }

  Future<void> _sendEmergencyAlert(MenuCategory menu) async {
    _showLoadingDialog(
        'Enviando Alerta', 'Procesando tu solicitud de emergencia...');

    try {
      final user = await _getUserData();
      final position = await _getCurrentLocation();

      if (user == null || position == null) return;

      final response = await AlertService.registerAlert(
        context: context,
        categoryId: menu.idCategoria.toString(),
        description: 'Alerta de emergencia: ${menu.nomCategoria}',
        latitude: position.latitude,
        longitude: position.longitude,
        userId: user.id,
        citizenId: user.id,
        email: user.correo,
        phone: user.telefono,
        imageFile: null,
        fileName: null,
      );

      _closeDialog();

      if (response.success) {
        _showSuccessSnackBar(
            'Alerta de ${menu.nomCategoria} enviada exitosamente');
      } else {
        throw Exception(response.error);
      }
    } catch (e) {
      _closeDialog();
      _showErrorSnackBar('Error: ${e.toString()}');
    }
  }

  // Manejo del botón de pánico
  Future<void> _handlePanicButton() async {
    final shouldSend = await _showConfirmationDialog(
      title: 'BOTÓN DE PÁNICO',
      message: '¿Confirmas que necesitas ayuda de emergencia?',
      color: _primaryColor,
    );

    if (shouldSend == true) {
      await _sendPanicAlert();
    }
  }

  Future<void> _sendPanicAlert() async {
    _showLoadingDialog('Enviando Alerta de Pánico',
        'Procesando tu solicitud de emergencia...');

    try {
      final user = await _getUserData();
      final position = await _getCurrentLocation();

      if (user == null || position == null) return;

      final response = await BotonDePanicoService.sendPanicAlert(
        context: context,
        categoryId: _panicCategoryId.toString(),
        description: "ALERTA DE PÁNICO ACTIVADA - SOLICITA AYUDA INMEDIATA",
        latitude: position.latitude,
        longitude: position.longitude,
        userId: user.id,
        citizenId: user.id,
        email: user.correo,
        phone: user.telefono,
        imageFile: null,
        fileName: null,
      );

      _closeDialog();

      if (response.success) {
        _showWaitingDialog();
        await _connectSocket();
      } else {
        _showErrorSnackBar(response.error ?? 'Error al enviar alerta');
      }
    } catch (e) {
      _closeDialog();
      _showErrorSnackBar('Error: ${e.toString()}');
    }
  }

  // Servicios auxiliares
  Future<dynamic> _getUserData() async {
    final user = await UserStorageService.getUser();
    if (user == null) {
      _showErrorSnackBar('Datos de usuario no disponibles');
    }
    return user;
  }

  Future<Position?> _getCurrentLocation() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        _showErrorSnackBar('Por favor, habilita el servicio de ubicación');
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showErrorSnackBar('Permisos de ubicación denegados');
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showErrorSnackBar('Permisos de ubicación denegados permanentemente');
        return null;
      }

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
    } catch (e) {
      _showErrorSnackBar('Error obteniendo ubicación: ${e.toString()}');
      return null;
    }
  }

  // Conexión con Socket
  Future<void> _connectSocket() async {
    final userId = await UserStorageService.getUserId();
    if (userId == null) {
      await ErrorModalService.showErrorModal(
        context,
        title: 'Error',
        message: '❌ No se pudo obtener el ID del usuario.',
      );
      return;
    }

    SocketService.connect(userId.toString());
    await Future.delayed(_socketConnectionDelay);
    SocketService.testConnection();

    SocketService.onAlertaAceptada((_) {
      _countdownTimer?.cancel();
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
        _showSuccessAlert();
      }
    });

    SocketService.onAlertaNoRespondida((_) {
      _countdownTimer?.cancel();
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
        _showNoResponseAlert();
      }
    });
  }

  // Diálogos y modales
  Future<bool?> _showConfirmationDialog({
    required String title,
    required String message,
    required Color color,
  }) {
    return CustomDialog.showConfirmation(
      context: context,
      title: title,
      message: message,
      primaryButtonText: 'ENVIAR ALERTA',
      secondaryButtonText: 'Cancelar',
      color: color,
      icon: Icons.warning,
    );
  }

  void _showLoadingDialog(String title, String message) {
    CustomDialog.showLoading(
      context: context,
      title: title,
      message: message,
    );
  }

  void _showWaitingDialog() {
    _remainingSeconds = _countdownDuration;
    StateSetter? dialogSetState;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          dialogSetState = setState;
          return CustomDialog(
            type: DialogType.loading,
            title: 'Esperando Respuesta',
            customContent: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(color: _primaryColor),
                SizedBox(height: ResponsiveHelper.getSpacing(context, base: 16)),
                Text(
                  'Estamos a la espera de una respuesta del personal de seguridad.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getBodyFontSize(context, base: 16),
                    color: _textColor,
                  ),
                ),
                SizedBox(height: ResponsiveHelper.getSpacing(context, base: 8)),
                Text(
                  'Tiempo restante: $_remainingSeconds segundos',
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getBodyFontSize(context, base: 14),
                    fontWeight: FontWeight.bold,
                    color: _primaryColor,
                  ),
                ),
              ],
            ),
            barrierDismissible: false,
          );
        },
      ),
    ).then((_) {
      _countdownTimer?.cancel();
    });

    Future.delayed(const Duration(milliseconds: 100), () {
      if (dialogSetState != null) {
        _startCountdownTimer(dialogSetState!);
      }
    });
  }

  void _startCountdownTimer(StateSetter dialogSetState) {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        if (mounted && Navigator.canPop(context)) {
          try {
            dialogSetState(() => _remainingSeconds--);
          } catch (e) {
            timer.cancel();
          }
        } else {
          timer.cancel();
        }
      } else {
        timer.cancel();
        if (mounted && Navigator.canPop(context)) {
          try {
            Navigator.pop(context);
            _showTimeoutAlert();
          } catch (e) {
            ErrorModalService.showErrorModal(
              context,
              title: 'Error de Conexión',
              message: 'Error cerrando diálogo: $e.',
            );
          }
        }
      }
    });
  }

  void _showSuccessAlert() {
    CustomDialog.showSuccess(
      context: context,
      title: 'Alerta Recibida',
      message: 'Tu alerta fue aceptada. Recibirás atención en breve.',
    );
  }

  void _showTimeoutAlert() {
    CustomDialog.showWarning(
      context: context,
      title: 'Tiempo Agotado',
      message: 'Ningún agente respondió a tiempo.',
    );
  }

  void _showNoResponseAlert() {
    CustomDialog.showWarning(
      context: context,
      title: 'Alerta No Respondida',
      message: 'Ningún agente respondió a tu alerta.',
    );
  }

  // Métodos auxiliares
  void _closeDialog() {
    if (Navigator.canPop(context)) Navigator.pop(context);
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: _successColor,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: _errorColor,
      ),
    );
  }

  Color _getColorForCategory(String categoryName) {
    final name = categoryName.toLowerCase();
    if (name.contains('bomberos')) return const Color(0xFFC22725);
    if (name.contains('serenazgo')) return const Color(0xFF0C9BD7);
    if (name.contains('ambulancia')) return const Color(0xFF76A054);
    return const Color(0xFF757575);
  }
}