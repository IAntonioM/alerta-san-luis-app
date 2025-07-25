import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'https://d19fc6d7c99e.ngrok-free.app/api.alertas.com';
  
  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  static Future<http.Response> get(String endpoint) async {
    final url = Uri.parse('$baseUrl$endpoint');
    return await http.get(url, headers: headers);
  }

  static Future<http.Response> post(String endpoint, Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl$endpoint');
    return await http.post(
      url,
      headers: headers,
      body: jsonEncode(data),
    );
  }

  // Método corregido para enviar form-data como application/x-www-form-urlencoded
  static Future<http.Response> postFormData(String endpoint, Map<String, String> data) async {
    final url = Uri.parse('$baseUrl$endpoint');
    
    return await http.post(
      url,
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Accept': 'application/json',
      },
      body: data, // http.post automáticamente codifica el Map<String, String> como form-urlencoded
    );
  }

  // Método alternativo si necesitas multipart (para archivos)
  static Future<http.Response> postMultipart(String endpoint, Map<String, String> data) async {
    final url = Uri.parse('$baseUrl$endpoint');
    
    var request = http.MultipartRequest('POST', url);
    
    // Agregar todos los campos al form-data
    data.forEach((key, value) {
      request.fields[key] = value;
    });
    
    // Enviar la request
    var streamedResponse = await request.send();
    
    // Convertir la respuesta a http.Response
    return await http.Response.fromStream(streamedResponse);
  }
}