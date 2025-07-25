import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import '../models/alert_model.dart';
import '../models/api_response_model.dart';
import 'api_service.dart';

class AlertService {
  static Future<ApiResponse<String>> registerAlert({
    required int categoryId,
    required String description,
    required double latitude,
    required double longitude,
    required String userId,
    required int citizenId,
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
        'ID_CIUDADANO': citizenId.toString(),
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

      final response = await ApiService.postFormData(
        '/servicio.php?opcion=api/insertAlerta',
        data,
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['RESULTADO'] == 1) {
          return ApiResponse.success(responseData['MENSAJE']);
        } else {
          return ApiResponse.error('Error al registrar alerta');
        }
      } else {
        return ApiResponse.error('Error en el servidor');
      }
    } catch (e) {
      return ApiResponse.error('Error de conexión: $e');
    }
  }
}