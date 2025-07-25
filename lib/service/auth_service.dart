import 'dart:convert';
import '../models/ciudadano_model.dart';
import '../models/api_response_model.dart';
import 'api_service.dart';

class AuthService {
  static Future<ApiResponse<Citizen>> registerCitizen({
    required String correo,
    required String telefono,
    required String nombre,
    required String direccion,
    required String numDoc,
  }) async {
    try {
      final response = await ApiService.postFormData(
        '/servicio.php?opcion=api/insertCiudadano',
        {
          'CORREO': correo,
          'TELEFONO': telefono,
          'NOMBRE': nombre,
          'DIRECCION': direccion,
          'NUMDOC': numDoc,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ApiResponse.success(Citizen.fromJson(data));
      } else {
        return ApiResponse.error('Error en el registro');
      }
    } catch (e) {
      return ApiResponse.error('Error de conexión: $e');
    }
  }

  static Future<ApiResponse<Citizen>> loginCitizen({
    required String correo,
    required String contrasena,
  }) async {
    try {
      final response = await ApiService.postFormData(
        '/servicio.php?opcion=api/loginCiudadano',
        {
          'CORREO': correo,
          'CONTRASENA': contrasena,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return ApiResponse.success(Citizen.fromJson(data['data']));
        } else {
          return ApiResponse.error('Credenciales incorrectas');
        }
      } else {
        return ApiResponse.error('Error en el login');
      }
    } catch (e) {
      return ApiResponse.error('Error de conexión: $e');
    }
  }
}