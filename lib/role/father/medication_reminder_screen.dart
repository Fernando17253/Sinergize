import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class MedicationRegistrationScreen extends StatefulWidget {
  const MedicationRegistrationScreen({super.key});

  @override
  _MedicationRegistrationScreenState createState() =>
      _MedicationRegistrationScreenState();
}

class _MedicationRegistrationScreenState
    extends State<MedicationRegistrationScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _typeController = TextEditingController();
  final TextEditingController _doseController = TextEditingController();
  final TextEditingController _frequencyController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String? _userId;
  String? _token;

  @override
  void initState() {
    super.initState();
    _getAuthData();
  }

  Future<void> _getAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getString('user_id');
      _token = prefs.getString('auth_token');
    });
  }

  Future<void> _registerMedication() async {
    final name = _nameController.text.trim();
    final type = _typeController.text.trim();
    final dose = _doseController.text.trim();
    final frequency = _frequencyController.text.trim();
    final description = _descriptionController.text.trim();

    if (name.isEmpty ||
        type.isEmpty ||
        dose.isEmpty ||
        frequency.isEmpty ||
        description.isEmpty ||
        _userId == null ||
        _token == null) {
      _showMessage('Todos los campos son obligatorios.');
      return;
    }

    final Map<String, dynamic> body = {
      'nombre': name,
      'tipo': type,
      'dosis': dose,
      'frecuencia': frequency,
      'descripcion': description,
      'id_usuario': _userId,
    };

    try {
      final response = await http.post(
        Uri.parse('http://98.85.2.180:3000/api/v1/medicamentos'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: jsonEncode(body),
      );

      print('Estado: ${response.statusCode}');
      print('Respuesta: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        _showMessage('Medicamento registrado con éxito.', isError: false);
        _clearForm();
      } else {
        final responseBody = jsonDecode(response.body);
        _showMessage(
          responseBody['message'] ?? 'Error al registrar el medicamento.',
        );
      }
    } catch (error) {
      _showMessage('Error al registrar el medicamento: $error');
    }
  }

  void _clearForm() {
    _nameController.clear();
    _typeController.clear();
    _doseController.clear();
    _frequencyController.clear();
    _descriptionController.clear();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro de Medicamentos'),
        backgroundColor: const Color(0xFF203F8E),
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
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Registrar Medicamento',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre del medicamento',
                    prefixIcon: Icon(Icons.medical_services),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _typeController,
                  decoration: const InputDecoration(
                    labelText: 'Tipo',
                    prefixIcon: Icon(Icons.category),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _doseController,
                  decoration: const InputDecoration(
                    labelText: 'Dosis',
                    prefixIcon: Icon(Icons.local_pharmacy),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _frequencyController,
                  decoration: const InputDecoration(
                    labelText: 'Frecuencia',
                    prefixIcon: Icon(Icons.timer),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Descripción',
                    prefixIcon: Icon(Icons.description),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _registerMedication,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF203F8E),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      'Registrar Medicamento',
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
