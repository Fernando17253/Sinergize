import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ParentScreen extends StatefulWidget {
  const ParentScreen({super.key});

  @override
  _ParentScreenState createState() => _ParentScreenState();
}

class _ParentScreenState extends State<ParentScreen> {
  final List<Map<String, dynamic>> _predictions = [];
  final List<Map<String, dynamic>> _activities = [];
  bool _isLoadingPredictions = true;

  @override
  void initState() {
    super.initState();
    _fetchPredictions();
    _loadActivities();
  }

  Future<void> _fetchPredictions() async {
    const url = 'http://18.118.24.98:8000/predicciones/1';
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _predictions.addAll(data.map((item) => {
            'Fecha': item['Fecha'],
            'Tiempo_Estimado': item['Tiempo_Estimado'],
          }).toList());
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

  Future<void> _loadActivities() async {
    final prefs = await SharedPreferences.getInstance();
    final activitiesData = prefs.getString('activities');
    if (activitiesData != null) {
      setState(() {
        _activities.addAll(List<Map<String, dynamic>>.from(json.decode(activitiesData)));
      });
    }
  }

  Future<void> _deleteActivity(int index) async {
    final prefs = await SharedPreferences.getInstance();

    // Eliminamos la actividad de la lista local
    setState(() {
      _activities.removeAt(index);
    });

    // Guardamos la lista actualizada en SharedPreferences
    await prefs.setString('activities', jsonEncode(_activities));

    _showMessage('Actividad eliminada correctamente.', isError: false);
  }

  // Método para mostrar mensajes emergentes
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
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 100),
                child: Center(
                  child: Image.asset(
                    'assets/logo1_copy.png',
                    height: 200,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              // Mostrar las actividades registradas
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Actividades',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 10),
              _activities.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        'No hay actividades registradas.',
                        style: TextStyle(color: Colors.red, fontSize: 16),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _activities.length,
                      itemBuilder: (context, index) {
                        final activity = _activities[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: ListTile(
                            title: Text(activity['nombre']),
                            subtitle: Text('Hijo: ${activity['id_hijo']}\n'
                                'Fecha: ${activity['fecha_completado']}'),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Confirmar'),
                                    content: const Text('¿Estás seguro de que deseas eliminar esta actividad?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('Cancelar'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                          _deleteActivity(index);
                                        },
                                        child: const Text('Eliminar'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
              const SizedBox(height: 30),
              // Predicciones Section
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Predicciones',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 10),
              _isLoadingPredictions
                  ? const Center(child: CircularProgressIndicator())
                  : _predictions.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            'No hay predicciones disponibles.',
                            style: TextStyle(color: Colors.red, fontSize: 16),
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Tiempo Estimado por Día de Finalización de Actividades',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 5),
                              GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 10,
                                  childAspectRatio: 2.5,
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
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
