import 'package:flutter/material.dart';
import 'package:spinkeeper/server/database_helper.dart';
import 'package:spinkeeper/server/session_manager.dart';
import 'package:spinkeeper/role/navigationbar/parent_tab_bar.dart'; // Barra para padres
import 'package:spinkeeper/role/admin/admin_screen.dart'; // Pantalla admin
import 'package:spinkeeper/role/maestro/teacher_screen.dart'; // Pantalla maestro
import 'package:spinkeeper/gradient_background.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final SessionManager _sessionManager = SessionManager();

  void _register() async {
    final fullName = _fullNameController.text.trim();
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();
    final phone = _phoneController.text.trim();

    if (fullName.isEmpty || username.isEmpty || password.isEmpty || confirmPassword.isEmpty || phone.isEmpty) {
      _showMessage('Por favor, completa todos los campos.');
      return;
    }

    if (password != confirmPassword) {
      _showMessage('Las contraseñas no coinciden.');
      return;
    }

    final existingUser = await _dbHelper.getUserByUsername(username);
    if (existingUser != null) {
      _showMessage('El usuario ya existe.');
      return;
    }

    final user = {
      'fullName': fullName,
      'username': username,
      'password': password,
      'phone': phone,
      'userType': 'parent', // Por defecto, registramos como padre (puedes modificar según el rol)
    };

    final userId = await _dbHelper.insertUser(user);
    if (userId != null) {
      await _sessionManager.saveLastUser(userId, 'parent');
      _navigateToHome(userId, 'parent');
    } else {
      _showMessage('Error al registrar el usuario.');
    }
  }

  void _navigateToHome(int userId, String userType) {
    if (userType == 'admin') {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AdminScreen()));
    } else if (userType == 'parent') {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ParentTabBar(parentId: userId)));
    } else if (userType == 'teacher') {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => TeacherScreen(teacherId: userId)));
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
                    controller: _fullNameController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre completo',
                      prefixIcon: Icon(Icons.person),
                    ),
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
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Teléfono',
                      prefixIcon: Icon(Icons.phone),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Contraseña',
                      prefixIcon: Icon(Icons.lock),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _confirmPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Confirmar contraseña',
                      prefixIcon: Icon(Icons.lock),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF203F8E),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                    ),
                    child: const Text('Registrar', style: TextStyle(fontSize: 16, color: Colors.white)),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context); // Regresar a la pantalla de login
                    },
                    child: const Text(
                      '¿Ya tienes una cuenta? Inicia sesión aquí',
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
