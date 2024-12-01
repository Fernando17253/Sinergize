import 'package:flutter/material.dart';

class AssignActivityScreen extends StatefulWidget {
  const AssignActivityScreen({super.key});

  @override
  _AssignActivityScreenState createState() => _AssignActivityScreenState();
}

class _AssignActivityScreenState extends State<AssignActivityScreen> {
  final TextEditingController _activityNameController = TextEditingController();
  final TextEditingController _instructionsController = TextEditingController();
  final TextEditingController _multimediaController = TextEditingController();

  final List<Map<String, dynamic>> students = [
    {'id': 1, 'name': 'Alumno 1', 'selected': false},
    {'id': 2, 'name': 'Alumno 2', 'selected': false},
    {'id': 3, 'name': 'Alumno 3', 'selected': false},
  ];

  void _saveActivity() {
    final String activityName = _activityNameController.text.trim();
    final String instructions = _instructionsController.text.trim();
    final String multimedia = _multimediaController.text.trim();

    if (activityName.isEmpty || instructions.isEmpty) {
      _showMessage('Por favor, completa todos los campos obligatorios.');
      return;
    }

    final selectedStudents = students.where((student) => student['selected']).toList();

    if (selectedStudents.isEmpty) {
      _showMessage('Selecciona al menos un alumno para asignar la actividad.');
      return;
    }

    // Aquí se puede realizar el POST a la API para registrar la actividad
    _showMessage('Actividad asignada con éxito.', isError: false);
    Navigator.pop(context);
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
        title: const Text('Registrar Actividad'),
        backgroundColor: const Color(0xFF203F8E),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _activityNameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre de la Actividad',
                  prefixIcon: Icon(Icons.title),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _instructionsController,
                decoration: const InputDecoration(
                  labelText: 'Instrucciones',
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _multimediaController,
                decoration: const InputDecoration(
                  labelText: 'Enlace Multimedia (Opcional)',
                  prefixIcon: Icon(Icons.link),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Seleccionar Alumnos:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: students.length,
                itemBuilder: (context, index) {
                  final student = students[index];
                  return CheckboxListTile(
                    title: Text(student['name']),
                    value: student['selected'],
                    onChanged: (bool? value) {
                      setState(() {
                        student['selected'] = value!;
                      });
                    },
                  );
                },
              ),
              const SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  onPressed: _saveActivity,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF203F8E),
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                  ),
                  child: const Text('Guardar Actividad', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
