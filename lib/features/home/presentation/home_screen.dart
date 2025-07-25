import 'package:flutter/material.dart';
import '../../../core/widgets/alert_modal.dart';
import '../../incidencias/presentation/incidencias_screen.dart';

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
    // Aquí puedes agregar tu lógica de logout:
    // - Limpiar tokens de autenticación
    // - Limpiar datos locales
    // - Llamar a API de logout
    
    // Ejemplo de navegación al login
    Navigator.of(context).pushReplacementNamed('/login');
    
    // O si usas Navigator.pushAndRemoveUntil para limpiar todo el stack:
    // Navigator.of(context).pushAndRemoveUntil(
    //   MaterialPageRoute(builder: (context) => const LoginScreen()),
    //   (route) => false,
    // );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
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

// El resto del código permanece igual...
class EmergenciaTab extends StatelessWidget {
  const EmergenciaTab({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      {
        'icon': Icons.local_fire_department,
        'text': 'Bomberos',
        'color': const Color(0xFFE53935)
      },
      {
        'icon': Icons.security,
        'text': 'Serenazgo',
        'color': const Color(0xFF1976D2)
      },
      {
        'icon': Icons.local_hospital,
        'text': 'Ambulancia',
        'color': const Color(0xFF43A047)
      },
    ];

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 20),
          // Primera fila - 2 cards
          Row(
            children: [
              Expanded(
                child: _buildCard(
                  icon: items[0]['icon'] as IconData,
                  text: items[0]['text'] as String,
                  color: items[0]['color'] as Color,
                  onTap: () {
                    // Acción Bomberos
                    AlertModal.show(
                      context: context,
                      title: 'Bomberos',
                      onConfirm: () {
                        // Aquí puedes poner tu lógica de llamada API, etc.
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Alerta enviada a Bomberos')),
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildCard(
                  icon: items[1]['icon'] as IconData,
                  text: items[1]['text'] as String,
                  color: items[1]['color'] as Color,
                  onTap: () {
                    // Acción Serenazgo
                    AlertModal.show(
                      context: context,
                      title: 'Serenazgo',
                      onConfirm: () {
                        // Aquí puedes poner tu lógica de llamada API, etc.
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Alerta enviada a Serenazgo')),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Segunda fila - 1 card en su cuadrícula
          Row(
            children: [
              Expanded(
                child: _buildCard(
                  icon: items[2]['icon'] as IconData,
                  text: items[2]['text'] as String,
                  color: items[2]['color'] as Color,
                  onTap: () {
                    // Acción Ambulancia
                    AlertModal.show(
                      context: context,
                      title: 'Ambulancia',
                      onConfirm: () {
                        // Aquí puedes poner tu lógica de llamada API, etc.
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Alerta enviada a Ambulancia')),
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(child: Container()), // Espacio vacío
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCard({
    required IconData icon,
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
            Icon(
              icon,
              size: 48,
              color: Colors.white,
            ),
            const SizedBox(height: 12),
            Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class IncidenciasTab extends StatelessWidget {
  const IncidenciasTab({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      {
        'icon': Icons.warning,
        'text': 'Alerta rápida',
        'color': const Color(0xFFFF9800)
      },
      {
        'icon': Icons.medication,
        'text': 'Drogas',
        'color': const Color(0xFF9C27B0)
      },
      {
        'icon': Icons.person_search,
        'text': 'Sospechosos',
        'color': const Color(0xFF795548)
      },
      {
        'icon': Icons.car_crash,
        'text': 'Accidentes de tránsito',
        'color': const Color(0xFFE53935)
      },
      {
        'icon': Icons.theater_comedy,
        'text': 'Robo',
        'color': const Color(0xFF607D8B)
      },
    ];

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 20),
          // Primera fila
          Row(
            children: [
              Expanded(
                child: _buildCard(
                  icon: items[0]['icon'] as IconData,
                  text: items[0]['text'] as String,
                  color: items[0]['color'] as Color,
                  onTap: () {
                    // Acción Alerta rápida
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildCard(
                  icon: items[1]['icon'] as IconData,
                  text: items[1]['text'] as String,
                  color: items[1]['color'] as Color,
                  onTap: () {
                    // Acción Drogas
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const IncidenciaFormScreen(
                            tipo: 'Drogas'),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Segunda fila
          Row(
            children: [
              Expanded(
                child: _buildCard(
                  icon: items[2]['icon'] as IconData,
                  text: items[2]['text'] as String,
                  color: items[2]['color'] as Color,
                  onTap: () {
                    // Acción Sospechosos
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const IncidenciaFormScreen(
                            tipo: 'Sospechosos'),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildCard(
                  icon: items[3]['icon'] as IconData,
                  text: items[3]['text'] as String,
                  color: items[3]['color'] as Color,
                  onTap: () {
                    // Acción Accidentes
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const IncidenciaFormScreen(
                            tipo: 'Accidentes'),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Tercera fila - 1 card en su cuadrícula
          Row(
            children: [
              Expanded(
                child: _buildCard(
                  icon: items[4]['icon'] as IconData,
                  text: items[4]['text'] as String,
                  color: items[4]['color'] as Color,
                  onTap: () {
                    // Acción Robo
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const IncidenciaFormScreen(
                            tipo: 'Robo'),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(child: Container()), // Espacio vacío
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCard({
    required IconData icon,
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
            Icon(
              icon,
              size: 48,
              color: Colors.white,
            ),
            const SizedBox(height: 12),
            Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}