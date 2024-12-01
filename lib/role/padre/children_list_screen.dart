import 'package:flutter/material.dart';

class ChildrenListScreen extends StatelessWidget {
  const ChildrenListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Datos estáticos de ejemplo
    final List<Map<String, String>> children = [
      {'name': 'Juan Pérez', 'birthdate': '2012-05-16'},
      {'name': 'María López', 'birthdate': '2015-11-23'},
      {'name': 'Carlos Martínez', 'birthdate': '2018-03-12'},
    ];

    return Scaffold(
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
        child: Column(
          children: [
            // Logo en la parte superior
            Padding(
              padding: const EdgeInsets.only(top: 50),
              child: Center(
                child: Image.asset(
                  'assets/logo1_copy.png', // Ruta del logo
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
            // Lista de hijos
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
                            title: Text(child['name']!),
                            subtitle: Text('Fecha de nacimiento: ${child['birthdate']}'),
                            leading: const Icon(Icons.child_care, color: Color(0xFF203F8E)),
                            trailing: IconButton(
                              icon: const Icon(Icons.info, color: Colors.grey),
                              onPressed: () {
                                // Acción para más información (opcional)
                              },
                            ),
                          ),
                        );
                      },
                    ),
            ),
            // Botón para registrar hijos
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  // Navegar a la pantalla de registro de hijos
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

// Vista de ejemplo para registrar hijos
class ChildRegistrationScreen extends StatelessWidget {
  const ChildRegistrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar Hijo'),
        backgroundColor: const Color(0xFF203F8E),
      ),
      body: const Center(
        child: Text(
          'Formulario de registro de hijos',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
