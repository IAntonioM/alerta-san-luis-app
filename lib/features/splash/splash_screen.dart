import 'package:flutter/material.dart';
import 'dart:async';
import '../../utils/responsive_helper.dart';

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
  bool _hasStartedTimer = false;

  @override
  void initState() {
    super.initState();

    // Solo inicializar animaciones aquí
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

    _animationController.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_hasStartedTimer) {
      _hasStartedTimer = true;

      final splashDuration = ResponsiveHelper.responsiveValue(
        context,
        mobile: const Duration(seconds: 3),
        tablet: const Duration(seconds: 2),
        desktop: const Duration(seconds: 2),
      );

      Timer(splashDuration, () {
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/login');
        }
      });
    }
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
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: ResponsiveHelper.responsiveValue(
          context,
          mobile: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF099AD7), Color(0xFF1976D2)],
            ),
          ),
          tablet: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF099AD7), Color(0xFF1976D2)],
            ),
          ),
          desktop: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.center,
              colors: [Color(0xFF099AD7), Color(0xFF1976D2)],
            ),
          ),
        ),
        child: SafeArea(
          child: ResponsiveHelper.centeredContent(
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
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Logo principal con tamaño responsivo
                        Container(
                          padding: EdgeInsets.all(
                            ResponsiveHelper.getSpacing(context, base: 16),
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(
                              ResponsiveHelper.getBorderRadius(context,
                                  base: 20),
                            ),
                          ),
                          child: Image.asset(
                            "assets/imgs/logo.png",
                            width: ResponsiveHelper.responsiveValue(
                              context,
                              mobile: ResponsiveHelper.getScreenWidth(context) *
                                  0.6,
                              tablet: 400.0,
                              desktop: 500.0,
                            ),
                            height: ResponsiveHelper.responsiveValue(
                              context,
                              mobile: ResponsiveHelper.getScreenWidth(context) *
                                  0.24,
                              tablet: 160.0,
                              desktop: 200.0,
                            ),
                            fit: BoxFit.contain,
                          ),
                        ),

                        // Espaciado responsivo
                        SizedBox(
                          height:
                              ResponsiveHelper.getSpacing(context, base: 32),
                        ),

                        // Texto principal con tamaño responsivo
                        Text(
                          ResponsiveHelper.responsiveValue(
                            context,
                            mobile: "Cargando...",
                            tablet: "Inicializando aplicación...",
                            desktop: "Preparando la aplicación...",
                          ),
                          style: TextStyle(
                            fontSize: ResponsiveHelper.getTitleFontSize(
                              context,
                              base: ResponsiveHelper.responsiveValue(
                                context,
                                mobile: 20,
                                tablet: 24,
                                desktop: 28,
                              ),
                            ),
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: ResponsiveHelper.responsiveValue(
                              context,
                              mobile: 0.5,
                              tablet: 1.0,
                              desktop: 1.2,
                            ),
                          ),
                          textAlign: TextAlign.center,
                        ),

                        // Texto secundario para tablets y desktop
                        if (ResponsiveHelper.isTablet(context) ||
                            ResponsiveHelper.isDesktop(context)) ...[
                          SizedBox(
                            height:
                                ResponsiveHelper.getSpacing(context, base: 12),
                          ),
                          Text(
                            "Sistema de Alertas Ciudadanas",
                            style: TextStyle(
                              fontSize: ResponsiveHelper.getBodyFontSize(
                                context,
                                base: 16,
                              ),
                              color: Colors.white.withOpacity(0.8),
                              fontWeight: FontWeight.w300,
                              letterSpacing: 0.8,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],

                        // Espaciado adicional
                        SizedBox(
                          height:
                              ResponsiveHelper.getSpacing(context, base: 40),
                        ),

                        // Indicador de progreso con tamaño responsivo
                        Container(
                          padding: EdgeInsets.all(
                            ResponsiveHelper.getSpacing(context, base: 20),
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(
                              ResponsiveHelper.getBorderRadius(context,
                                  base: 50),
                            ),
                          ),
                          child: SizedBox(
                            width: ResponsiveHelper.getResponsiveWidth(
                              context,
                              ResponsiveHelper.responsiveValue(
                                context,
                                mobile: 40,
                                tablet: 50,
                                desktop: 60,
                              ),
                            ),
                            height: ResponsiveHelper.getResponsiveHeight(
                              context,
                              ResponsiveHelper.responsiveValue(
                                context,
                                mobile: 40,
                                tablet: 50,
                                desktop: 60,
                              ),
                            ),
                            child: CircularProgressIndicator(
                              strokeWidth: ResponsiveHelper.responsiveValue(
                                context,
                                mobile: 3.0,
                                tablet: 4.0,
                                desktop: 5.0,
                              ),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                              backgroundColor: Colors.white.withOpacity(0.3),
                            ),
                          ),
                        ),

                        // Información adicional para dispositivos más grandes
                        if (ResponsiveHelper.isDesktop(context)) ...[
                          SizedBox(
                            height:
                                ResponsiveHelper.getSpacing(context, base: 48),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: ResponsiveHelper.getHorizontalPadding(
                                  context),
                              vertical: ResponsiveHelper.getSpacing(context,
                                  base: 16),
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(
                                ResponsiveHelper.getBorderRadius(context,
                                    base: 12),
                              ),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: Colors.white.withOpacity(0.8),
                                  size: ResponsiveHelper.getIconSize(context,
                                      base: 16),
                                ),
                                SizedBox(
                                  width: ResponsiveHelper.getSpacing(context,
                                      base: 8),
                                ),
                                Text(
                                  "Versión 1.0.0 - Desarrollado para la comunidad",
                                  style: TextStyle(
                                    fontSize: ResponsiveHelper.getBodyFontSize(
                                      context,
                                      base: 12,
                                    ),
                                    color: Colors.white.withOpacity(0.8),
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        // Logos adicionales para tablets
                        if (ResponsiveHelper.isTablet(context)) ...[
                          SizedBox(
                            height:
                                ResponsiveHelper.getSpacing(context, base: 32),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/imgs/muni_logo.png',
                                height: ResponsiveHelper.getIconSize(context,
                                    base: 40),
                                color: Colors.white.withOpacity(0.8),
                              ),
                              SizedBox(
                                width: ResponsiveHelper.getSpacing(context,
                                    base: 24),
                              ),
                              Container(
                                width: 1,
                                height: ResponsiveHelper.getIconSize(context,
                                    base: 40),
                                color: Colors.white.withOpacity(0.3),
                              ),
                              SizedBox(
                                width: ResponsiveHelper.getSpacing(context,
                                    base: 24),
                              ),
                              Text(
                                "Municipalidad",
                                style: TextStyle(
                                  fontSize: ResponsiveHelper.getBodyFontSize(
                                    context,
                                    base: 14,
                                  ),
                                  color: Colors.white.withOpacity(0.8),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
