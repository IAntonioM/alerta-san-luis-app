import 'dart:async';
import 'package:boton_panico_app/utils/responsive_helper.dart';
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
      padding: ResponsiveHelper.getScreenPadding(context),
      child: SingleChildScrollView(
        child: ResponsiveHelper.centeredContent(
          context,
          Column(
            children: [
              SizedBox(height: ResponsiveHelper.getSpacing(context, base: 20)),
              // Grid responsivo de incidencias
              _buildResponsiveGrid(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResponsiveGrid() {
    // Determinar número de columnas según el dispositivo
    final columns = ResponsiveHelper.getGridColumns(
      context,
      mobile: 3,
      tablet: 4,
      desktop: 4,
    );

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: ResponsiveHelper.getSpacing(context, base: 8),
        mainAxisSpacing: ResponsiveHelper.getSpacing(context, base: 16),
        childAspectRatio: _getChildAspectRatio(context),
      ),
      itemCount: incidenciaMenus.length,
      itemBuilder: (context, index) {
        final menu = incidenciaMenus[index];
        return _buildCard(
          iconUrl: MenuService.getIconUrl(menu.iconoCategoria),
          text: menu.nomCategoria.toUpperCase(),
          color: _getColorForCategory(menu.nomCategoria),
          onTap: () => _handleCardTap(menu),
        );
      },
    );
  }

  double _getChildAspectRatio(BuildContext context) {
    // Ajustar la proporción según el dispositivo para mejor visualización
    if (ResponsiveHelper.isSmallMobile(context)) {
      return 0.7;
    } else if (ResponsiveHelper.isMobile(context)) {
      return 0.75;
    } else if (ResponsiveHelper.isTablet(context)) {
      return 0.8;
    } else {
      return 0.85;
    }
  }

  void _handleCardTap(MenuCategory menu) {
    
      // Navegar al formulario
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => IncidenciaFormScreen(
            tipo: menu.nomCategoria,
            idCategoria: menu.idCategoria.toString(),
          ),
        ),
      );
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
    final cardHeight = ResponsiveHelper.getResponsiveSize(context, 100.0);
    final iconSize = ResponsiveHelper.getIconSize(context, base: 60);
    final textHeight = ResponsiveHelper.getResponsiveSize(context, 60.0);
    final borderRadius = ResponsiveHelper.getBorderRadius(context, base: 12);
    final elevation = ResponsiveHelper.getElevation(context, base: 6);

    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          // Card principal
          Container(
            height: cardHeight,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(borderRadius),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: elevation,
                  offset: Offset(0, elevation / 2),
                ),
              ],
            ),
            child: Center(
              child: CachedNetworkImage(
                imageUrl: iconUrl,
                height: iconSize,
                width: iconSize,
                fit: BoxFit.contain,
                placeholder: (context, url) => SizedBox(
                  width: ResponsiveHelper.getIconSize(context, base: 24),
                  height: ResponsiveHelper.getIconSize(context, base: 24),
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                errorWidget: (context, url, error) => Icon(
                  _getDefaultIcon(),
                  size: ResponsiveHelper.getIconSize(context, base: 35),
                  color: Colors.white,
                ),
              ),
            ),
          ),
          SizedBox(height: ResponsiveHelper.getSpacing(context, base: 8)),
          // Contenedor con altura fija para el texto
          SizedBox(
            height: textHeight,
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: ResponsiveHelper.getCaptionFontSize(context, base: 11),
                fontWeight: FontWeight.w900,
                color: const Color(0xFF333333),
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