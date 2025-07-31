// ignore_for_file: unrelated_type_equality_checks, curly_braces_in_flow_control_structures, use_build_context_synchronously

import 'package:boton_panico_app/service/boton_de_panico_service.dart';
import 'package:boton_panico_app/service/socket_service.dart';
import 'package:boton_panico_app/service/user_storage_service.dart';
import 'package:flutter/material.dart';
import '../../../core/widgets/alert_modal.dart';
import '../../incidencias/presentation/incidencias_screen.dart';
import '../../../service/auth_service.dart';
import '../../../service/menu_service.dart';
import '../../../models/menu_model.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cerrar Sesión'),
          content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _logout(context);
              },
              child: const Text('Cerrar Sesión'),
            ),
          ],
        );
      },
    );
  }

  void _logout(BuildContext context) {
    AuthService.logout();
    Navigator.of(context).pushReplacementNamed('/splash');
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 2, 14, 179),
          elevation: 0,
          toolbarHeight: 120,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Logo de la municipalidad
              Image.asset(
                'assets/imgs/muni_logo.png',
                height: 60,
                fit: BoxFit.contain,
              ),
              // Logo de la app
              Image.asset(
                'assets/imgs/logo.png',
                height: 50,
                fit: BoxFit.contain,
              ),
            ],
          ),
          actions: [
            IconButton(
              onPressed: () => _showLogoutDialog(context),
              icon: const Icon(
                Icons.logout,
                color: Colors.white,
                size: 24,
              ),
              tooltip: 'Cerrar Sesión',
            ),
          ],
          bottom: const TabBar(
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            labelStyle: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            tabs: [
              Tab(text: "Emergencia"),
              Tab(text: "Incidencias"),
            ],
          ),
        ),
        body: Container(
          color: Colors.white,
          child: const TabBarView(
            children: [
              EmergenciaTab(),
              IncidenciasTab(),
            ],
          ),
        ),
      ),
    );
  }
}

class EmergenciaTab extends StatefulWidget {
  const EmergenciaTab({super.key});

  @override
  State<EmergenciaTab> createState() => _EmergenciaTabState();
}

class _EmergenciaTabState extends State<EmergenciaTab> {
  List<MenuCategory> emergenciaMenus = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEmergenciaMenus();
  }

  Future<void> _loadEmergenciaMenus() async {
    final response = await MenuService.getMenus(context: context);

    if (response.success && response.data != null) {
      setState(() {
        // Filtrar menús de emergencia (grupo 2 según el API)
        emergenciaMenus =
            response.data!.where((menu) => menu.grupo == 2).toList();
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
            // Construir filas dinámicamente
            ..._buildDynamicRows(),
            // Botón de pánico
            const SizedBox(height: 20),
            _buildPanicButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildPanicButton() {
    return GestureDetector(
      onTap: () => _handlePanicButton(context),
      child: Container(
        width: double.infinity,
        height: 250,
        decoration: BoxDecoration(
          color: const Color(0xFFFFD700), // Color amarillo
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.warning,
              size: 70,
              color: Colors.red,
            ),
            SizedBox(height: 8),
            Text(
              'Botón de pánico',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handlePanicButton(BuildContext context) async {
    // Mostrar confirmación
    final shouldSend = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('⚠️ BOTÓN DE PÁNICO'),
        content: const Text('¿Confirmas que necesitas ayuda de emergencia?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('ENVIAR ALERTA',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (shouldSend == true) {
      _sendPanicAlert();
    }
  }

  void _sendPanicAlert() async {
    // Mostrar loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    final response =
        await BotonDePanicoService.sendPanicAlert(context: context);

    Navigator.pop(context); // Cerrar loading

    if (response.success) {
      _showWaitingDialog();
      _connectSocket();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.error ?? 'Error al enviar alerta'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showWaitingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('⏳ Esperando respuesta'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            const Text(
                'Estamos a la espera de una respuesta del personal de seguridad.'),
            const SizedBox(height: 8),
            Text('Tiempo restante: 20 segundos',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );

    // Timer de 20 segundos
    Future.delayed(const Duration(seconds: 20), () {
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
        _showTimeoutAlert();
      }
    });
  }

  void _connectSocket() async {
    final userId = await UserStorageService.getUserId();
    if (userId != null) {
      SocketService.connect(userId);

      SocketService.onAlertaAceptada((data) {
        if (data['id'] == userId) {
          Navigator.pop(context); // Cerrar diálogo
          _showSuccessAlert();
        }
      });

      SocketService.onAlertaNoRespondida((data) {
        if (data['id'] == userId) {
          Navigator.pop(context); // Cerrar diálogo
          _showNoResponseAlert();
        }
      });
    }
  }

  void _showSuccessAlert() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('✔️ Alerta recibida'),
        content:
            const Text('Tu alerta fue aceptada. Recibirás atención en breve.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showTimeoutAlert() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('⚠️ Tiempo agotado'),
        content: const Text('Ningún agente respondió a tiempo.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showNoResponseAlert() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('⚠️ Alerta no respondida'),
        content: const Text('Ningún agente respondió a tu alerta.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildDynamicRows() {
    List<Widget> rows = [];

    for (int i = 0; i < emergenciaMenus.length; i += 2) {
      List<Widget> rowChildren = [];

      // Primer elemento de la fila
      rowChildren.add(
        Expanded(
          child: _buildCard(
            iconUrl: MenuService.getIconUrl(emergenciaMenus[i].iconoCategoria),
            text: emergenciaMenus[i].nomCategoria,
            color: _getColorForCategory(emergenciaMenus[i].nomCategoria),
            onTap: () {
              AlertModal.show(
                context: context,
                title: emergenciaMenus[i].nomCategoria,
                onConfirm: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'Alerta enviada a ${emergenciaMenus[i].nomCategoria}'),
                    ),
                  );
                },
              );
            },
          ),
        ),
      );

      rowChildren.add(const SizedBox(width: 16));

      // Segundo elemento de la fila (si existe)
      if (i + 1 < emergenciaMenus.length) {
        rowChildren.add(
          Expanded(
            child: _buildCard(
              iconUrl:
                  MenuService.getIconUrl(emergenciaMenus[i + 1].iconoCategoria),
              text: emergenciaMenus[i + 1].nomCategoria,
              color: _getColorForCategory(emergenciaMenus[i + 1].nomCategoria),
              onTap: () {
                AlertModal.show(
                  context: context,
                  title: emergenciaMenus[i + 1].nomCategoria,
                  onConfirm: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            'Alerta enviada a ${emergenciaMenus[i + 1].nomCategoria}'),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        );
      } else {
        // Espacio vacío si no hay segundo elemento
        rowChildren.add(Expanded(child: Container()));
      }

      rows.add(Row(children: rowChildren));

      // Agregar espaciado entre filas (excepto después de la última)
      if (i + 2 < emergenciaMenus.length) {
        rows.add(const SizedBox(height: 16));
      }
    }

    return rows;
  }

  Color _getColorForCategory(String categoryName) {
    final name = categoryName.toLowerCase();
    if (name.contains('bomberos')) return const Color(0xFFC22725);
    if (name.contains('serenazgo')) return const Color(0xFF0C9BD7);
    if (name.contains('ambulancia')) return const Color(0xFF76A054);
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
      child: Container(
        height: 140,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Imagen desde URL
            Image.network(
              iconUrl,
              height: 140,
              width: 140,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                // Fallback a icono por defecto si la imagen no carga
                return Icon(
                  _getDefaultIcon(),
                  size: 70,
                  color: Colors.white,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    SocketService.disconnect();
    super.dispose();
  }

  IconData _getDefaultIcon() {
    return Icons.emergency;
  }
}

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
            // Construir filas dinámicamente
            ..._buildDynamicRows(),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildDynamicRows() {
    List<Widget> rows = [];

    for (int i = 0; i < incidenciaMenus.length; i += 2) {
      List<Widget> rowChildren = [];

      // Primer elemento de la fila
      rowChildren.add(
        Expanded(
          child: _buildCard(
            iconUrl: MenuService.getIconUrl(incidenciaMenus[i].iconoCategoria),
            text: incidenciaMenus[i].nomCategoria,
            color: _getColorForCategory(incidenciaMenus[i].nomCategoria),
            onTap: () {
              if (incidenciaMenus[i]
                  .nomCategoria
                  .toLowerCase()
                  .contains('alerta')) {
                // Acción para alerta rápida
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content:
                          Text('${incidenciaMenus[i].nomCategoria} activada')),
                );
              } else {
                // Navegar al formulario
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => IncidenciaFormScreen(
                      tipo: incidenciaMenus[i].nomCategoria,
                      idCategoria: incidenciaMenus[i].idCategoria.toString(),
                    ),
                  ),
                );
              }
            },
          ),
        ),
      );

      rowChildren.add(const SizedBox(width: 16));

      // Segundo elemento de la fila (si existe)
      if (i + 1 < incidenciaMenus.length) {
        rowChildren.add(
          Expanded(
            child: _buildCard(
              iconUrl:
                  MenuService.getIconUrl(incidenciaMenus[i + 1].iconoCategoria),
              text: incidenciaMenus[i + 1].nomCategoria,
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
                        idCategoria: incidenciaMenus[i+1].idCategoria.toString(),
                      ),
                    ),
                  );
                }
                print("id categoria:");
                print(incidenciaMenus[i + 1].idCategoria.toString());
              },
            ),
          ),
        );
      } else {
        // Espacio vacío si no hay segundo elemento
        rowChildren.add(Expanded(child: Container()));
      }

      rows.add(Row(children: rowChildren));

      // Agregar espaciado entre filas (excepto después de la última)
      if (i + 2 < incidenciaMenus.length) {
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
    if (name.contains('alteración al orden público'))
      return const Color(0xFF0C9BD7);
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
      child: Container(
        height: 140,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Imagen desde URL
            Image.network(
              iconUrl,
              height: 140,
              width: 140,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                // Fallback a icono por defecto si la imagen no carga
                return Icon(
                  _getDefaultIcon(),
                  size: 70,
                  color: Colors.white,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  IconData _getDefaultIcon() {
    return Icons.warning;
  }
}
