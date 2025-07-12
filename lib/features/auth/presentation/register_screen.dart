import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final fullNameController = TextEditingController();
  final phoneController = TextEditingController();
  final dniController = TextEditingController();
  final emailController = TextEditingController();
  final addressController = TextEditingController();

  bool acceptedTerms = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/imgs/background-login.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.0),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  // Top section with logo and back button
                  Expanded(
                    flex: 1,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Back button and logo row
                        Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              icon: const Icon(
                                Icons.arrow_back,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            Expanded(
                              child: Center(
                                child: Image.asset(
                                  'assets/imgs/logo.png',
                                  height: 80,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                            const SizedBox(width: 48), // Balance the back button
                          ],
                        ),
                        const SizedBox(height: 20),
                        // Title
                        const Text(
                          'Registro',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w300,
                            color: Color.fromARGB(255, 255, 255, 255),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Form section
                  Expanded(
                    flex: 4,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          // Nombres completos
                          TextField(
                            controller: fullNameController,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Color.fromARGB(255, 255, 255, 255),
                            ),
                            decoration: InputDecoration(
                              hintText: 'Nombres completos',
                              hintStyle: TextStyle(
                                color: const Color.fromARGB(255, 255, 255, 255),
                                fontSize: 16,
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
                              contentPadding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Teléfono
                          TextField(
                            controller: phoneController,
                            keyboardType: TextInputType.phone,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Color.fromARGB(255, 255, 255, 255),
                            ),
                            decoration: InputDecoration(
                              hintText: 'Teléfono',
                              hintStyle: TextStyle(
                                color: const Color.fromARGB(255, 255, 255, 255),
                                fontSize: 16,
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
                              contentPadding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // DNI o C.E.
                          TextField(
                            controller: dniController,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Color.fromARGB(255, 255, 255, 255),
                            ),
                            decoration: InputDecoration(
                              hintText: 'DNI o C.E.',
                              hintStyle: TextStyle(
                                color: const Color.fromARGB(255, 255, 255, 255),
                                fontSize: 16,
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
                              contentPadding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Correo electrónico
                          TextField(
                            controller: emailController,
                            keyboardType: TextInputType.emailAddress,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Color.fromARGB(255, 255, 255, 255),
                            ),
                            decoration: InputDecoration(
                              hintText: 'Correo electrónico',
                              hintStyle: TextStyle(
                                color: const Color.fromARGB(255, 255, 255, 255),
                                fontSize: 16,
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
                              contentPadding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Dirección
                          TextField(
                            controller: addressController,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Color.fromARGB(255, 255, 255, 255),
                            ),
                            decoration: InputDecoration(
                              hintText: 'Dirección',
                              hintStyle: TextStyle(
                                color: const Color.fromARGB(255, 255, 255, 255),
                                fontSize: 16,
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
                              contentPadding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),

                          const SizedBox(height: 32),

                          // Checkbox de términos
                          CheckboxListTile(
                            value: acceptedTerms,
                            onChanged: (value) {
                              setState(() => acceptedTerms = value ?? false);
                            },
                            title: const Text(
                              'Estoy de acuerdo con los Términos y Servicios',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                            checkColor: Colors.white,
                            activeColor: const Color(0xFF1976D2),
                            contentPadding: EdgeInsets.zero,
                          ),

                          const SizedBox(height: 32),

                          // Botón Registrarse
                          SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: ElevatedButton(
                              onPressed: acceptedTerms
                                  ? () {
                                      // Lógica de registro aquí
                                      Navigator.pop(context);
                                    }
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: acceptedTerms 
                                    ? const Color(0xFF1976D2) 
                                    : Colors.grey,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'Registrarse',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Enlace a Login
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text(
                              '¿Ya tienes cuenta? Iniciar Sesión',
                              style: TextStyle(
                                color: const Color.fromARGB(255, 255, 255, 255),
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}