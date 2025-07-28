// ignore_for_file: avoid_print

import 'package:boton_panico_app/service/user_storage_service.dart';
import 'package:flutter/material.dart';
import '../../../utils/responsive_helper.dart';
import '../../../service/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkExistingLogin();
  }

  // Verificar si ya hay una sesión activa
  Future<void> _checkExistingLogin() async {
    final isLoggedIn = await AuthService.isUserLoggedIn();
    if (isLoggedIn && mounted) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Por favor ingresa tu correo electrónico';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Por favor ingresa un correo válido';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Por favor ingresa tu contraseña';
    }
    return null;
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await AuthService.loginCitizen(
        context: context,
        usuario: emailController.text.trim(),
        contrasena: passwordController.text,
      );

      if (mounted) {
        if (response.success) {
          // Login exitoso - los datos ya están guardados automáticamente
          Navigator.pushReplacementNamed(context, '/home');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Bienvenido ${response.data?.nombre ?? ''}'),
              backgroundColor: Colors.green,
            ),
          );
          
          // Debug: mostrar datos guardados
          final savedUser = await UserStorageService.getUser();
          print('Usuario guardado: ${savedUser?.nombre}, ID: ${savedUser?.id}');
        } else {
          // Error en login
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.error ?? 'Error en el login'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error de conexión: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: ResponsiveHelper.centeredContent(
          context,
          Form(
            key: _formKey,
            child: Column(
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
                        height:
                            ResponsiveHelper.getImageSize(context, base: 120),
                        fit: BoxFit.contain,
                      ),
                      SizedBox(
                          height:
                              ResponsiveHelper.getSpacing(context, base: 40)),
                      // Title
                      Text(
                        'Iniciar Sesión',
                        style: TextStyle(
                          fontSize:
                              ResponsiveHelper.getHeadlineFontSize(context),
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
                  child: Column(
                    children: [
                      // Email TextField
                      SizedBox(
                        height: ResponsiveHelper.getTextFieldHeight(context),
                        child: TextFormField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          validator: _validateEmail,
                          style: TextStyle(
                            fontSize: ResponsiveHelper.getBodyFontSize(context),
                            color: const Color.fromARGB(255, 255, 255, 255),
                          ),
                          decoration: InputDecoration(
                            hintText: 'Correo electrónico',
                            hintStyle: TextStyle(
                              color: const Color.fromARGB(255, 255, 255, 255),
                              fontSize:
                                  ResponsiveHelper.getBodyFontSize(context),
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
                              vertical: ResponsiveHelper.getSpacing(context,
                                  base: 16),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(
                          height:
                              ResponsiveHelper.getFormFieldSpacing(context)),

                      // Password TextField
                      SizedBox(
                        height: ResponsiveHelper.getTextFieldHeight(context),
                        child: TextFormField(
                          controller: passwordController,
                          obscureText: true,
                          validator: _validatePassword,
                          style: TextStyle(
                            fontSize: ResponsiveHelper.getBodyFontSize(context),
                            color: const Color.fromARGB(255, 255, 255, 255),
                          ),
                          decoration: InputDecoration(
                            hintText: 'Contraseña',
                            hintStyle: TextStyle(
                              color: const Color.fromARGB(255, 255, 255, 255),
                              fontSize:
                                  ResponsiveHelper.getBodyFontSize(context),
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
                              vertical: ResponsiveHelper.getSpacing(context,
                                  base: 16),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(
                          height: ResponsiveHelper.getFormSpacing(context)),

                      // Login Button
                      SizedBox(
                        width: double.infinity,
                        height: ResponsiveHelper.getButtonHeight(context),
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isLoading
                                ? Colors.grey
                                : const Color(0xFF1976D2),
                            foregroundColor: Colors.white,
                            elevation: ResponsiveHelper.getElevation(context),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                ResponsiveHelper.getBorderRadius(context),
                              ),
                            ),
                          ),
                          child: _isLoading
                              ? SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: const CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  'Ingresar',
                                  style: TextStyle(
                                    fontSize:
                                        ResponsiveHelper.getButtonFontSize(
                                            context),
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                        ),
                      ),

                      SizedBox(
                          height:
                              ResponsiveHelper.getSpacing(context, base: 24)),

                      // Register Link
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/register');
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            vertical:
                                ResponsiveHelper.getSpacing(context, base: 12),
                            horizontal:
                                ResponsiveHelper.getSpacing(context, base: 16),
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
                SizedBox(
                    height: ResponsiveHelper.getSpacing(context, base: 32)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}