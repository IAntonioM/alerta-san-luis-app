import 'dart:convert';
import 'package:http/http.dart' as http;

class ErrorResponse {
  final String? message;

  ErrorResponse({this.message});

  // Constructor desde JSON
  factory ErrorResponse.fromJson(Map<String, dynamic> json) {
    return ErrorResponse(
      message: json['message'] as String?,
    );
  }

  // Convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'message': message,
    };
  }

  // Método estático para crear desde ResponseBody (equivalente al método Java)
  static ErrorResponse fromErrorBody(http.Response response) {
    try {
      if (response.body.isNotEmpty) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        return ErrorResponse.fromJson(json);
      } else {
        return ErrorResponse(message: 'Error desconocido: ${response.statusCode}');
      }
    } catch (e) {
      return ErrorResponse(
        message: 'Error de formato: ${response.statusCode} - ${response.reasonPhrase}',
      );
    }
  }

  // Método para crear desde String directamente
  static ErrorResponse fromErrorString(String errorBody) {
    try {
      if (errorBody.isNotEmpty) {
        final Map<String, dynamic> json = jsonDecode(errorBody);
        return ErrorResponse.fromJson(json);
      } else {
        return ErrorResponse(message: 'Error desconocido');
      }
    } catch (e) {
      return ErrorResponse(message: 'Error de formato en respuesta');
    }
  }

  // Getter para el mensaje (equivalente al método Java)
  String? get getMessage => message;

  // Override toString para debugging
  @override
  String toString() {
    return 'ErrorResponse{message: $message}';
  }

  // Método para verificar si tiene mensaje
  bool hasMessage() {
    return message != null && message!.isNotEmpty;
  }
}

// Clase de extensión para manejo de errores HTTP
class ApiException implements Exception {
  final int statusCode;
  final ErrorResponse errorResponse;

  ApiException(this.statusCode, this.errorResponse);

  @override
  String toString() {
    return 'ApiException: $statusCode - ${errorResponse.message}';
  }
}

// Ejemplo de uso con manejo de errores:
/*
class ApiClient {
  static Future<T> handleResponse<T>(
    http.Response response,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        final Map<String, dynamic> json = jsonDecode(response.body);
        return fromJson(json);
      } catch (e) {
        throw Exception('Error al parsear respuesta: $e');
      }
    } else {
      final errorResponse = ErrorResponse.fromErrorBody(response);
      throw ApiException(response.statusCode, errorResponse);
    }
  }
}

// Ejemplo de uso en tu ClienteRest:
Future<List<dynamic>> obtenerMenuConManejodeErrores() async {
  try {
    final response = await _client.get(
      Uri.parse('${baseUrl}servicio.php?opcion=api/menu'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data;
    } else {
      final errorResponse = ErrorResponse.fromErrorBody(response);
      throw ApiException(response.statusCode, errorResponse);
    }
  } catch (e) {
    if (e is ApiException) {
      print('Error de API: ${e.errorResponse.message}');
      rethrow;
    } else {
      throw Exception('Error de conexión: $e');
    }
  }
}
*/