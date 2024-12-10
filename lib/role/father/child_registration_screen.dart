import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ChildRegistrationScreen extends StatefulWidget {
  const ChildRegistrationScreen({super.key});

  @override
  _ChildRegistrationScreenState createState() => _ChildRegistrationScreenState();
}

class _ChildRegistrationScreenState extends State<ChildRegistrationScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _birthdateController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  Future<Map<String, String>> _getAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');
    final authToken = prefs.getString('auth_token');

    if (userId == null || authToken == null) {
      throw Exception('No se encontró el ID de usuario o el token de autenticación.');
    }

    return {'user_id': userId, 'auth_token': authToken};
  }

  Future<void> _selectBirthdate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
      setState(() {
        _birthdateController.text = formattedDate;
      });
    }
  }

  void _registerChild() async {
    final name = _nameController.text.trim();
    final birthdate = _birthdateController.text.trim();
    final address = _addressController.text.trim();

    if (name.isEmpty || birthdate.isEmpty || address.isEmpty) {
      _showMessage('Todos los campos son obligatorios.');
      return;
    }

    try {
      final authData = await _getAuthData();
      final parentId = authData['user_id']!;
      final authToken = authData['auth_token']!;

      final Map<String, dynamic> body = {
        'id_padre': parentId,
        'nombre': name,
        'fecha_nacimiento': birthdate,
        'direccion': address,
      };

      final response = await http.post(
        Uri.parse('http://98.85.2.180:3000/api/v1/hijos/register'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        _showMessage('Hijo registrado con éxito.', isError: false);
        _clearForm();
      } else {
        final responseBody = jsonDecode(response.body);
        _showMessage(
          responseBody['message'] ?? 'Error al registrar al hijo.',
        );
      }
    } catch (error) {
      _showMessage('Error al registrar al hijo: $error');
    }
  }

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

  void _clearForm() {
    _nameController.clear();
    _birthdateController.clear();
    _addressController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFFFFF), // Blanco
              Color(0xFFE0FFFF), // Azul claro
              Color(0xFF87CEEB), // Azul más fuerte
            ],
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 50),
                child: Center(
                  child: Image.asset(
                    'assets/logo1_copy.png', // Asegúrate de tener la imagen en assets
                    height: 100,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre completo',
                        prefixIcon: Icon(Icons.person),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _birthdateController,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'Fecha de nacimiento',
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      onTap: _selectBirthdate,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _addressController,
                      decoration: const InputDecoration(
                        labelText: 'Dirección',
                        prefixIcon: Icon(Icons.location_on),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _registerChild,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF203F8E),
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                      ),
                      child: const Text(
                        'Registrar Hijo',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
