// ignore_for_file: avoid_print, use_build_context_synchronously

import 'dart:convert';
import 'package:boton_panico_app/features/splash/splash_screen.dart';
import 'package:boton_panico_app/service/user_storage_service.dart';
import 'package:flutter/material.dart';
import '../models/ciudadano_model.dart';
import '../models/api_response_model.dart';
import 'api_service.dart';
import 'error_modal_service.dart';

class AuthService {
  // Registro de ciudadano - nueva ruta y estructura
  static Future<ApiResponse<Citizen>> registerCitizen({
    required BuildContext context,
    required String correo,
    required String telefono,
    required String nombre,
    required String direccion,
    required String numDoc,
    required String contrasena, // Ahora es requerido
  }) async {
    try {
      // Nueva estructura según la API
      final requestData = {
        'nombre': nombre,
        'telefono': telefono,
        'direccion': direccion,
        'numdoc': numDoc,
        'correo': correo, // Opcional según docs
        'contrasena': contrasena,
      };

      print('Acá es requestData:');
      print(requestData);

      final response = await ApiService.post(
        '/api/ciudadano', // Nueva ruta
        requestData,
      );

      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);

        if (data is Map<String, dynamic> && data['success'] == true) {
          // Crear objeto Citizen con los datos retornados
          final citizenData = data['data'];
          final citizen = Citizen(
            id: citizenData['ID'].toString(),
            nombre: nombre,
            telefono: telefono,
            direccion: direccion,
            numDoc: numDoc,
            correo: citizenData['CORREO'] ?? correo,
          );

          await UserStorageService.saveUser(citizen);

          // Mostrar modal de éxito
          await ErrorModalService.showSuccessModal(
            context,
            title: 'Registro Exitoso',
            message:
                'Tu cuenta ha sido creada correctamente. Bienvenido ${citizen.nombre}!',
          );

          return ApiResponse.success(citizen);
        } else {
          // Mostrar modal de error
          await ErrorModalService.showErrorModal(
            context,
            title: 'Error en el Registro',
            message:
                data['message'] ?? 'Error en el registro. Verifica tus datos.',
          );
          return ApiResponse.error(data['message'] ?? 'Error en el registro');
        }
      } else {
        // Mostrar modal de error del servidor usando el nuevo método
        await ErrorModalService.showApiErrorModal(
          context,
          response,
          title: 'Error del Servidor',
          defaultMessage: 'No se pudo completar el registro',
        );
        return ApiResponse.error('Error del servidor: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en registerCitizen: $e');
      // Mostrar modal de error de conexión
      await ErrorModalService.showErrorModal(
        context,
        title: 'Error de Conexión',
        message:
            'No se pudo conectar con el servidor. Verifica tu conexión a internet.',
      );
      return ApiResponse.error('Error de conexión: $e');
    }
  }

  // Login de ciudadano - nueva ruta y estructura
  static Future<ApiResponse<Citizen>> loginCitizen({
    required BuildContext context,
    required String usuario, // Puede ser correo o numDoc
    required String contrasena,
  }) async {
    try {
      final requestData = {
        'usuario': usuario, // Cambio de 'correo' a 'usuario'
        'contrasena': contrasena, // Cambio de 'NUMDOC' a 'contrasena'
      };

      final response = await ApiService.post(
        '/api/auth/login-ciudadano', // Nueva ruta
        requestData,
      );

      print('Login Status Code: ${response.statusCode}');
      print('Login Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final citizenData = data['data'];
          final citizen = Citizen(
            id: citizenData['ID'].toString(),
            nombre: citizenData['NOMBRE'],
            telefono: citizenData['TELEFONO'],
            direccion: citizenData['DIRECCION'],
            numDoc: citizenData['NUMDOC'],
            correo: citizenData['CORREO'],
          );

          // Guardar token si es necesario para futuras peticiones
          final token = data['token'];
          if (token != null) {
            await UserStorageService.saveToken(token);
          }

          await UserStorageService.saveUser(citizen);

          // Mostrar modal de éxito
          await ErrorModalService.showSuccessModal(
            context,
            title: 'Inicio de Sesión Exitoso',
            message: 'Bienvenido, ${citizen.nombre}!',
          );

          return ApiResponse.success(citizen);
        } else {
          // Mostrar modal de error
          await ErrorModalService.showErrorModal(
            context,
            title: 'Credenciales Incorrectas',
            message: data['message'] ?? 'Usuario o contraseña incorrectos.',
          );
          return ApiResponse.error(
              data['message'] ?? 'Credenciales incorrectas');
        }
      } else {
        // Mostrar modal de error del servidor usando el nuevo método
        await ErrorModalService.showApiErrorModal(
          context,
          response,
          title: 'No se pudo iniciar sesión',
          defaultMessage: 'No se pudo iniciar sesión',
        );

        // Para obtener el mensaje parseado para el return
        String errorMessage =
            'No se pudo iniciar sesión. Código: ${response.statusCode}';
        try {
          final errorData = jsonDecode(response.body);
          if (errorData is Map<String, dynamic> &&
              errorData['message'] != null) {
            errorMessage = errorData['message'];
          }
        } catch (parseError) {
          // Usar mensaje por defecto
        }

        return ApiResponse.error('Error en el login: $errorMessage');
      }
    } catch (e) {
      print('Error en loginCitizen: $e');
      // Mostrar modal de error de conexión
      await ErrorModalService.showErrorModal(
        context,
        title: 'Error de Conexión',
        message:
            'No se pudo conectar con el servidor. Verifica tu conexión a internet.',
      );
      return ApiResponse.error('Error de conexión: $e');
    }
  }

  // Método para cerrar sesión
  static Future<void> logout(BuildContext context) async {
    await UserStorageService.clearUser();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const SplashScreen()),
      (Route<dynamic> route) => false,
    );
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
