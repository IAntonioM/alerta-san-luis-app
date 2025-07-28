// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/ciudadano_model.dart';

class UserStorageService {
  static const String _userKey = 'current_user';
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _tokenKey = 'auth_token'; // Nuevo para manejar tokens

  // Guardar datos del usuario después del login
  static Future<void> saveUser(Citizen user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Convertir el modelo a Map y luego a JSON string
      final userJson = jsonEncode({
        'ID': user.id,
        'NOMBRE': user.nombre,
        'TELEFONO': user.telefono,
        'DIRECCION': user.direccion,
        'NUMDOC': user.numDoc,
        'CORREO': user.correo,
      });
      
      await prefs.setString(_userKey, userJson);
      await prefs.setBool(_isLoggedInKey, true);
      
      print('Usuario guardado exitosamente');
    } catch (e) {
      print('Error al guardar usuario: $e');
    }
  }

  // Nuevo método para guardar token de autenticación
  static Future<void> saveToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
      print('Token guardado exitosamente');
    } catch (e) {
      print('Error al guardar token: $e');
    }
  }

  // Nuevo método para obtener token
  static Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_tokenKey);
    } catch (e) {
      print('Error al obtener token: $e');
      return null;
    }
  }

  // Obtener datos del usuario guardado
  static Future<Citizen?> getUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_userKey);
      
      if (userJson != null) {
        final userData = jsonDecode(userJson);
        return Citizen.fromJson(userData);
      }
      return null;
    } catch (e) {
      print('Error al obtener usuario: $e');
      return null;
    }
  }

  // Verificar si el usuario está logueado
  static Future<bool> isLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_isLoggedInKey) ?? false;
    } catch (e) {
      print('Error al verificar login: $e');
      return false;
    }
  }

  // Obtener ID del usuario (útil para APIs)
  static Future<String?> getUserId() async {
    final user = await getUser();
    return user?.id;
  }

  // Obtener correo del usuario (útil para APIs)
  static Future<String?> getUserEmail() async {
    final user = await getUser();
    return user?.correo;
  }

  // Obtener nombre del usuario
  static Future<String?> getUserName() async {
    final user = await getUser();
    return user?.nombre;
  }

  // Obtener número de documento del usuario
  static Future<String?> getUserNumDoc() async {
    final user = await getUser();
    return user?.numDoc;
  }

  // Limpiar datos del usuario (logout)
  static Future<void> clearUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userKey);
      await prefs.remove(_tokenKey); // También limpiar token
      await prefs.setBool(_isLoggedInKey, false);
      print('Datos de usuario eliminados');
    } catch (e) {
      print('Error al limpiar datos de usuario: $e');
    }
  }

  // Actualizar datos específicos del usuario
  static Future<void> updateUser(Citizen updatedUser) async {
    await saveUser(updatedUser);
  }
}