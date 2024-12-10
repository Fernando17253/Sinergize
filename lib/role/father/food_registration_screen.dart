import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class FoodRegistrationScreen extends StatefulWidget {
  const FoodRegistrationScreen({super.key});

  @override
  _FoodRegistrationScreenState createState() =>
      _FoodRegistrationScreenState();
}

class _FoodRegistrationScreenState extends State<FoodRegistrationScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _scheduleController = TextEditingController();

  Future<void> _registerFood() async {
    final name = _nameController.text.trim();
    final category = _categoryController.text.trim();
    final schedule = _scheduleController.text.trim();

    if (name.isEmpty || category.isEmpty || schedule.isEmpty) {
      _showMessage('Todos los campos son obligatorios.');
      return;
    }

    final food = {
      'nombre': name,
      'categoria': category,
      'horario': schedule,
    };

    final prefs = await SharedPreferences.getInstance();
    final foodListString = prefs.getString('local_foods') ?? '[]';
    final List<dynamic> foodList = jsonDecode(foodListString);

    foodList.add(food);
    await prefs.setString('local_foods', jsonEncode(foodList));

    _showMessage('Alimento registrado localmente.', isError: false);
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
    _nameController.clear();
    _categoryController.clear();
    _scheduleController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro de Alimentos'),
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
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Registrar Alimento',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  prefixIcon: Icon(Icons.fastfood),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _categoryController,
                decoration: const InputDecoration(
                  labelText: 'Categoría',
                  prefixIcon: Icon(Icons.category),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _scheduleController,
                decoration: const InputDecoration(
                  labelText: 'Horario',
                  prefixIcon: Icon(Icons.access_time),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _registerFood,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF203F8E),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Center(
                  child: Text(
                    'Registrar Alimento',
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
