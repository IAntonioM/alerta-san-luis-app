class Citizen {
  final String id;
  final String nombre;
  final String telefono;
  final String direccion;
  final String numDoc;
  final String correo;

  Citizen({
    required this.id,
    required this.nombre,
    required this.telefono,
    required this.direccion,
    required this.numDoc,
    required this.correo,
  });

  factory Citizen.fromJson(Map<String, dynamic> json) {
    return Citizen(
      id: json['ID'] ?? '',
      nombre: json['NOMBRE'] ?? '',
      telefono: json['TELEFONO'] ?? '',
      direccion: json['DIRECCION'] ?? '',
      numDoc: json['NUMDOC'] ?? '',
      correo: json['CORREO'] ?? '',
    );
  }
}