import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MedicalAppointmentRegistrationScreen extends StatefulWidget {
  const MedicalAppointmentRegistrationScreen({super.key});

  @override
  _MedicalAppointmentRegistrationScreenState createState() =>
      _MedicalAppointmentRegistrationScreenState();
}

class _MedicalAppointmentRegistrationScreenState
  extends State<MedicalAppointmentRegistrationScreen> {
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _observationsController = TextEditingController();
  bool _reminder = false;

  List<Map<String, dynamic>> _children = [];
  List<String> _selectedChildIds = [];
  String userId = '';
  String authToken = '';

  @override
  void initState() {
    super.initState();
    _getUserIdAndFetchChildren();
  }

  Future<void> _getUserIdAndFetchChildren() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString('user_id') ?? '';
    final token = prefs.getString('auth_token') ?? '';

    if (id.isNotEmpty && token.isNotEmpty) {
      setState(() {
        userId = id;
        authToken = token;
      });
      await _fetchChildren();
    } else {
      _showMessage('No se encontró el ID del usuario o el token de autenticación.');
    }
  }

  Future<void> _fetchChildren() async {
    try {
      final url = 'http://98.85.2.180:3000/api/v1/padres/$userId/hijos';
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data is Map<String, dynamic> && data.containsKey('hijos')) {
          setState(() {
            _children = List<Map<String, dynamic>>.from(data['hijos']);
          });
        } else {
          _showMessage('El formato de respuesta no es el esperado.');
        }
      } else {
        _showMessage('Error al cargar los hijos: ${response.statusCode}');
      }
    } catch (error) {
      _showMessage('Error al cargar los hijos: $error');
    }
  }

  Future<void> _showChildSelectionDialog() async {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setDialogState) {
              return Container(
                padding: const EdgeInsets.all(16.0),
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.height * 0.6,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Seleccionar Hijos',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const Divider(),
                    Expanded(
                      child: ListView(
                        children: _children.map((child) {
                          final childId = child['id_hijo'];
                          final childName = child['nombre'] ?? 'Hijo sin nombre';
                          return CheckboxListTile(
                            title: Text(childName),
                            value: _selectedChildIds.contains(childId),
                            onChanged: (isChecked) {
                              setDialogState(() {
                                if (isChecked == true) {
                                  _selectedChildIds.add(childId);
                                } else {
                                  _selectedChildIds.remove(childId);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('Cancelar'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            if (_selectedChildIds.isEmpty) {
                              _showMessage('Debe seleccionar al menos un hijo.');
                            } else {
                              Navigator.pop(context);
                              _registerAppointment();
                            }
                          },
                          child: const Text('Confirmar'),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _registerAppointment() async {
    final date = _dateController.text.trim();
    final time = _timeController.text.trim();
    final observations = _observationsController.text.trim();

    if (date.isEmpty || time.isEmpty || observations.isEmpty) {
      _showMessage('Todos los campos son obligatorios.');
      return;
    }

    final String fechaCita = "${date}T$time";
    final appointments = _selectedChildIds.map((childId) {
      final childName = _children.firstWhere((child) => child['id_hijo'] == childId)['nombre'];
      return {
        'id_hijo': childId,
        'nombre_hijo': childName,
        'fecha_cita': fechaCita,
        'observaciones': observations,
        'recordatorio': _reminder,
      };
    }).toList();

    final prefs = await SharedPreferences.getInstance();
    final appointmentsString = prefs.getString('local_appointments') ?? '[]';
    final List<dynamic> existingAppointments = jsonDecode(appointmentsString);

    existingAppointments.addAll(appointments);
    await prefs.setString('local_appointments', jsonEncode(existingAppointments));

    _showMessage('Cita médica registrada para los hijos seleccionados.', isError: false);
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
    _dateController.clear();
    _timeController.clear();
    _observationsController.clear();
    setState(() {
      _reminder = false;
      _selectedChildIds = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro de Citas Médicas'),
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
              Color(0xFFFFFFFF),
              Color(0xFFE0FFFF),
              Color(0xFF87CEEB),
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Registrar Cita Médica',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _dateController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Fecha de la cita',
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      _dateController.text =
                          DateFormat('yyyy-MM-dd').format(pickedDate);
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _timeController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Hora de la cita',
                  prefixIcon: Icon(Icons.access_time),
                ),
                onTap: () async {
                  TimeOfDay? pickedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (pickedTime != null) {
                    setState(() {
                      _timeController.text =
                          "${pickedTime.hour.toString().padLeft(2, '0')}:${pickedTime.minute.toString().padLeft(2, '0')}:00";
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _observationsController,
                decoration: const InputDecoration(
                  labelText: 'Observaciones',
                  prefixIcon: Icon(Icons.notes),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text(
                    'Recordatorio:',
                    style: TextStyle(fontSize: 16),
                  ),
                  Switch(
                    value: _reminder,
                    onChanged: (value) {
                      setState(() {
                        _reminder = value;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _showChildSelectionDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF203F8E),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Center(
                  child: Text(
                    'Registrar Cita',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
