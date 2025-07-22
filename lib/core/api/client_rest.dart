import 'dart:convert';
import 'package:http/http.dart' as http;

// Importa tus modelos aquí
// import 'models/menu_alertas_dto.dart';
// import 'models/response_create_alerta.dart';
// import 'models/entidad_dto.dart';
// import 'models/moto_dto.dart';
// import 'models/response_ciudadano_dto.dart';
// import 'models/response_create_usuario.dart';

class ClienteRest {
  //no funciona "urlAlertaIndepHttp"
  static const String urlAlertaIndepHttp = "http://209.45.55.229:80/api.alerta.com/v1/";
  static const String urlServidorDesarrolloHttp = "http://161.132.177.168:8090/api.alertas.com/";

  final String baseUrl;
  final http.Client _client = http.Client();

  ClienteRest({this.baseUrl = urlAlertaIndepHttp});

  // Headers comunes
  Map<String, String> get _headers => {
    'Content-Type': 'application/x-www-form-urlencoded',
    'Accept': 'application/json',
  };

  /// Obtener entidades - método OPTIONS
  Future<List<dynamic>> getEntidades() async {
    try {
      final response = await _client.send(
        http.Request('OPTIONS', Uri.parse('${baseUrl}alerta/entidad'))
          ..headers.addAll(_headers),
      );
      
      final responseBody = await response.stream.bytesToString();
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(responseBody);
        return data;
        // return data.map((json) => EntidadDto.fromJson(json)).toList();
      } else {
        throw Exception('Error al obtener entidades: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  /// Obtener información de moto por placa
  Future<List<dynamic>> getMoto(String numPlaca) async {
    try {
      final response = await _client.get(
        Uri.parse('${baseUrl}alerta/vehiculo/$numPlaca'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data;
        // return data.map((json) => MotoDto.fromJson(json)).toList();
      } else {
        throw Exception('Error al obtener moto: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  /// Obtener menú de alertas
  Future<List<dynamic>> obtenerMenu() async {
    try {
      final response = await _client.get(
        Uri.parse('${baseUrl}servicio.php?opcion=api/menu'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data;
        // return data.map((json) => MenuAlertasDto.fromJson(json)).toList();
      } else {
        throw Exception('Error al obtener menú: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  /// Registrar alerta
  Future<dynamic> registrarAlerta({
    required String inIdCatAlerta,
    required String inIdEstado,
    required String inDescAlerta,
    required String inLatitud,
    required String inLongitud,
    required String inUsuarioCreacion,
    required String inNomImagen,
    required String inEstadoDet,
    required String inUsuarioCreacionDet,
    required String inImagenBytes,
    required String idCiudadano,
    required String inCorreo,
    required String inCelular,
  }) async {
    try {
      final Map<String, String> body = {
        'IN_ID_CAT_ALERTA': inIdCatAlerta,
        'IN_ID_ESTADO': inIdEstado,
        'IN_DESC_ALERTA': inDescAlerta,
        'IN_LATITUD': inLatitud,
        'IN_LONGITUD': inLongitud,
        'IN_USUARIO_CREACION': inUsuarioCreacion,
        'IN_NOM_IMAGEN': inNomImagen,
        'IN_ESTADO_DET': inEstadoDet,
        'IN_USUARIO_CREACION_DET': inUsuarioCreacionDet,
        'IN_IMAGEN_BYTES': inImagenBytes,
        'ID_CIUDADANO': idCiudadano,
        'IN_CORREO': inCorreo,
        'IN_CELULAR': inCelular,
      };

      final response = await _client.post(
        Uri.parse('${baseUrl}servicio.php?opcion=api/insertAlerta'),
        headers: _headers,
        body: body,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
        // return ResponseCreateAlerta.fromJson(data);
      } else {
        throw Exception('Error al registrar alerta: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  /// Registrar ciudadano
  Future<dynamic> registrarCiudadano({
    required String nombre,
    required String telefono,
    required String direccion,
    required String numDoc,
    required String correo,
  }) async {
    try {
      final Map<String, String> body = {
        'NOMBRE': nombre,
        'TELEFONO': telefono,
        'DIRECCION': direccion,
        'NUMDOC': numDoc,
        'CORREO': correo,
      };

      final response = await _client.post(
        Uri.parse('${baseUrl}servicio.php?opcion=api/insertCiudadano'),
        headers: _headers,
        body: body,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
        // return ResponseCiudadanoDto.fromJson(data);
      } else {
        throw Exception('Error al registrar ciudadano: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  /// Registrar usuario - método OPTIONS
  Future<dynamic> registrarUsuario(String usuario) async {
    try {
      final response = await _client.send(
        http.Request('OPTIONS', Uri.parse('${baseUrl}alerta/usuario/$usuario'))
          ..headers.addAll(_headers),
      );
      
      final responseBody = await response.stream.bytesToString();
      
      if (response.statusCode == 200) {
        final data = json.decode(responseBody);
        return data;
        // return ResponseCreateUsuario.fromJson(data);
      } else {
        throw Exception('Error al registrar usuario: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  /// Cerrar cliente HTTP
  void dispose() {
    _client.close();
  }
}

// Ejemplo de uso:
/*
void main() async {
  final clienteRest = ClienteRest();
  
  try {
    // Obtener menú
    final menu = await clienteRest.obtenerMenu();
    print('Menú obtenido: $menu');
    
    // Obtener entidades
    final entidades = await clienteRest.getEntidades();
    print('Entidades obtenidas: $entidades');
    
    // Registrar ciudadano
    final response = await clienteRest.registrarCiudadano(
      nombre: 'Juan Pérez',
      telefono: '123456789',
      direccion: 'Av. Principal 123',
      numDoc: '12345678',
      correo: 'juan@email.com',
    );
    print('Ciudadano registrado: $response');
    
  } catch (e) {
    print('Error: $e');
  } finally {
    clienteRest.dispose();
  }
}
*/