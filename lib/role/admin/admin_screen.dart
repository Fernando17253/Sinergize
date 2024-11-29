import 'package:flutter/material.dart';
import 'package:spinkeeper/gradient_background.dart';
import 'package:spinkeeper/role/admin/teacher_registration_screen.dart';
import 'package:spinkeeper/server/database_helper.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> _teachers = [];
  List<Map<String, dynamic>> _parents = [];

  @override
  void initState() {
    super.initState();
    _loadTeachers();
    _loadParents();
  }

  Future<void> _loadTeachers() async {
    final teachers = await _dbHelper.getTeachers();
    setState(() {
      _teachers = teachers;
    });
  }

  Future<void> _loadParents() async {
    final parents = await _dbHelper.getParents();
    setState(() {
      _parents = parents;
    });
  }

  Future<void> _deleteTeacher(int id) async {
    await _dbHelper.deleteTeacher(id);
    _loadTeachers();
  }

  Future<void> _deleteParent(int id) async {
    await _dbHelper.deleteParent(id);
    _loadParents();
  }

  void _confirmDelete(String type, int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Eliminar $type'),
        content: Text('¿Estás seguro de que deseas eliminar este $type? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: Color.fromARGB(255, 18, 18, 18))),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (type == 'Maestro') {
                _deleteTeacher(id);
              } else if (type == 'Padre') {
                _deleteParent(id);
              }
            },
            child: const Text('Eliminar', style: TextStyle(color: Color.fromARGB(255, 228, 56, 43))),
          ),
        ],
      ),
    );
  }

  // Mostrar diálogo con detalles del usuario
  void _showDetailsDialog(String title, Map<String, dynamic> details, List<String> fields) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: fields.map((field) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Text(
                  '$field: ${details[field]}',
                  style: const TextStyle(fontSize: 16),
                ),
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar', style: TextStyle(color: Color(0xFF203F8E))),
          ),
        ],
      ),
    );
  }

  void _showTeacherDetails(Map<String, dynamic> teacher) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Detalles del Maestro'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Nombre: ${teacher['name']}'),
          Text('Correo: ${teacher['email']}'),
          Text('Teléfono: ${teacher['phone']}'),
          Text('Dirección: ${teacher['address']}'),
          Text('Área: ${teacher['area']}'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cerrar'),
        ),
      ],
    ),
  );
}

void _showParentDetails(Map<String, dynamic> parent) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Detalles del Padre'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Nombre: ${parent['fullName']}'),
          Text('Correo: ${parent['username']}'),
          Text('Teléfono: ${parent['phone']}'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cerrar'),
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
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const TeacherRegistrationScreen()),
                  ).then((_) {
                    _loadTeachers();
                    _loadParents();
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF203F8E),
                  padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Registrar Maestro',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  children: [
                    const Text(
                      'Maestros Registrados',
                      style: TextStyle(
                        color: Color.fromARGB(255, 15, 15, 15),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (_teachers.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'No hay ningún maestro registrado.',
                          style: TextStyle(color: Colors.red, fontSize: 16),
                        ),
                      )
                    else
                      ..._teachers.map((teacher) {
                        return Card(
                          color: Colors.white,
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          child: ListTile(
                            title: Text(
                              teacher['name'],
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text('Área: ${teacher['area']}'),
                            onTap: () => _showTeacherDetails(teacher),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _confirmDelete('Maestro', teacher['id']),
                            ),
                            isThreeLine: true,
                          ),
                        );
                      }),
                    const SizedBox(height: 16),
                    const Text(
                      'Padres Registrados',
                      style: TextStyle(
                        color: Color.fromARGB(255, 15, 15, 15),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (_parents.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'No hay ningún usuario padre registrado.',
                          style: TextStyle(color: Colors.red, fontSize: 16),
                        ),
                      )
                    else
                      ..._parents.map((parent) {
                        return Card(
                          color: Colors.white,
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          child: ListTile(
                            title: Text(
                              parent['fullName'],
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text('Teléfono: ${parent['phone']}'),
                            onTap: () => _showParentDetails(parent),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _confirmDelete('Padre', parent['id']),
                            ),
                          ),
                        );
                      }),
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
