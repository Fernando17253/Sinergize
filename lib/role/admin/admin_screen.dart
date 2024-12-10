import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sinergize/gradient_background.dart';
import 'package:sinergize/role/loguin/login_screen.dart';
import 'teacher_registration_screen.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  List<Map<String, dynamic>> _teachers = [];
  String token = '';

  @override
  void initState() {
    super.initState();
    _getToken(); // Obtener el token de autenticación
  }

  // Obtener el auth_token desde SharedPreferences
  Future<void> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      token = prefs.getString('auth_token') ?? '';
    });

    if (token.isNotEmpty) {
      // Cargar docentes al obtener el token
      await _loadTeachers();
    } else {
      _showMessage('No se pudo cargar el token de autenticación.');
    }
  }

  // Cargar docentes desde la API utilizando auth_token
  Future<void> _loadTeachers() async {
    try {
      const url = 'http://98.85.2.180:3000/api/v1/docentes';
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // Incluir el token en el encabezado
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _teachers = data.map((teacher) => teacher as Map<String, dynamic>).toList();
        });
      } else {
        _showMessage('Error al cargar los docentes: ${response.statusCode}');
      }
    } catch (error) {
      _showMessage('Error al cargar los docentes: $error');
    }
  }

  // Método para cerrar sesión
  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Limpiar todas las preferencias guardadas
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()), // Redirigir a la pantalla de login
    );
  }

  // Mostrar mensaje emergente
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
        body: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Text(
                    'Docentes Registrados:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadTeachers,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF203F8E),
                      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Cargar Docentes',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView(
                      children: _teachers.isEmpty
                          ? [const Center(child: Text('No hay docentes registrados.'))]
                          : _teachers.map((teacher) {
                              return Card(
                                color: Colors.white,
                                margin: const EdgeInsets.symmetric(vertical: 8.0),
                                child: ListTile(
                                  title: Text('ID: ${teacher['id_docente']}'),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Materia: ${teacher['materia']}'),
                                      Text('Dirección: ${teacher['direccion']}'),
                                    ],
                                  ),
                                  onTap: () {
                                    // Mostrar detalles del docente si es necesario
                                  },
                                ),
                              );
                            }).toList(),
                    ),
                  ),
                ],
              ),
            ),
            // Botón para cerrar sesión
            Positioned(
              top: 16,
              left: 16,
              child: FloatingActionButton(
                mini: true,
                onPressed: () => _logout(context),
                backgroundColor: Colors.red,
                child: const Icon(Icons.exit_to_app),
              ),
            ),
            // Botón para registrar docentes
            Positioned(
              bottom: 16,
              right: 16,
              child: FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const TeacherRegistrationScreen()),
                  );
                },
                backgroundColor: const Color(0xFF203F8E),
                child: const Icon(Icons.add, size: 30),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
