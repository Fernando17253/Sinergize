import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class MedicalHistoryScreen extends StatefulWidget {
  const MedicalHistoryScreen({super.key});

  @override
  _MedicalHistoryScreenState createState() => _MedicalHistoryScreenState();
}

class _MedicalHistoryScreenState extends State<MedicalHistoryScreen> {
  List<Map<String, dynamic>> _appointments = [];
  List<Map<String, dynamic>> _foods = [];
  final Set<int> _selectedAppointments = {}; // Índices de citas seleccionadas

  @override
  void initState() {
    super.initState();
    _loadLocalData();
  }

  Future<void> _loadLocalData() async {
    final prefs = await SharedPreferences.getInstance();

    // Load appointments
    final appointmentsString = prefs.getString('local_appointments') ?? '[]';
    final List<Map<String, dynamic>> appointments =
        List<Map<String, dynamic>>.from(jsonDecode(appointmentsString));

    // Load foods
    final foodsString = prefs.getString('local_foods') ?? '[]';
    final List<Map<String, dynamic>> foods =
        List<Map<String, dynamic>>.from(jsonDecode(foodsString));

    setState(() {
      _appointments = appointments;
      _foods = foods;
    });
  }

  Future<void> _deleteSelectedAppointments() async {
    if (_selectedAppointments.isEmpty) {
      _showMessage('No hay citas seleccionadas para eliminar.');
      return;
    }

    final confirmed = await _showConfirmationDialog();
    if (!confirmed!) return;

    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _appointments = _appointments
          .asMap()
          .entries
          .where((entry) => !_selectedAppointments.contains(entry.key))
          .map((entry) => entry.value)
          .toList();
      _selectedAppointments.clear();
    });
    await prefs.setString('local_appointments', jsonEncode(_appointments));
    _showMessage('Citas médicas eliminadas.');
  }

  Future<bool?> _showConfirmationDialog() async {
    return showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Confirmar Eliminación'),
            content: const Text(
                '¿Está seguro de que desea eliminar las citas seleccionadas?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Eliminar'),
              ),
            ],
          ),
        );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial Médico'),
        backgroundColor: const Color(0xFF203F8E),
        actions: [
          if (_selectedAppointments.isNotEmpty)
            IconButton(
              icon: const Icon(
                Icons.delete,
                color: Colors.red, // Cambia el color del ícono a rojo
              ),
            onPressed: _deleteSelectedAppointments,
          ),
        ],
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
                'Citas Médicas',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Divider(),
              if (_appointments.isEmpty)
                const Center(child: Text('No hay citas médicas registradas.'))
              else
                Column(
                  children: _appointments.asMap().entries.map((entry) {
                    final index = entry.key;
                    final appointment = entry.value;
                    final nombreHijo =
                        appointment['nombre_hijo'] ?? 'Hijo desconocido';
                    final fechaCita =
                        appointment['fecha_cita'] ?? 'Sin fecha registrada';
                    final observaciones =
                        appointment['observaciones'] ?? 'Sin observaciones';

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: CheckboxListTile(
                        title: Text('Hijo: $nombreHijo'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Fecha: $fechaCita'),
                            Text('Observaciones: $observaciones'),
                            if (appointment['recordatorio'] == true)
                              const Text(
                                'Recordatorio Activado',
                                style: TextStyle(fontStyle: FontStyle.italic),
                              ),
                          ],
                        ),
                        value: _selectedAppointments.contains(index),
                        onChanged: (isChecked) {
                          setState(() {
                            if (isChecked == true) {
                              _selectedAppointments.add(index);
                            } else {
                              _selectedAppointments.remove(index);
                            }
                          });
                        },
                      ),
                    );
                  }).toList(),
                ),
              const SizedBox(height: 16),
              const Text(
                'Alimentos',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Divider(),
              if (_foods.isEmpty)
                const Center(child: Text('No hay alimentos registrados.'))
              else
                Column(
                  children: _foods.map((food) {
                    final nombre = food['nombre'] ?? 'Sin nombre';
                    final categoria = food['categoria'] ?? 'N/A';
                    final horario = food['horario'] ?? 'N/A';

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        title: Text('Alimento: $nombre'),
                        subtitle:
                            Text('Categoría: $categoria - Horario: $horario'),
                      ),
                    );
                  }).toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
