import 'package:flutter/material.dart';

class MedicalHistoryScreen extends StatelessWidget {
  const MedicalHistoryScreen({super.key});

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
              Color(0xFFFFFFFF), // Blanco
              Color(0xFFE0FFFF), // Azul claro
              Color(0xFF87CEEB), // Azul más fuerte
            ],
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Coloca la imagen (logo) en la parte superior
              Padding(
                padding: const EdgeInsets.only(top: 50), // Ajusta el espacio superior
                child: Center(
                  child: Image.asset(
                    'assets/logo1_copy.png', // Cambia esta ruta si es necesario
                    height: 100, // Ajusta el tamaño del logo
                  ),
                ),
              ),
              const SizedBox(height: 30), // Espacio después del logo
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Sección de Citas Médicas
                    Text(
                      'Citas Médicas',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Divider(),
                    ListTile(
                      title: Text('Cita Médica 1'),
                      subtitle: Text('Fecha: 2024-11-24'),
                    ),
                    ListTile(
                      title: Text('Cita Médica 2'),
                      subtitle: Text('Fecha: 2024-12-01'),
                    ),
                    SizedBox(height: 16),
                    // Sección de Medicamentos
                    Text(
                      'Medicamentos',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Divider(),
                    ListTile(
                      title: Text('Ibuprofeno'),
                      subtitle: Text('Dosis: 200mg - Frecuencia: Cada 8 horas'),
                    ),
                    ListTile(
                      title: Text('Paracetamol'),
                      subtitle: Text('Dosis: 500mg - Frecuencia: Cada 12 horas'),
                    ),
                    SizedBox(height: 16),
                    // Sección de Alimentos
                    Text(
                      'Alimentos',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Divider(),
                    ListTile(
                      title: Text('Dieta 1'),
                      subtitle: Text('Frutas, Verduras, Proteínas'),
                    ),
                    ListTile(
                      title: Text('Dieta 2'),
                      subtitle: Text('Pescado, Granos, Frutas'),
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
