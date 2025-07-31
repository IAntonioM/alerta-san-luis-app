import 'dart:convert';
import 'package:boton_panico_app/service/user_storage_service.dart';
import 'package:http/http.dart' as http;

class ApiService {
  // Nueva URL base según la documentación
  static const String baseUrl = 'https://733cbe01c49c.ngrok-free.app';

  static Map<String, String> get headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  static Map<String, String> get formHeaders => {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Accept': 'application/json',
      };

  static Future<Map<String, String>> get headersWithToken async {
    final token = await UserStorageService.getToken();
    final baseHeaders = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (token != null) {
      baseHeaders['Authorization'] = 'Bearer $token';
    }

    return baseHeaders;
  }

// Agregar nuevo método GET con token
  static Future<http.Response> getWithToken(String endpoint) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final headers = await headersWithToken;
    return await http.get(url, headers: headers);
  }

  static Future<http.Response> get(String endpoint) async {
    final url = Uri.parse('$baseUrl$endpoint');
    return await http.get(url, headers: headers);
  }

  static Future<http.Response> post(
      String endpoint, Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl$endpoint');
    return await http.post(
      url,
      headers: headers,
      body: jsonEncode(data),
    );
  }

  // Método para enviar form-data como application/x-www-form-urlencoded
  static Future<http.Response> postFormData(
      String endpoint, Map<String, String> data) async {
    final url = Uri.parse('$baseUrl$endpoint');

    return await http.post(
      url,
      headers: formHeaders,
      body: data,
    );
  }

  // Nuevo método para manejar multipart/form-data (para alertas con archivos)
  static Future<http.StreamedResponse> postMultipartFormData(
      String endpoint, Map<String, String> fields) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final token = await UserStorageService.getToken();
    
    var request = http.MultipartRequest('POST', url);

    if(token != null){
      request.headers['Authorization'] = 'Bearer $token';
    }

    // Agregar todos los campos
    request.fields.addAll(fields);

    return await request.send();
  }
}
