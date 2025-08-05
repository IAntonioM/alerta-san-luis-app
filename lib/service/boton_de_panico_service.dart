// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';
import 'package:boton_panico_app/service/auth_service.dart';
import 'package:flutter/material.dart';
import '../models/api_response_model.dart';
import 'api_service.dart';
import 'package:http/http.dart' as http;
import 'error_modal_service.dart';

class BotonDePanicoService {
  static Future<ApiResponse<String>> sendPanicAlert({
    required BuildContext context,
    required String categoryId, // ID de categoría para pánico
    required String description,
    required double latitude,
    required double longitude,
    required String userId,
    required String citizenId,
    required String email,
    required String phone,
    File? imageFile,
    String? fileName,
  }) async {
    try {
      Map<String, String> data = {
        'IN_ID_CAT_ALERTA': categoryId.toString(),
        'IN_ID_ESTADO': '1',
        'IN_DESC_ALERTA': description,
        'IN_LATITUD': latitude.toString(),
        'IN_LONGITUD': longitude.toString(),
        'IN_USUARIO_CREACION': userId,
        'IN_ESTADO_DET': '1',
        'IN_USUARIO_CREACION_DET': userId,
        'ID_CIUDADANO': citizenId,
        'IN_CORREO': email,
        'IN_CELULAR': phone,
      };

      // Si hay imagen, convertir a base64
      if (imageFile != null && fileName != null) {
        final bytes = await imageFile.readAsBytes();
        final base64Image = base64Encode(bytes);
        data['IN_NOM_IMAGEN'] = fileName;
        data['IN_IMAGEN_BYTES'] = base64Image;
      } else {
        data['IN_NOM_IMAGEN'] = '';
        data['IN_IMAGEN_BYTES'] = '';
      }

      // Usar la misma ruta que AlertService
      final streamedResponse = await ApiService.postMultipartFormData(
        '/api/alertas',
        data,
      );

      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['RESULTADO'] == 1) {
          // No mostrar modal de éxito aquí para botón de pánico
          // ya que se manejará en la pantalla principal
          return ApiResponse.success(responseData['MENSAJE']);
        } else {
          await ErrorModalService.showErrorModal(
            context,
            title: 'Error en el envío',
            message: responseData['MENSAJE'] ?? 'Error al enviar alerta de pánico',
          );
          return ApiResponse.error('Error al enviar alerta de pánico');
        }
      } else {
        await ErrorModalService.showApiErrorModal(
          context,
          response,
          title: 'Error del Servidor',
          defaultMessage: 'No se pudo conectar con el servidor',
        );
        return ApiResponse.error('Error en el servidor');
      }
    } catch (e) {
      await ErrorModalService.showErrorModal(
        context,
        title: 'Error de Conexión',
        message:
            'No se pudo establecer conexión con el servidor. Verifica tu conexión a internet.',
      );
      await AuthService.logout(context);
      return ApiResponse.error('Error de conexión: $e');
    }
  }
}