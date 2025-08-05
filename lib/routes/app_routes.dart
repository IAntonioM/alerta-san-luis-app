import 'package:flutter/material.dart';
import '../features/auth/login_screen.dart';
import '../features/splash/splash_screen.dart';
import '../features/auth/register_screen.dart';
import '../features/home/home_screen.dart';
import '../features/incidencias/incidencias_screen.dart';
class AppRoutes {
  static Map<String, WidgetBuilder> routes = {
    '/login': (context) => const LoginScreen(),
    '/home': (context) => const HomeScreen(),
    '/register': (context) => const RegisterScreen(),
    '/splash': (context) => const SplashScreen(),
    '/incidencia': (context) => const IncidenciaFormScreen(tipo: 'Incidencia', idCategoria: '1',),
  };
}
