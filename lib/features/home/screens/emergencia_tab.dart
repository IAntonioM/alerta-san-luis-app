import 'dart:async';
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
  static const int _itemsPerRow = 3;
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
      padding: const EdgeInsets.all(20),
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
      child: Column(
        children: [
          const SizedBox(height: 20),
          ..._buildEmergencyGrid(),
          const SizedBox(height: 30),
          _buildPanicButton(),
        ],
      ),
    );
  }

  Widget _buildPanicButton() {
    return GestureDetector(
      onTap: _handlePanicButton,
      child: Container(
        width: double.infinity,
        height: 250,
        decoration: BoxDecoration(
          color: _panicButtonColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.phone_in_talk,
              size: 120,
              color: _errorColor,
            ),
            SizedBox(height: 16),
            Text(
              'BOTÓN DE PÁNICO',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: _errorColor,
                letterSpacing: 1.2,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Presiona para emergencia',
              style: TextStyle(
                fontSize: 16,
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
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 110,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black,
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Center(
              child: CachedNetworkImage(
                imageUrl: iconUrl,
                height: 80,
                width: 80,
                fit: BoxFit.contain,
                placeholder: (context, url) => const CircularProgressIndicator(),
                errorWidget: (context, url, error) => const Icon(
                  Icons.emergency,
                  size: 50,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: _textColor,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
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

  // Construcción de la grilla de emergencias
  List<Widget> _buildEmergencyGrid() {
    final rows = <Widget>[];

    for (int i = 0; i < _emergenciaMenus.length; i += _itemsPerRow) {
      final rowItems = <Widget>[];

      for (int j = 0; j < _itemsPerRow; j++) {
        final index = i + j;
        
        if (index < _emergenciaMenus.length) {
          final menu = _emergenciaMenus[index];
          rowItems.add(
            Expanded(
              child: _buildEmergencyCard(
                iconUrl: MenuService.getIconUrl(menu.iconoCategoria),
                text: menu.nomCategoria,
                color: _getColorForCategory(menu.nomCategoria),
                onTap: () => _handleEmergencyAlert(menu),
              ),
            ),
          );
        } else {
          rowItems.add(Expanded(child: Container()));
        }

        if (j < _itemsPerRow - 1) {
          rowItems.add(const SizedBox(width: 12));
        }
      }

      rows.add(Row(children: rowItems));

      if (i + _itemsPerRow < _emergenciaMenus.length) {
        rows.add(const SizedBox(height: 20));
      }
    }

    return rows;
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
    _showLoadingDialog('Enviando Alerta', 'Procesando tu solicitud de emergencia...');

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
        _showSuccessSnackBar('Alerta de ${menu.nomCategoria} enviada exitosamente');
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
    _showLoadingDialog('Enviando Alerta de Pánico', 'Procesando tu solicitud de emergencia...');

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
    late StateSetter dialogSetState;

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
                const SizedBox(height: 16),
                const Text(
                  'Estamos a la espera de una respuesta del personal de seguridad.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: _textColor),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tiempo restante: $_remainingSeconds segundos',
                  style: const TextStyle(
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
    );

    _startCountdownTimer(dialogSetState);
  }

  void _startCountdownTimer(StateSetter dialogSetState) {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        dialogSetState(() => _remainingSeconds--);
      } else {
        timer.cancel();
        if (Navigator.canPop(context)) {
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