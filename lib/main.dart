// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:boton_panico_app/routes/app_routes.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mi App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/splash',
      routes: AppRoutes.routes,
      builder: (context, child) {
        final mediaQueryData = MediaQuery.of(context);
        final scale = mediaQueryData.textScaleFactor;
        final devicePixelRatio = mediaQueryData.devicePixelRatio;

        // Limitar el escalado de texto entre 0.8 y 1.3
        final constrainedScale = scale.clamp(0.8, 1.3);
        final constrainedPixelRatio = devicePixelRatio.clamp(1.0, 1.5);

        return MediaQuery(
          data: mediaQueryData.copyWith(
            textScaleFactor: constrainedScale,
            devicePixelRatio: constrainedPixelRatio,
          ),
          child: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/imgs/background-login.jpg'),
                fit: BoxFit.cover,
              ),
            ),
            child: child,
          ),
        );
      },
    );
  }
}
