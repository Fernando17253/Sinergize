import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ScheduleActivityScreen extends StatefulWidget {
  const ScheduleActivityScreen({super.key});

  @override
  _ScheduleActivityScreenState createState() => _ScheduleActivityScreenState();
}

class _ScheduleActivityScreenState extends State<ScheduleActivityScreen> {
  List<dynamic> parents = [];
  String? selectedChildId;
  String? selectedParentId;
  final TextEditingController _activityTitleController = TextEditingController();
  final TextEditingController _activityDescriptionController = TextEditingController();
  DateTime? _selectedDate;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchParentsAndChildren();
  }

  Future<String?> _getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token'); // Recuperar el token almacenado localmente
  }

  Future<void> _fetchParentsAndChildren() async {
    final token = await _getAuthToken();
    if (token == null) {
      _showMessage('Error: No se encontró el token de autenticación.');
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('http://98.85.2.180:3000/api/v1/actividades/padreshijos'),
        headers: {
          'Authorization': 'Bearer $token', // Incluir el token en el encabezado
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          parents = json.decode(response.body);
          _isLoading = false;
        });
      } else {
        _showMessage('Error al obtener los datos de los padres e hijos. Código: ${response.statusCode}');
      }
    } catch (error) {
      _showMessage('Error al cargar datos: $error');
    }
  }

  void _pickDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (selected != null) {
      setState(() {
        _selectedDate = selected;
      });
    }
  }

  Future<void> _saveActivityLocally() async {
    if (selectedParentId == null || selectedChildId == null) {
      _showMessage('Por favor, selecciona un padre y un hijo.');
      return;
    }
    if (_activityTitleController.text.trim().isEmpty ||
        _activityDescriptionController.text.trim().isEmpty ||
        _selectedDate == null) {
      _showMessage('Por favor, completa todos los campos.');
      return;
    }

    final newActivity = {
      'id_hijo': selectedChildId,
      'id_padre': selectedParentId,
      'nombre': _activityTitleController.text.trim(),
      'descripcion': _activityDescriptionController.text.trim(),
      'fecha_completado': _selectedDate!.toIso8601String(),
    };

    final prefs = await SharedPreferences.getInstance();
    final activitiesData = prefs.getString('activities');
    List<dynamic> activities = [];
    if (activitiesData != null) {
      activities = jsonDecode(activitiesData);
    }
    activities.add(newActivity);

    await prefs.setString('activities', jsonEncode(activities));
    _showMessage('Actividad guardada localmente.', isError: false);
    _clearForm();
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
    _activityTitleController.clear();
    _activityDescriptionController.clear();
    _selectedDate = null;
    setState(() {
      selectedChildId = null;
      selectedParentId = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agendar Actividad'),
        backgroundColor: const Color(0xFF203F8E),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Selecciona un Padre'),
                    items: parents.map<DropdownMenuItem<String>>((parent) {
                      // Verificamos que el id_padre no sea nulo
                      if (parent['id_padre'] != null && parent['nombre_padre'] != null) {
                        return DropdownMenuItem<String>(
                          value: parent['id_padre'] as String, // Convertimos a String
                          child: Text(parent['nombre_padre'] as String),
                        );
                      }
                      return const DropdownMenuItem<String>(
                        value: null,
                        child: Text('Datos inválidos'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedParentId = value;
                        selectedChildId = null; // Reiniciar selección de hijo al cambiar el padre
                      });
                    },
                    value: selectedParentId,
                  ),
                  const SizedBox(height: 16),
                  if (selectedParentId != null)
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Selecciona un Hijo'),
                      items: parents
                          .firstWhere((parent) => parent['id_padre'] == selectedParentId)['hijos']
                          .where((child) => child['id_hijo'] != null && child['nombre_hijo'] != null)
                          .map<DropdownMenuItem<String>>((child) {
                        return DropdownMenuItem<String>(
                          value: child['id_hijo'] as String, // Convertimos a String
                          child: Text(child['nombre_hijo'] as String),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedChildId = value;
                        });
                      },
                      value: selectedChildId,
                    ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _activityTitleController,
                    decoration: const InputDecoration(labelText: 'Título de la Actividad'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _activityDescriptionController,
                    decoration: const InputDecoration(labelText: 'Descripción de la Actividad'),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _selectedDate == null
                              ? 'Selecciona una fecha'
                              : 'Fecha: ${_selectedDate!.toLocal()}'.split(' ')[0],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: _pickDate,
                        child: const Text('Seleccionar Fecha'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _saveActivityLocally,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF203F8E),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Center(
                      child: Text(
                        'Guardar Actividad Localmente',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
