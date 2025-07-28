// ignore_for_file: use_build_context_synchronously, avoid_print

import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/menu_model.dart';
import '../models/api_response_model.dart';
import 'api_service.dart';
import 'error_modal_service.dart';

class MenuService {
  // Cache estático para los menús
  static List<MenuCategory>? _cachedMenus;
  static DateTime? _cacheTimestamp;
  static const Duration _cacheExpiration = Duration(minutes: 30); // Configurable

  // Método para verificar si el cache es válido
  static bool _isCacheValid() {
    if (_cachedMenus == null || _cacheTimestamp == null) return false;
    return DateTime.now().difference(_cacheTimestamp!) < _cacheExpiration;
  }

  // Método para limpiar el cache manualmente
  static void clearCache() {
    _cachedMenus = null;
    _cacheTimestamp = null;
  }

  static Future<ApiResponse<List<MenuCategory>>> getMenus({
    required BuildContext context,
    bool forceRefresh = false, // Parámetro para forzar actualización
  }) async {
    // Si no se fuerza refresh y el cache es válido, retornar cache
    if (!forceRefresh && _isCacheValid()) {
      return ApiResponse.success(_cachedMenus!);
    }

    try {
      final response = await ApiService.getWithToken('/api/menu');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final menus = data.map((json) => MenuCategory.fromJson(json)).toList();

        // Guardar en cache
        _cachedMenus = menus;
        _cacheTimestamp = DateTime.now();

        print("Menús cargados desde API y guardados en cache");

        return ApiResponse.success(menus);
      } else {
        await ErrorModalService.showErrorModal(
          context,
          title: 'Error en la obtención de data',
          message: 'Error al obtener los menus.',
        );
        return ApiResponse.error('Error al obtener menús');
      }
    } catch (e) {
      print('Error en MenusGet: $e');
      await ErrorModalService.showErrorModal(
        context,
        title: 'Error de Conexión',
        message: 'No se pudo conectar con el servidor. Verifica tu conexión a internet.',
      );
      return ApiResponse.error('Error de conexión: $e');
    }
  }

  static String getIconUrl(String iconName) {
    return '${ApiService.baseUrl}/api/img/$iconName';
  }
}