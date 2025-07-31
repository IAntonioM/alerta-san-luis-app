// lib/service/socket_service.dart
// ignore_for_file: library_prefixes, avoid_print

import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:boton_panico_app/service/api_service.dart';

class SocketService {
  static IO.Socket? _socket;
  static String? _currentCiudadanoId;

  static void connect(String ciudadanoId) {
    // Desconectar socket anterior si existe
    if (_socket != null) {
      _socket!.disconnect();
      _socket = null;
    }

    _currentCiudadanoId = ciudadanoId;
    
    _socket = IO.io(ApiService.baseUrl, <String, dynamic>{
      'transports': ['websocket', 'polling'], // Agregar polling como fallback
      'query': {'ciudadanoId': ciudadanoId},
      'timeout': 10000,
      'reconnection': true,
      'reconnectionAttempts': 3,
      'reconnectionDelay': 1000,
    });

    // Eventos de conexión
    _socket!.on('connect', (_) {
      print('✅ Socket conectado exitosamente');
      print('📱 Socket ID: ${_socket!.id}');
      print('👤 Ciudadano ID: $ciudadanoId');
    });

    _socket!.on('connect_error', (error) {
      print('❌ Error de conexión socket: $error');
    });

    _socket!.on('disconnect', (reason) {
      print('🔌 Socket desconectado: $reason');
    });

    _socket!.connect();
  }

  static void onAlertaAceptada(void Function(Map<String, dynamic>) callback) {
    _socket?.on('alerta-aceptada', (data) {
      print('📨 Evento alerta-aceptada recibido: $data');
      
      try {
        Map<String, dynamic> parsedData;
        if (data is Map<String, dynamic>) {
          parsedData = data;
        } else if (data is Map) {
          parsedData = Map<String, dynamic>.from(data);
        } else {
          parsedData = {'message': data.toString()};
        }

        // Verificar que el evento es para este ciudadano
        if (parsedData['id'] != null && 
            parsedData['id'].toString() == _currentCiudadanoId) {
          print('✅ Alerta aceptada para este ciudadano');
          callback(parsedData);
        } else {
          print('⚠️ Alerta aceptada no es para este ciudadano');
        }
      } catch (e) {
        print('Error parsing alerta-aceptada data: $e');
        callback({'error': 'Error parsing data'});
      }
    });
  }

  static void onAlertaNoRespondida(void Function(Map<String, dynamic>) callback) {
    _socket?.on('alerta-no-respondida', (data) {
      print('📨 Evento alerta-no-respondida recibido: $data');
      
      try {
        Map<String, dynamic> parsedData;
        if (data is Map<String, dynamic>) {
          parsedData = data;
        } else if (data is Map) {
          parsedData = Map<String, dynamic>.from(data);
        } else {
          parsedData = {'message': data.toString()};
        }

        // Verificar que el evento es para este ciudadano
        if (parsedData['id'] != null && 
            parsedData['id'].toString() == _currentCiudadanoId) {
          print('⚠️ Alerta no respondida para este ciudadano');
          callback(parsedData);
        }
      } catch (e) {
        print('Error parsing alerta-no-respondida data: $e');
        callback({'error': 'Error parsing data'});
      }
    });
  }

  // Método para testear la conexión
  static void testConnection() {
    if (_socket?.connected == true && _currentCiudadanoId != null) {
      _socket!.emit('test-conexion', {
        'ciudadanoId': _currentCiudadanoId,
        'mensaje': 'Probando conexión desde Flutter',
        'timestamp': DateTime.now().toIso8601String()
      });
      print('🧪 Test de conexión enviado');
    } else {
      print('⚠️ Socket no conectado para test');
    }
  }

  static void disconnect() {
    print('🧹 Desconectando socket...');
    _socket?.disconnect();
    _socket = null;
    _currentCiudadanoId = null;
  }

  static bool get isConnected => _socket?.connected ?? false;
  static String? get socketId => _socket?.id;
}