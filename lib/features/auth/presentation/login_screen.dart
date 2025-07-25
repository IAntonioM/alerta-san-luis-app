import 'package:flutter/material.dart';
import '../../../utils/responsive_helper.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: ResponsiveHelper.centeredContent(
          context,
          Column(
            children: [
              // Top section with logo
              Expanded(
                flex: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo
                    Image.asset(
                      'assets/imgs/logo.png',
                      height: ResponsiveHelper.getImageSize(context, base: 120),
                      fit: BoxFit.contain,
                    ),
                    SizedBox(height: ResponsiveHelper.getSpacing(context, base: 40)),
                    // Title
                    Text(
                      'Iniciar Sesión',
                      style: TextStyle(
                        fontSize: ResponsiveHelper.getHeadlineFontSize(context),
                        fontWeight: FontWeight.w300,
                        color: const Color.fromARGB(255, 255, 255, 255),
                        letterSpacing: 0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              // Form section
              Expanded(
                flex: 3,
                child: Column(
                  children: [
                    // Email TextField
                    Container(
                      height: ResponsiveHelper.getTextFieldHeight(context),
                      child: TextField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: TextStyle(
                          fontSize: ResponsiveHelper.getBodyFontSize(context),
                          color: const Color.fromARGB(255, 255, 255, 255),
                        ),
                        decoration: InputDecoration(
                          hintText: 'Correo electrónico',
                          hintStyle: TextStyle(
                            color: const Color.fromARGB(255, 255, 255, 255),
                            fontSize: ResponsiveHelper.getBodyFontSize(context),
                          ),
                          border: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: const Color.fromARGB(255, 255, 255, 255),
                            ),
                          ),
                          focusedBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Color.fromARGB(255, 255, 255, 255),
                              width: 2,
                            ),
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: const Color.fromARGB(255, 255, 255, 255),
                            ),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            vertical: ResponsiveHelper.getSpacing(context, base: 16),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: ResponsiveHelper.getFormFieldSpacing(context)),

                    // Password TextField
                    Container(
                      height: ResponsiveHelper.getTextFieldHeight(context),
                      child: TextField(
                        controller: passwordController,
                        obscureText: true,
                        style: TextStyle(
                          fontSize: ResponsiveHelper.getBodyFontSize(context),
                          color: const Color.fromARGB(255, 255, 255, 255),
                        ),
                        decoration: InputDecoration(
                          hintText: 'Contraseña',
                          hintStyle: TextStyle(
                            color: const Color.fromARGB(255, 255, 255, 255),
                            fontSize: ResponsiveHelper.getBodyFontSize(context),
                          ),
                          border: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: const Color.fromARGB(255, 255, 255, 255),
                            ),
                          ),
                          focusedBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Color.fromARGB(255, 255, 255, 255),
                              width: 2,
                            ),
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: const Color.fromARGB(255, 255, 255, 255),
                            ),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            vertical: ResponsiveHelper.getSpacing(context, base: 16),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: ResponsiveHelper.getFormSpacing(context)),

                    // Login Button
                    SizedBox(
                      width: double.infinity,
                      height: ResponsiveHelper.getButtonHeight(context),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, '/home');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1976D2),
                          foregroundColor: Colors.white,
                          elevation: ResponsiveHelper.getElevation(context),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              ResponsiveHelper.getBorderRadius(context),
                            ),
                          ),
                        ),
                        child: Text(
                          'Ingresar',
                          style: TextStyle(
                            fontSize: ResponsiveHelper.getButtonFontSize(context),
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: ResponsiveHelper.getSpacing(context, base: 24)),

                    // Register Link
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/register');
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          vertical: ResponsiveHelper.getSpacing(context, base: 12),
                          horizontal: ResponsiveHelper.getSpacing(context, base: 16),
                        ),
                      ),
                      child: Text(
                        '¿No tienes cuenta? Regístrate',
                        style: TextStyle(
                          color: const Color.fromARGB(255, 255, 255, 255),
                          fontSize: ResponsiveHelper.getBodyFontSize(context),
                          fontWeight: FontWeight.w400,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Bottom spacing
              SizedBox(height: ResponsiveHelper.getSpacing(context, base: 32)),
            ],
          ),
        ),
      ),
    );
  }
}