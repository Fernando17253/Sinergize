import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sinergize/role/admin/admin_screen.dart';
import 'package:sinergize/role/teacher/teacher_screen.dart';
import 'package:sinergize/role/navigationbar/parent_tab_bar.dart';
import 'package:sinergize/role/loguin/parent_registration_screen.dart';
import 'package:sinergize/gradient_background.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final LocalAuthentication _auth = LocalAuthentication();

  bool _obscurePassword = true;

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  Future<void> _saveToken(String token, String username, String password, String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    await prefs.setString('user_email', username);
    await prefs.setString('user_password', password);
    await prefs.setString('user_id', userId);
  }

  Future<void> _loadLastSession() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('user_email');
    final password = prefs.getString('user_password');

    if (username != null && password != null) {
      _authenticateWithBiometrics();
    }
  }

  void _login() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      _showMessage('Por favor, ingresa tu correo y contraseña.');
      return;
    }

    final Map<String, String> body = {
      'correo': username,
      'password': password,
    };

    try {
      final response = await http.post(
        Uri.parse('http://98.85.2.180:3000/api/v1/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);

        if (responseBody.containsKey('userType')) {
          final userType = responseBody['userType'];
          final token = responseBody['token'];
          final userId = responseBody['id_usuario'];

          if (userType == null || token == null || userId == null) {
            _showMessage('Datos incompletos recibidos del servidor.');
            return;
          }

          await _saveToken(token, username, password, userId);
          _navigateToHome(userType);
        } else {
          _showMessage('La respuesta del servidor no contiene los datos esperados.');
        }
      } else {
        final responseBody = jsonDecode(response.body);
        _showMessage(responseBody['message'] ?? 'Error al iniciar sesión.');
      }
    } catch (error) {
      _showMessage('Ocurrió un error: $error');
    }
  }

  void _navigateToHome(String userType) {
    switch (userType) {
      case 'Administrador':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AdminScreen()),
        );
        break;
      case 'Padre':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ParentTabBar()),
        );
        break;
      case 'Docente':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const TeacherScreen()),
        );
        break;
      default:
        _showMessage('Tipo de usuario no reconocido: $userType');
    }
  }

void _authenticateWithBiometrics() async {
  try {
    final isAvailable = await _auth.canCheckBiometrics;

    if (!isAvailable) {
      _showMessage('La autenticación biométrica no está disponible.');
      return;
    }

    final authenticated = await _auth.authenticate(
      localizedReason: 'Usa tu huella digital para iniciar sesión',
      options: const AuthenticationOptions(biometricOnly: true),
    );

    if (authenticated) {
      final prefs = await SharedPreferences.getInstance();
      final username = prefs.getString('user_email');
      final password = prefs.getString('user_password');

      if (username != null && password != null) {
        _loginWithBiometrics(username, password);
      } else {
        _showMessage('No hay datos guardados para iniciar sesión.');
      }
    } else {
      _showMessage('Autenticación fallida.');
    }
  } catch (e) {
    _showMessage('Error al usar la autenticación biométrica: $e');
  }
}

void _loginWithBiometrics(String username, String password) async {
  final Map<String, String> body = {
    'correo': username,
    'password': password,
  };

  try {
    final response = await http.post(
      Uri.parse('http://98.85.2.180:3000/api/v1/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);

      if (responseBody.containsKey('userType')) {
        final userType = responseBody['userType'];
        final token = responseBody['token'];
        final userId = responseBody['id_usuario'];

        if (userType == null || token == null || userId == null) {
          _showMessage('Datos incompletos recibidos del servidor.');
          return;
        }

        await _saveToken(token, username, password, userId);
        _navigateToHome(userType);
      } else {
        _showMessage('Error: No se encontraron datos válidos.');
      }
    } else {
      final responseBody = jsonDecode(response.body);
      _showMessage(responseBody['message'] ?? 'Error al realizar la solicitud con la huella.');
    }
  } catch (error) {
    _showMessage('Error al intentar iniciar sesión: $error');
  }
}

  void _loginWithSavedCredentials(String username, String password) async {
    final Map<String, String> body = {
      'correo': username,
      'password': password,
    };

    try {
      final response = await http.post(
        Uri.parse('http://98.85.2.180:3000/api/v1/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);

        if (responseBody.containsKey('userType')) {
          final userType = responseBody['userType'];
          _navigateToHome(userType);
        } else {
          _showMessage('Error: No se encontraron datos válidos.');
        }
      } else {
        _showMessage('Error al realizar la solicitud con la huella.');
      }
    } catch (error) {
      _showMessage('Ocurrió un error al intentar iniciar sesión: $error');
    }
  }

  void _showMessage(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Información'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadLastSession();
  }

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: SingleChildScrollView(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16.0),
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.0),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Image.asset(
                    'assets/logo1.png',
                    height: 100,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      labelText: 'Correo',
                      prefixIcon: Icon(Icons.email),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Contraseña',
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off : Icons.visibility,
                        ),
                        onPressed: _togglePasswordVisibility,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    child: ElevatedButton(
                    onPressed: _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF203F8E),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15),
                      ),
                      child: const Text(
                        'Iniciar sesión',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _authenticateWithBiometrics,
                    icon: const Icon(Icons.fingerprint),
                    label: const Text('Iniciar sesión con huella'),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const RegisterScreen()),
                      );
                    },
                    child: const Text('Crear una cuenta'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
