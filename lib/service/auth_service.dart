import 'dart:convert';
import 'package:boton_panico_app/utils/user_storage_service.dart';
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

      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data is Map<String, dynamic>) {
          if (data.containsKey('success')) {
            if (data['success'] == true) {
              final citizen = Citizen.fromJson(data['data'] ?? data);
              // Guardar automáticamente después del registro exitoso
              await UserStorageService.saveUser(citizen);
              return ApiResponse.success(citizen);
            } else {
              return ApiResponse.error(data['message'] ?? 'Error en el registro');
            }
          } else {
            final citizen = Citizen.fromJson(data);
            await UserStorageService.saveUser(citizen);
            return ApiResponse.success(citizen);
          }
        } else {
          return ApiResponse.error('Formato de respuesta inválido');
        }
      } else {
        return ApiResponse.error('Error del servidor: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en registerCitizen: $e');
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
          'NUMDOC': contrasena,
        },
      );

      print('Login Status Code: ${response.statusCode}');
      print('Login Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final citizen = Citizen.fromJson(data['data']);
          // Guardar automáticamente después del login exitoso
          await UserStorageService.saveUser(citizen);
          return ApiResponse.success(citizen);
        } else {
          return ApiResponse.error(data['message'] ?? 'Credenciales incorrectas');
        }
      } else {
        return ApiResponse.error('Error en el login: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en loginCitizen: $e');
      return ApiResponse.error('Error de conexión: $e');
    }
  }

  // Método para cerrar sesión
  static Future<void> logout() async {
    await UserStorageService.clearUser();
  }

  // Método para verificar si hay una sesión activa
  static Future<bool> isUserLoggedIn() async {
    return await UserStorageService.isLoggedIn();
  }

  // Método para obtener el usuario actual
  static Future<Citizen?> getCurrentUser() async {
    return await UserStorageService.getUser();
  }
}