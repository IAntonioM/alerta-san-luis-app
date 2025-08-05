import 'package:flutter/material.dart';
import '../../utils/responsive_helper.dart';
import '../../service/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _dniController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();

  bool _acceptedTerms = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _dniController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes aceptar los términos y servicios'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await AuthService.registerCitizen(
        context: context,
        correo: _emailController.text.trim(),
        telefono: _phoneController.text.trim(),
        nombre: _fullNameController.text.trim(),
        direccion: _addressController.text.trim(),
        numDoc: _dniController.text.trim(),
        contrasena: _passwordController.text.trim(),
      );

      if (mounted) {
        if (response.success) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Registro exitoso. Bienvenido ${response.data?.nombre ?? ''}'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.error ?? 'Error en el registro'),
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

  // Estilo común para los campos de texto
  InputDecoration _getInputDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(
        color: Colors.white70,
        fontSize: ResponsiveHelper.getFontSize(context, 16),
      ),
      border: const UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.white70),
      ),
      focusedBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.white, width: 2),
      ),
      enabledBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.white70),
      ),
      contentPadding: EdgeInsets.symmetric(
        vertical: ResponsiveHelper.getSpacing(context, base: 16),
      ),
    );
  }

  // Estilo común para el texto de los campos
  TextStyle _getTextFieldStyle() {
    return TextStyle(
      fontSize: ResponsiveHelper.getFontSize(context, 16),
      color: Colors.white,
    );
  }

  // Widget para crear un campo de texto personalizado
  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    bool obscureText = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: _getTextFieldStyle(),
      decoration: _getInputDecoration(hintText),
      validator: validator,
      obscureText: obscureText,
    );
  }

  // Validadores
  String? _validateFullName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Por favor ingresa tu nombre completo';
    }
    if (value.trim().length < 2) {
      return 'El nombre debe tener al menos 2 caracteres';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Por favor ingresa tu teléfono';
    }
    if (value.trim().length < 9) {
      return 'El teléfono debe tener al menos 9 dígitos';
    }
    return null;
  }

  String? _validateDNI(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Por favor ingresa tu DNI o C.E.';
    }
    if (value.trim().length < 8) {
      return 'El DNI debe tener al menos 8 caracteres';
    }
    return null;
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

  String? _validateAddress(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Por favor ingresa tu dirección';
    }
    if (value.trim().length < 10) {
      return 'Por favor ingresa una dirección más específica';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Por favor ingresa tu contraseña';
    }
    if (value.trim().length < 6) {
      return 'Por favor ingresa una contraseña más específica';
    }
    return null;
  }

  String? _validatePasswordConfirm(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Por favor confirma tu contraseña';
    }
    if (value != _passwordController.text.trim()) {
      return 'Las contraseñas no son iguales';
    }
    return null;
  }

  List<Widget> _buildFormFields() {
    final spacing = ResponsiveHelper.getSpacing(context, base: 20);

    return [
      _buildTextField(
        controller: _fullNameController,
        hintText: 'Nombres completos',
        validator: _validateFullName,
      ),
      SizedBox(height: spacing),

      _buildTextField(
        controller: _phoneController,
        hintText: 'Teléfono',
        keyboardType: TextInputType.phone,
        validator: _validatePhone,
      ),
      SizedBox(height: spacing),

      _buildTextField(
        controller: _dniController,
        hintText: 'DNI o C.E.',
        validator: _validateDNI,
      ),
      SizedBox(height: spacing),

      _buildTextField(
        controller: _emailController,
        hintText: 'Correo electrónico',
        keyboardType: TextInputType.emailAddress,
        validator: _validateEmail,
      ),
      SizedBox(height: spacing),

      _buildTextField(
        controller: _addressController,
        hintText: 'Dirección',
        validator: _validateAddress,
      ),

      SizedBox(height: spacing),

      _buildTextField(
        controller: _passwordController,
        hintText: 'Contraseña',
        validator: _validatePassword,
        obscureText: true,
      ),

      SizedBox(height: spacing),

      _buildTextField(
        controller: _passwordConfirmController,
        hintText: 'Confirmar Contraseña',
        validator: _validatePasswordConfirm,
        obscureText: true,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: ResponsiveHelper.centeredContent(
          context,
          Column(
            children: [
              // Header con logo y botón de retroceso
              _buildHeader(),

              // Formulario
              Expanded(
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Campos del formulario
                        ..._buildFormFields(),

                        SizedBox(
                          height: ResponsiveHelper.getSpacing(context, base: 32),
                        ),

                        // Checkbox de términos
                        _buildTermsCheckbox(),

                        SizedBox(
                          height: ResponsiveHelper.getSpacing(context, base: 32),
                        ),

                        // Botón de registro
                        _buildRegisterButton(),

                        SizedBox(
                          height: ResponsiveHelper.getSpacing(context, base: 24),
                        ),

                        // Enlace a login
                        _buildLoginLink(),

                        SizedBox(
                          height: ResponsiveHelper.getSpacing(context, base: 32),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Fila con botón de retroceso y logo
        Row(
          children: [
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: ResponsiveHelper.getIconSize(context),
              ),
            ),
            Expanded(
              child: Center(
                child: Image.asset(
                  'assets/imgs/logo.png',
                  height: ResponsiveHelper.getResponsiveSize(context, 100),
                  fit: BoxFit.contain,
                ),
              ),
            ),
            SizedBox(
              width: ResponsiveHelper.getIconSize(context) + 16,
            ), // Balance
          ],
        ),

        SizedBox(height: ResponsiveHelper.getSpacing(context, base: 8)),

        // Título
        Text(
          'Registro',
          style: TextStyle(
            fontSize: ResponsiveHelper.getFontSize(context, 28),
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildTermsCheckbox() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(
          ResponsiveHelper.getBorderRadius(context),
        ),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveHelper.getSpacing(context, base: 8),
      ),
      child: CheckboxListTile(
        value: _acceptedTerms,
        onChanged: (value) {
          setState(() => _acceptedTerms = value ?? false);
        },
        title: Text(
          'Estoy de acuerdo con los Términos y Servicios',
          style: TextStyle(
            color: Colors.white,
            fontSize: ResponsiveHelper.getFontSize(context, 14),
          ),
        ),
        checkColor: Colors.white,
        activeColor: const Color(0xFF1976D2),
        contentPadding: EdgeInsets.zero,
        controlAffinity: ListTileControlAffinity.leading,
      ),
    );
  }

  Widget _buildRegisterButton() {
    return SizedBox(
      width: double.infinity,
      height: ResponsiveHelper.getButtonHeight(context),
      child: ElevatedButton(
        onPressed: (_acceptedTerms && !_isLoading) ? _handleRegister : null,
        style: ElevatedButton.styleFrom(
          backgroundColor:
          _acceptedTerms ? const Color(0xFF1976D2) : Colors.grey,
          foregroundColor: Colors.white,
          elevation: ResponsiveHelper.responsiveValue<double>(
            context,
            mobile: 4.0,
            tablet: 6.0,
            desktop: 8.0,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              ResponsiveHelper.getBorderRadius(context),
            ),
          ),
        ),
        child: _isLoading
            ? SizedBox(
          height: ResponsiveHelper.getResponsiveSize(context, 20),
          width: ResponsiveHelper.getResponsiveSize(context, 20),
          child: const CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 2,
          ),
        )
            : Text(
          'Registrarse',
          style: TextStyle(
            fontSize: ResponsiveHelper.getFontSize(context, 16),
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildLoginLink() {
    return TextButton(
      onPressed: () => Navigator.pop(context),
      child: Text(
        '¿Ya tienes cuenta? Iniciar Sesión',
        style: TextStyle(
          color: Colors.white70,
          fontSize: ResponsiveHelper.getFontSize(context, 14),
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}