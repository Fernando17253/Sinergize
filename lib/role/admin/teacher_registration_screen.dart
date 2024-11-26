import 'package:flutter/material.dart';
import 'package:spinkeeper/server/database_helper.dart';

class TeacherRegistrationScreen extends StatefulWidget {
  const TeacherRegistrationScreen({super.key});

  @override
  _TeacherRegistrationScreenState createState() => _TeacherRegistrationScreenState();
}

class _TeacherRegistrationScreenState extends State<TeacherRegistrationScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  String? _selectedArea; // Área seleccionada
  final DatabaseHelper _dbHelper = DatabaseHelper();

  void _registerTeacher() async {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final email = _emailController.text.trim();
    final address = _addressController.text.trim();
    final area = _selectedArea;

    // Validaciones
    if (name.isEmpty || phone.isEmpty || email.isEmpty || address.isEmpty || area == null) {
      _showMessage('Todos los campos son obligatorios.');
      return;
    }

    // Asignar el nombre como contraseña
    final password = name; // Nombre del maestro como contraseña

    // Registrar al maestro en la base de datos
    await _dbHelper.registerUserWithDetails(email, password, 'teacher', name, phone);

    // Registrar detalles adicionales en la tabla de maestros
    await _dbHelper.registerTeacherWithDetails(name, phone, email, address, area);

    // Mostrar mensaje de éxito
    _showMessage('Maestro registrado con éxito.', isError: false);

    // Limpiar los campos del formulario
    _nameController.clear();
    _phoneController.clear();
    _emailController.clear();
    _addressController.clear();
    setState(() {
      _selectedArea = null;
    });
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
        title: const Text('Registro de Maestros'),
        backgroundColor: const Color(0xFF203F8E), // Azul
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
                  DropdownMenuItem(value: 'Linguística', child: Text('Linguística')),
                  DropdownMenuItem(value: 'Trazos', child: Text('Trazos')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedArea = value;
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Área',
                  prefixIcon: Icon(Icons.category),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _registerTeacher,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF203F8E), // Azul
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                ),
                child: const Center(
                  child: Text(
                    'Registrar Maestro',
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
