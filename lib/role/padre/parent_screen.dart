import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:spinkeeper/server/local_data_store.dart';
import 'package:spinkeeper/role/padre/child_registration_screen.dart';

class ParentScreen extends StatefulWidget {
  final int parentId;

  const ParentScreen({required this.parentId, super.key});

  @override
  _ParentScreenState createState() => _ParentScreenState();
}

class _ParentScreenState extends State<ParentScreen> {
  final LocalDataStore _localDataStore = LocalDataStore();
  List<Map<String, dynamic>> _children = [];
  List<Map<String, dynamic>> _predictions = [];
  bool _isLoadingChildren = true;
  bool _isLoadingPredictions = true;

  @override
  void initState() {
    super.initState();
    _loadChildren();
    _fetchPredictions();
  }

  // Cargar los hijos desde el almacenamiento local
  Future<void> _loadChildren() async {
    await _localDataStore.loadChildren(widget.parentId);
    setState(() {
      _children = _localDataStore.children;
      _isLoadingChildren = false;
    });
  }

  // Obtener las predicciones desde la API
  Future<void> _fetchPredictions() async {
    const url = 'http://18.118.24.98:8000/predicciones/1';
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _predictions = data.map((item) {
            return {
              'Fecha': item['Fecha'],
              'Tiempo_Estimado': item['Tiempo_Estimado'],
            };
          }).toList();
          _isLoadingPredictions = false;
        });
      } else {
        throw Exception('Error al obtener las predicciones');
      }
    } catch (error) {
      setState(() {
        _isLoadingPredictions = false;
      });
      _showMessage('Error al cargar las predicciones');
    }
  }

  // Mostrar un mensaje de error
  void _showMessage(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mensaje'),
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
      // Fondo con gradiente
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
          child: Column(
            children: [
              // Coloca la imagen en la parte superior
              Padding(
                padding: const EdgeInsets.only(top: 100), // Ajusta el espacio superior
                child: Center(
                  child: Image.asset(
                    'assets/logo1_copy.png',  // Cambia esto con la ruta correcta de tu logo
                    height: 200,           // Ajusta el tamaño del logo
                  ),
                ),
              ),
              const SizedBox(height: 30), // Espacio después del logo
              ElevatedButton(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChildRegistrationScreen(parentId: widget.parentId),
                    ),
                  );
                  _loadChildren(); // Recargar los datos después de registrar un hijo
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF203F8E),
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                ),
                child: const Text('Registrar Hijo', style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
              const SizedBox(height: 20),
              // Mostrar los hijos registrados
              _isLoadingChildren
                  ? const Center(child: CircularProgressIndicator())
                  : _children.isEmpty
                      ? const Center(child: Text('No hay hijos registrados.', style: TextStyle(color: Colors.red, fontSize: 16)))
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _children.length,
                          itemBuilder: (context, index) {
                            final child = _children[index];
                            return ListTile(
                              title: Text(child['name']),
                              subtitle: Text('Fecha de nacimiento: ${child['birthdate']}'),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () async {
                                  await _localDataStore.removeChild(child['id']);
                                  setState(() {}); // Recargar los datos después de eliminar un hijo
                                },
                              ),
                            );
                          },
                        ),
              const SizedBox(height: 20),
              // Mostrar las predicciones
              _isLoadingPredictions
                  ? const Center(child: CircularProgressIndicator())
                  : _predictions.isEmpty
                      ? const Center(child: Text('No hay predicciones disponibles.', style: TextStyle(color: Colors.red, fontSize: 16)))
                      : Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Tiempo Estimado por Día',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 10),
                              // Usamos un GridView para mostrar las predicciones de manera compacta
                              GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 10,
                                  childAspectRatio: 2.5, // Controlar el tamaño de las tarjetas
                                ),
                                itemCount: _predictions.length,
                                itemBuilder: (context, index) {
                                  final prediction = _predictions[index];
                                  final date = prediction['Fecha'];
                                  final estimatedTime = prediction['Tiempo_Estimado'];

                                  return Card(
                                    color: Colors.white,
                                    elevation: 4.0,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            date,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            'Tiempo Estimado: $estimatedTime min',
                                            style: const TextStyle(fontSize: 13, color: Colors.grey),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
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
