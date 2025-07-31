import 'package:flutter/material.dart';
import 'dart:async';
import '../../../utils/responsive_helper.dart'; // Asegúrate de importar tu ResponsiveHelper

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Inicializar animaciones
    _animationController = AnimationController(
      duration: ResponsiveHelper.getAnimationDuration(slow: true),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: ResponsiveHelper.getAnimationCurve(),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: ResponsiveHelper.getAnimationCurve(bounce: true),
    ));

    // Iniciar animación
    _animationController.forward();

    // Simula espera o lógica de inicialización
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ResponsiveHelper.centeredContent(
        context,
        AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Icono principal con tamaño responsivo
                    Image.asset(
                      "assets/imgs/logo.png",
                      width: ResponsiveHelper.getIconSize(context, base: 500),
                      height: ResponsiveHelper.getIconSize(context, base: 200),
                    ),

                    // Espaciado responsivo
                    SizedBox(
                      height: ResponsiveHelper.getSpacing(context, base: 20),
                    ),

                    // Texto principal con tamaño responsivo
                    Text(
                      "Cargando...",
                      style: TextStyle(
                        fontSize: ResponsiveHelper.getTitleFontSize(context,
                            base: 20),
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
                      ),
                    ),

                    // Espaciado adicional
                    SizedBox(
                      height: ResponsiveHelper.getSpacing(context, base: 32),
                    ),

                    // Indicador de progreso con tamaño responsivo
                    SizedBox(
                      width: ResponsiveHelper.getResponsiveWidth(context, 40),
                      height: ResponsiveHelper.getResponsiveHeight(context, 40),
                      child: CircularProgressIndicator(
                        strokeWidth:
                            ResponsiveHelper.isMobile(context) ? 3.0 : 4.0,
                        valueColor:
                            const AlwaysStoppedAnimation<Color>(Colors.blue),
                      ),
                    ),

                    // Texto adicional para dispositivos más grandes
                    if (ResponsiveHelper.isTablet(context) ||
                        ResponsiveHelper.isDesktop(context)) ...[
                      SizedBox(
                        height: ResponsiveHelper.getSpacing(context, base: 24),
                      ),
                      Text(
                        "Inicializando aplicación...",
                        style: TextStyle(
                          fontSize: ResponsiveHelper.getBodyFontSize(context,
                              base: 14),
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ],

                    // Logo o información adicional para pantallas grandes
                    if (ResponsiveHelper.isDesktop(context)) ...[
                      SizedBox(
                        height: ResponsiveHelper.getSpacing(context, base: 40),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal:
                              ResponsiveHelper.getHorizontalPadding(context),
                          vertical:
                              ResponsiveHelper.getSpacing(context, base: 16),
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(
                            ResponsiveHelper.getBorderRadius(context, base: 12),
                          ),
                        ),
                        child: Text(
                          "Versión 1.0.0",
                          style: TextStyle(
                            fontSize: ResponsiveHelper.getBodyFontSize(context,
                                base: 12),
                            color: Colors.blue[800],
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
