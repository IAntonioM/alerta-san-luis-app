import 'dart:convert';
import '../models/menu_model.dart';
import '../models/api_response_model.dart';
import 'api_service.dart';

class MenuService {
  static Future<ApiResponse<List<MenuCategory>>> getMenus() async {
    try {
      final response = await ApiService.get('/servicio.php?opcion=api/menu');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final menus = data.map((json) => MenuCategory.fromJson(json)).toList();
        return ApiResponse.success(menus);
      } else {
        return ApiResponse.error('Error al obtener menús');
      }
    } catch (e) {
      return ApiResponse.error('Error de conexión: $e');
    }
  }

  static String getIconUrl(String iconName) {
    return '${ApiService.baseUrl}/assets/images/ICONOS/$iconName';
  }
}