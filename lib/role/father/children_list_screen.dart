import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sinergize/role/father/child_registration_screen.dart';
import 'package:intl/intl.dart';

class ChildrenListScreen extends StatefulWidget {
  const ChildrenListScreen({super.key});

  @override
  _ChildrenListScreenState createState() => _ChildrenListScreenState();
}

class _ChildrenListScreenState extends State<ChildrenListScreen> {
  List<Map<String, dynamic>> children = [];
  String userId = '';
  String authToken = '';

  @override
  void initState() {
    super.initState();
    _getUserIdAndFetchChildren();
  }

  String _formatDate(String? isoDate) {
    if (isoDate == null || isoDate.isEmpty) return 'Desconocida';
    try {
      final date = DateTime.parse(isoDate);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (e) {
      return 'Formato inválido';
    }
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
          final List<Map<String, dynamic>> fetchedChildren =
              List<Map<String, dynamic>>.from(data['hijos']);

          setState(() {
            children = fetchedChildren;
          });

          // Guardar localmente en SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('children_list', jsonEncode(fetchedChildren));
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

  void _showMessage(String message, {bool isError = true}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isError ? 'Error' : 'Información'),
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
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 50),
              child: Center(
                child: Image.asset(
                  'assets/logo1_copy.png',
                  height: 150,
                ),
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'Hijos Registrados',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF203F8E),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: children.isEmpty
                  ? const Center(
                      child: Text(
                        'No hay hijos registrados.',
                        style: TextStyle(fontSize: 16, color: Colors.red),
                      ),
                    )
                  : ListView.builder(
                      itemCount: children.length,
                      itemBuilder: (context, index) {
                        final child = children[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: ListTile(
                            title: Text(child['nombre'] ?? 'Sin nombre'),
                            subtitle: Text(
                              'Fecha de nacimiento: ${_formatDate(child['fecha_nacimiento'])}\nDirección: ${child['direccion'] ?? 'Sin dirección'}',
                            ),
                            leading: const Icon(Icons.child_care, color: Color(0xFF203F8E)),
                          ),
                        );
                      },
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ChildRegistrationScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF203F8E),
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text(
                  'Registrar Nuevo Hijo',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
