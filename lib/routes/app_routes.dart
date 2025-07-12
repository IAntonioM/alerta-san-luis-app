import 'package:flutter/material.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/splash/presentation/splash_screen.dart';
import '../features/auth/presentation/register_screen.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/incidencias/presentation/incidencias_screen.dart';
class AppRoutes {
  static Map<String, WidgetBuilder> routes = {
    '/login': (context) => const LoginScreen(),
    '/home': (context) => const HomeScreen(),
    '/register': (context) => const RegisterScreen(),
    '/splash': (context) => const SplashScreen(),
    '/incidencia': (context) => const IncidenciaFormScreen(tipo: 'Incidencia'),
  };
}
