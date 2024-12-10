import 'package:flutter/material.dart';
import 'package:spinkeeper/gradient_background.dart';
import 'package:spinkeeper/role/maestro/assign_activity_screen.dart';

class TeacherScreen extends StatelessWidget {
  final int teacherId;

  const TeacherScreen({required this.teacherId, super.key});

  void _navigateToAssignActivity(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AssignActivityScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Datos estáticos por ahora
    const String subjectName = "Matemáticas";
    final List<Map<String, dynamic>> students = [
      {'id': 1, 'name': 'Alumno 1'},
      {'id': 2, 'name': 'Alumno 2'},
      {'id': 3, 'name': 'Alumno 3'},
    ];
    final List<Map<String, String>> activities = [
      {'name': 'Tarea 1', 'description': 'Resolver problemas de álgebra.'},
      {'name': 'Tarea 2', 'description': 'Geometría: calcular áreas y perímetros.'},
    ];

    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Materia: $subjectName'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Alumnos en la materia:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: students.length,
                  itemBuilder: (context, index) {
                    final student = students[index];
                    return ListTile(
                      title: Text(student['name']),
                      leading: const Icon(Icons.person),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Actividades asignadas:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: activities.length,
                  itemBuilder: (context, index) {
                    final activity = activities[index];
                    return ListTile(
                      title: Text(activity['name']!),
                      subtitle: Text(activity['description']!),
                      leading: const Icon(Icons.assignment),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _navigateToAssignActivity(context),
          backgroundColor: const Color(0xFF203F8E),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
