import 'package:flutter/material.dart';
import 'register.dart';
import 'consultaPrincipal.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  String? _errorMessage;

  void _validateAndLogin() {
    setState(() {
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      if (email.isEmpty || password.isEmpty) {
        _errorMessage = 'Por favor complete todos los campos';
      } else if (!email.contains('@') ||
          !email.contains('.') ||
          !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
        _errorMessage = 'Correo electrónico inválido';
      } else if (password.length < 8) {
        _errorMessage = 'La contraseña es invalida';
      } else {
        _errorMessage = null;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ConsultaPrincipal()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(255, 13, 91, 77),
              Color.fromARGB(255, 14, 158, 139),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'LOGIN',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 30),
              _buildTextField('Gmail', controller: _emailController),
              const SizedBox(height: 20),
              _buildTextField(
                'Contraseña',
                controller: _passwordController,
                isPassword: true,
                showToggle: true,
              ),
              const SizedBox(height: 10),
              if (_errorMessage != null)
                Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red, fontSize: 14),
                ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 2, 64, 40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 15,
                  ),
                ),
                onPressed: _validateAndLogin,
                child: const Text(
                  'LOGIN',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "¿No tienes una cuenta?",
                    style: TextStyle(color: Colors.white),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const Register(),
                        ),
                      );
                    },
                    child: const Text(
                      'Regístrate ahora',
                      style: TextStyle(
                        color: Color.fromARGB(255, 112, 163, 205),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String hintText, {
    required TextEditingController controller,
    bool isPassword = false,
    bool showToggle = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword && _obscurePassword,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.white54),
        filled: true,
        fillColor: Colors.white.withOpacity(0.2),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 15,
        ),
        suffixIcon:
            showToggle
                ? IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                )
                : null,
      ),
    );
  }
}
