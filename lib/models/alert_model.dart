class AlertModel {
  final int categoryId;
  final String description;
  final double latitude;
  final double longitude;
  final String userId;
  final int citizenId;
  final String email;
  final String phone;
  final String? imageName;
  final String? imageBase64;

  AlertModel({
    required this.categoryId,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.userId,
    required this.citizenId,
    required this.email,
    required this.phone,
    this.imageName,
    this.imageBase64,
  });

  Map<String, String> toMap() {
    return {
      'IN_ID_CAT_ALERTA': categoryId.toString(),
      'IN_ID_ESTADO': '1',
      'IN_DESC_ALERTA': description,
      'IN_LATITUD': latitude.toString(),
      'IN_LONGITUD': longitude.toString(),
      'IN_USUARIO_CREACION': userId,
      'IN_ESTADO_DET': '1',
      'IN_USUARIO_CREACION_DET': userId,
      'ID_CIUDADANO': citizenId.toString(),
      'IN_CORREO': email,
      'IN_CELULAR': phone,
      'IN_NOM_IMAGEN': imageName ?? '',
      'IN_IMAGEN_BYTES': imageBase64 ?? '',
    };
  }
}
