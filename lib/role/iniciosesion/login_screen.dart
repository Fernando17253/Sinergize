import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:spinkeeper/role/admin/admin_screen.dart';
import 'package:spinkeeper/role/maestro/teacher_screen.dart';
import 'package:spinkeeper/role/navigationbar/parent_tab_bar.dart'; // Nueva barra para padres
import 'package:spinkeeper/server/database_helper.dart';
import 'package:spinkeeper/server/session_manager.dart';
import 'package:spinkeeper/gradient_background.dart';
import 'package:spinkeeper/role/iniciosesion/parent_registration_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final LocalAuthentication _auth = LocalAuthentication();
  final SessionManager _sessionManager = SessionManager();

  @override
  void initState() {
    super.initState();
  }

  void _login() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      _showMessage('Por favor, ingresa usuario y contraseña.');
      return;
    }

    final user = await _dbHelper.loginUser(username, password);
    if (user != null) {
      await _sessionManager.saveLastUser(user['id'], user['userType']);
      _navigateToHome(user);
    } else {
      _showMessage('Credenciales incorrectas.');
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
        final lastUser = await _sessionManager.getLastUser();
        if (lastUser != null) {
          _navigateToHome(lastUser);
        } else {
          _showMessage('No hay datos de una sesión previa.');
        }
      } else {
        _showMessage('Autenticación fallida.');
      }
    } catch (e) {
      _showMessage('Error al usar la autenticación biométrica: $e');
    }
  }

  void _navigateToHome(Map<String, dynamic> user) {
    final userType = user['userType'];
    final userId = user['id'];

    if (userType == 'admin') {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminScreen()));
    } else if (userType == 'parent') {
      Navigator.push(context, MaterialPageRoute(builder: (context) => ParentTabBar(parentId: userId)));
    } else if (userType == 'teacher') {
      Navigator.push(context, MaterialPageRoute(builder: (context) => TeacherScreen(teacherId: userId)));
    } else {
      _showMessage('Tipo de usuario no reconocido.');
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
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.lock),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF203F8E),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                    ),
                    child: const Text('Sign in', style: TextStyle(fontSize: 16, color: Colors.white)),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _authenticateWithBiometrics,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      side: const BorderSide(color: Color(0xFF203F8E)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                    ),
                    icon: const Icon(Icons.fingerprint, color: Color(0xFF203F8E)),
                    label: const Text('Iniciar sesión con Huella', style: TextStyle(color: Color(0xFF203F8E))),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const RegisterScreen()),
                      );
                    },
                    child: const Text(
                      "Don't have an account? Register here",
                      style: TextStyle(color: Color(0xFF203F8E)),
                    ),
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
