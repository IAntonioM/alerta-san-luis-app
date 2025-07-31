// lib/service/socket_service.dart
// ignore_for_file: library_prefixes, avoid_print

import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:boton_panico_app/service/api_service.dart';

class SocketService {
  static IO.Socket? _socket;

  static void connect(String ciudadanoId) {
    _socket = IO.io(ApiService.baseUrl, <String, dynamic>{
      'transports': ['websocket'],
      'query': {'ciudadanoId': ciudadanoId}
    });

    _socket?.connect();
    print('📱 Socket conectado para ciudadano: $ciudadanoId');
  }

  static void onAlertaAceptada(void Function(Map<String, dynamic>) callback) {
    _socket?.on('/alerta-aceptada', (data) {
      try {
        Map<String, dynamic> parsedData;
        if (data is Map<String, dynamic>) {
          parsedData = data;
        } else if (data is Map) {
          parsedData = Map<String, dynamic>.from(data);
        } else {
          parsedData = {'message': data.toString()};
        }
        callback(parsedData);
      } catch (e) {
        print('Error parsing alerta-aceptada data: $e');
        callback({'error': 'Error parsing data'});
      }
    });
  }

  static void onAlertaNoRespondida(void Function(Map<String, dynamic>) callback) {
    _socket?.on('/alerta-no-respondida', (data) {
      try {
        Map<String, dynamic> parsedData;
        if (data is Map<String, dynamic>) {
          parsedData = data;
        } else if (data is Map) {
          parsedData = Map<String, dynamic>.from(data);
        } else {
          parsedData = {'message': data.toString()};
        }
        callback(parsedData);
      } catch (e) {
        print('Error parsing alerta-no-respondida data: $e');
        callback({'error': 'Error parsing data'});
      }
    });
  }

  static void disconnect() {
    _socket?.disconnect();
    _socket = null;
  }

  static bool get isConnected => _socket?.connected ?? false;
}