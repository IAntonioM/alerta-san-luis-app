import 'dart:async';
import 'package:flutter/material.dart';
import '../../incidencias/incidencias_screen.dart';
import '../../../service/menu_service.dart';
import '../../../models/menu_model.dart';
import 'package:cached_network_image/cached_network_image.dart';

class IncidenciasTab extends StatefulWidget {
  const IncidenciasTab({super.key});

  @override
  State<IncidenciasTab> createState() => _IncidenciasTabState();
}

class _IncidenciasTabState extends State<IncidenciasTab> {
  List<MenuCategory> incidenciaMenus = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadIncidenciaMenus();
  }

  Future<void> _loadIncidenciaMenus() async {
    final response = await MenuService.getMenus(context: context);

    if (response.success && response.data != null) {
      setState(() {
        // Filtrar menús de incidencias (grupo 1 según el API)
        incidenciaMenus =
            response.data!.where((menu) => menu.grupo == 1).toList();
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color.fromARGB(255, 2, 14, 179),
        ),
      );
    }

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Construir filas dinámicamente con 4 elementos por fila
            ..._buildDynamicRows(),
          ],
        ),
      ),
    );
  }

  // Método modificado para 4 elementos por fila en incidencias
  List<Widget> _buildDynamicRows() {
    List<Widget> rows = [];

    for (int i = 0; i < incidenciaMenus.length; i += 4) {
      List<Widget> rowChildren = [];

      // Primer elemento de la fila
      rowChildren.add(
        Expanded(
          child: _buildCard(
            iconUrl: MenuService.getIconUrl(incidenciaMenus[i].iconoCategoria),
            text: incidenciaMenus[i].nomCategoria.toUpperCase(),
            color: _getColorForCategory(incidenciaMenus[i].nomCategoria),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => IncidenciaFormScreen(
                    tipo: incidenciaMenus[i].nomCategoria,
                    idCategoria: incidenciaMenus[i].idCategoria.toString(),
                  ),
                ),
              );
            },
          ),
        ),
      );

      rowChildren.add(const SizedBox(width: 8));

      // Segundo elemento de la fila (si existe)
      if (i + 1 < incidenciaMenus.length) {
        rowChildren.add(
          Expanded(
            child: _buildCard(
              iconUrl:
                  MenuService.getIconUrl(incidenciaMenus[i + 1].iconoCategoria),
              text: incidenciaMenus[i + 1].nomCategoria.toUpperCase(),
              color: _getColorForCategory(incidenciaMenus[i + 1].nomCategoria),
              onTap: () {
                if (incidenciaMenus[i + 1]
                    .nomCategoria
                    .toLowerCase()
                    .contains('alerta')) {
                  // Acción para alerta rápida
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(
                            '${incidenciaMenus[i + 1].nomCategoria} activada')),
                  );
                } else {
                  // Navegar al formulario
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => IncidenciaFormScreen(
                        tipo: incidenciaMenus[i + 1].nomCategoria,
                        idCategoria:
                            incidenciaMenus[i + 1].idCategoria.toString(),
                      ),
                    ),
                  );
                }
              },
            ),
          ),
        );
      } else {
        // Espacio vacío si no hay segundo elemento
        rowChildren.add(Expanded(child: Container()));
      }

      rowChildren.add(const SizedBox(width: 8));

      // Tercer elemento de la fila (si existe)
      if (i + 2 < incidenciaMenus.length) {
        rowChildren.add(
          Expanded(
            child: _buildCard(
              iconUrl:
                  MenuService.getIconUrl(incidenciaMenus[i + 2].iconoCategoria),
              text: incidenciaMenus[i + 2].nomCategoria.toUpperCase(),
              color: _getColorForCategory(incidenciaMenus[i + 2].nomCategoria),
              onTap: () {
                if (incidenciaMenus[i + 2]
                    .nomCategoria
                    .toLowerCase()
                    .contains('alerta')) {
                  // Acción para alerta rápida
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(
                            '${incidenciaMenus[i + 2].nomCategoria} activada')),
                  );
                } else {
                  // Navegar al formulario
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => IncidenciaFormScreen(
                        tipo: incidenciaMenus[i + 2].nomCategoria,
                        idCategoria:
                            incidenciaMenus[i + 2].idCategoria.toString(),
                      ),
                    ),
                  );
                }
              },
            ),
          ),
        );
      } else {
        // Espacio vacío si no hay tercer elemento
        rowChildren.add(Expanded(child: Container()));
      }

      rowChildren.add(const SizedBox(width: 8));

      // Cuarto elemento de la fila (si existe)
      if (i + 3 < incidenciaMenus.length) {
        rowChildren.add(
          Expanded(
            child: _buildCard(
              iconUrl:
                  MenuService.getIconUrl(incidenciaMenus[i + 3].iconoCategoria),
              text: incidenciaMenus[i + 3].nomCategoria.toUpperCase(),
              color: _getColorForCategory(incidenciaMenus[i + 3].nomCategoria),
              onTap: () {
                if (incidenciaMenus[i + 3]
                    .nomCategoria
                    .toLowerCase()
                    .contains('alerta')) {
                  // Acción para alerta rápida
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(
                            '${incidenciaMenus[i + 3].nomCategoria} activada')),
                  );
                } else {
                  // Navegar al formulario
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => IncidenciaFormScreen(
                        tipo: incidenciaMenus[i + 3].nomCategoria,
                        idCategoria:
                            incidenciaMenus[i + 3].idCategoria.toString(),
                      ),
                    ),
                  );
                }
              },
            ),
          ),
        );
      } else {
        // Espacio vacío si no hay cuarto elemento
        rowChildren.add(Expanded(child: Container()));
      }

      rows.add(Row(children: rowChildren));

      // Agregar espaciado entre filas (excepto después de la última)
      if (i + 4 < incidenciaMenus.length) {
        rows.add(const SizedBox(height: 16));
      }
    }

    return rows;
  }

  Color _getColorForCategory(String categoryName) {
    final name = categoryName.toLowerCase();
    if (name.contains('alerta rapida')) return const Color(0xFFC22725);
    if (name.contains('drogas')) return const Color(0xFF17DC09);
    if (name.contains('robo')) return const Color(0xFF051A51);
    if (name.contains('sospechosos')) return const Color(0xFF494544);
    if (name.contains('accidente de transito')) return const Color(0xFFAF9570);
    if (name.contains('alteración al orden público')) return const Color(0xFF0C9BD7);
    if (name.contains('violencia familiar')) return const Color(0xFF49738B);
    if (name.contains('ruidos molestos')) return const Color(0xFF494544);
    if (name.contains('parques y jardines')) return const Color(0xFF76A054);
    if (name.contains('limpieza pública')) return const Color(0xFF76A054);
    if (name.contains('otros')) return const Color(0xFF051A51);
    return const Color(0xFF757575); // Color por defecto
  }

  Widget _buildCard({
    required String iconUrl,
    required String text,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          // Card principal
          Container(
            height: 100,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black,
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Center(
              child: CachedNetworkImage(
                imageUrl: iconUrl,
                height: 100,
                width: 100,
                fit: BoxFit.contain,
                placeholder: (context, url) =>
                    const CircularProgressIndicator(),
                errorWidget: (context, url, error) => Icon(
                  _getDefaultIcon(),
                  size: 35,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Contenedor con altura fija para el texto
          SizedBox(
            height: 60, // Altura fija para 2 líneas de texto
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                color: Color(0xFF333333),
              ),
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getDefaultIcon() {
    return Icons.warning;
  }
}
