class MenuCategory {
  final String idCategoria;
  final String iconoCategoria;
  final String nomCategoria;
  final String grupo;
  final String fechaRegistro;
  final String flag;

  MenuCategory({
    required this.idCategoria,
    required this.iconoCategoria,
    required this.nomCategoria,
    required this.grupo,
    required this.fechaRegistro,
    required this.flag,
  });

  factory MenuCategory.fromJson(Map<String, dynamic> json) {
    return MenuCategory(
      idCategoria: json['id_categoria'] ?? '',
      iconoCategoria: json['icono_categoria'] ?? '',
      nomCategoria: json['nom_categoria'] ?? '',
      grupo: json['grupo'] ?? '',
      fechaRegistro: json['fecharegistro'] ?? '',
      flag: json['flag'] ?? '',
    );
  }
}