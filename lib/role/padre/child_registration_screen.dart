import 'package:flutter/material.dart';
import 'package:spinkeeper/server/local_data_store.dart';
import 'package:intl/intl.dart';

class ChildRegistrationScreen extends StatefulWidget {
  final int parentId;

  const ChildRegistrationScreen({required this.parentId, super.key});

  @override
  _ChildRegistrationScreenState createState() => _ChildRegistrationScreenState();
}

class _ChildRegistrationScreenState extends State<ChildRegistrationScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _birthdateController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final LocalDataStore _localDataStore = LocalDataStore();

  Future<void> _selectBirthdate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate!);
    setState(() {
      _birthdateController.text = formattedDate;
    });
    }

  void _registerChild() async {
    final name = _nameController.text;
    final birthdate = _birthdateController.text;
    final address = _addressController.text;

    if (name.isEmpty || birthdate.isEmpty || address.isEmpty) {
      _showMessage('Todos los campos son obligatorios.');
      return;
    }

    await _localDataStore.addChild(widget.parentId, name, birthdate, address);

    _showMessage('Hijo registrado con éxito.', isError: false);
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
        title: const Text('Registrar Hijo'),
        backgroundColor: const Color(0xFF203F8E),
      ),
      body: Padding(
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
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Registrar Hijo', style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
