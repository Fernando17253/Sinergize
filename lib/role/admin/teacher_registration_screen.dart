import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sinergize/gradient_background.dart';

class TeacherRegistrationScreen extends StatefulWidget {
  const TeacherRegistrationScreen({super.key});

  @override
  _TeacherRegistrationScreenState createState() =>
      _TeacherRegistrationScreenState();
}

class _TeacherRegistrationScreenState extends State<TeacherRegistrationScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  String? _selectedArea;

  bool _obscurePassword = true;

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  // Recuperar el token de SharedPreferences
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // Recuperar el id_usuario desde SharedPreferences
  Future<String?> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id');
  }

  // Registrar al docente en la base de datos usando la API
  Future<void> _registerTeacher() async {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final correo = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final address = _addressController.text.trim();
    final area = _selectedArea;

    if (name.isEmpty ||
        phone.isEmpty ||
        correo.isEmpty ||
        password.isEmpty ||
        address.isEmpty ||
        area == null) {
      _showMessage('Todos los campos son obligatorios.');
      return;
    }

    // Recuperar el id_usuario desde SharedPreferences
    final userId = await _getUserId();
    if (userId == null) {
      _showMessage('No se pudo recuperar el ID del usuario.');
      return;
    }

    final Map<String, String> body = {
      'id_usuario': userId,
      'nombre': name,
      'correo': correo,
      'password': password,
      'telefono': phone,
      'materia': area,
      'direccion': address,
    };

    try {
      final token = await _getToken();
      if (token == null) {
        _showMessage('Token de autenticación no disponible.');
        return;
      }

      final response = await http.post(
        Uri.parse('http://98.85.2.180:3000/api/v1/docentes/register'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        _showMessage('Maestro registrado con éxito.', isError: false);
        _clearForm();
      } else {
        _showMessage('Maestro registrado con éxito.');
      }
    } catch (error) {
      _showMessage('Error al registrar al maestro: $error');
    }
  }

  // Mostrar mensaje de éxito o error
  void _showMessage(String message, {bool isError = true}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isError ? 'Error' : 'Éxito'),
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

  // Limpiar formulario después de registrar
  void _clearForm() {
    _nameController.clear();
    _phoneController.clear();
    _emailController.clear();
    _passwordController.clear();
    _addressController.clear();
    setState(() {
      _selectedArea = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Llene todos los campos'),
          backgroundColor: const Color.fromARGB(255, 225, 231, 246),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'Registrar Maestro',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre',
                    prefixIcon: Icon(Icons.person),
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
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Correo',
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
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
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: _togglePasswordVisibility,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _addressController,
                  decoration: const InputDecoration(
                    labelText: 'Dirección',
                    prefixIcon: Icon(Icons.location_on),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedArea,
                  items: const [
                    DropdownMenuItem(value: 'Matemáticas', child: Text('Matemáticas')),
                    DropdownMenuItem(value: 'Lingüística', child: Text('Lingüística')),
                    DropdownMenuItem(value: 'Trazo', child: Text('Trazo')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedArea = value;
                    });
                  },
                  decoration: const InputDecoration(
                    labelText: 'Materia',
                    prefixIcon: Icon(Icons.category),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _registerTeacher,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF203F8E),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                    ),
                    child: const Text(
                      'Registrar Maestro',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
