// ignore_for_file: use_build_context_synchronously, avoid_print

import 'dart:convert';
import 'package:boton_panico_app/service/user_storage_service.dart';
import 'package:flutter/material.dart';
import '../models/api_response_model.dart';
import 'api_service.dart';
import 'package:http/http.dart' as http;

class BotonDePanicoService {
  // Datos de alerta de pánico predefinidos
  static Future<Map<String, dynamic>> _buildPanicAlertData() async {
    final userId = await UserStorageService.getUserId();
    final userEmail = await UserStorageService.getUserEmail();
    
    return {
      "IN_ID_CAT_ALERTA": "22", // ID para pánico (ajustar según tu BD)
      "IN_ID_ESTADO": "1",
      "IN_DESC_ALERTA": "ALERTA DE PÁNICO ACTIVADA - SOLICITA AYUDA INMEDIATA",
      "IN_LATITUD": "-12.0464", // Obtener ubicación real después
      "IN_LONGITUD": "-77.0428", // Obtener ubicación real después
      "IN_USUARIO_CREACION": userId ?? "unknown",
      "IN_NOM_IMAGEN": "panico_alerta.jpg",
      "IN_ESTADO_DET": "1",
      "IN_USUARIO_CREACION_DET": userId ?? "unknown",
      "ID_CIUDADANO": userId ?? "0",
      "IN_CORREO": userEmail ?? "",
      "IN_CELULAR": "12345678", // Obtener del usuario después
      "IN_IMAGEN_BYTES": "" // Sin imagen por defecto para pánico
    };
  }

  static Future<ApiResponse<Map<String, dynamic>>> sendPanicAlert({
    required BuildContext context,
  }) async {
    try {
      final alertData = await _buildPanicAlertData();
      final headers = await ApiService.headersWithToken;
      
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/api/alertas'),
        headers: headers,
        body: jsonEncode(alertData),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['RESULTADO'] == 1) {
        return ApiResponse.success(responseData);
      } else {
        return ApiResponse.error(
          responseData['mensaje'] ?? 'Error al enviar alerta de pánico'
        );
      }
    } catch (e) {
      print('Error en sendPanicAlert: $e');
      return ApiResponse.error('Error de conexión: $e');
    }
  }
}