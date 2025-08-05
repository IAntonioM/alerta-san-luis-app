// ignore_for_file: unrelated_type_equality_checks, curly_braces_in_flow_control_structures, use_build_context_synchronously
import 'package:boton_panico_app/features/home/screens/emergencia_tab.dart';
import 'package:boton_panico_app/features/home/screens/incidencias_tab.dart';
import 'package:boton_panico_app/utils/responsive_helper.dart';
import 'package:flutter/material.dart';
import '../../service/auth_service.dart';
import 'package:boton_panico_app/core/widgets/custom_dialog_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _showLogoutDialog(BuildContext context) {
    CustomDialog.showConfirmation(
      context: context,
      title: 'Cerrar Sesión',
      message: '¿Estás seguro de que quieres cerrar sesión?',
      primaryButtonText: 'Cerrar Sesión',
      secondaryButtonText: 'Cancelar',
      color: const Color(0xFFC22725), // Rojo
      icon: Icons.logout,
    ).then((confirmed) {
      if (confirmed == true) {
        _logout(context);
      }
    });
  }

  void _logout(BuildContext context) {
    AuthService.logout(context);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          //colores
          backgroundColor: const Color.fromARGB(255, 9, 154, 215),
          elevation: 0,
          toolbarHeight: 120,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Logo de la municipalidad
              Image.asset(
                'assets/imgs/muni_logo.png',
                height: ResponsiveHelper.getIconSize(context, base: 70),
                fit: BoxFit.contain,
              ),
              // Logo de la app
              Image.asset(
                'assets/imgs/logo.png',
                height: ResponsiveHelper.getIconSize(context, base: 80),
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

