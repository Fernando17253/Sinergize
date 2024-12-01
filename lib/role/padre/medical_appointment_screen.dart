import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Para trabajar con fechas
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class MedicalAppointmentsScreen extends StatefulWidget {
  const MedicalAppointmentsScreen({super.key});

  @override
  _MedicalAppointmentsScreenState createState() => _MedicalAppointmentsScreenState();
}

class _MedicalAppointmentsScreenState extends State<MedicalAppointmentsScreen> {
  late FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;
  List<Map<String, dynamic>> _appointments = [];
  
  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _loadAppointments();
  }

  // Inicializar las notificaciones
  Future<void> _initializeNotifications() async {
    _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    const androidSettings = AndroidInitializationSettings('app_icon');
    const initializationSettings = InitializationSettings(android: androidSettings);
    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  // Simulación de carga de citas médicas
  void _loadAppointments() {
    setState(() {
      _appointments = [
        {
          'id': 1,
          'name': 'Consulta con el Dr. Pérez',
          'date': DateTime.parse('2024-12-30 09:00:00'),
        },
        {
          'id': 2,
          'name': 'Revisión de resultados',
          'date': DateTime.parse('2024-12-31 10:30:00'),
        },
        {
          'id': 3,
          'name': 'Cita con el nutricionista',
          'date': DateTime.parse('2024-12-25 14:00:00'), // Esta ya pasó, no se debe mostrar
        },
      ];
    });
  }

  // Mostrar notificación para la cita médica
  Future<void> _showNotification(DateTime scheduledTime) async {
    const androidDetails = AndroidNotificationDetails(
      'appointments_channel',
      'Medical Appointments',
      importance: Importance.max,
      priority: Priority.high,
    );
    const platformDetails = NotificationDetails(android: androidDetails);

    await _flutterLocalNotificationsPlugin.schedule(
      0,
      '¡Es hora de tu cita médica!',
      'Recuerda tu cita médica: ${_appointments.last['name']}.',
      scheduledTime.subtract(const Duration(minutes: 5)),
      platformDetails,
    );
  }

  // Filtrar las citas pendientes
  List<Map<String, dynamic>> _getUpcomingAppointments() {
    DateTime now = DateTime.now();
    return _appointments.where((appointment) {
      return appointment['date'].isAfter(now); // Mostrar solo las citas futuras
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> upcomingAppointments = _getUpcomingAppointments();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Citas Médicas Pendientes'),
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (upcomingAppointments.isEmpty)
                const Center(
                  child: Text(
                    'No hay citas médicas pendientes.',
                    style: TextStyle(fontSize: 16, color: Colors.red),
                  ),
                ),
              Expanded(
                child: ListView.builder(
                  itemCount: upcomingAppointments.length,
                  itemBuilder: (context, index) {
                    final appointment = upcomingAppointments[index];
                    return ListTile(
                      title: Text(appointment['name']),
                      subtitle: Text(DateFormat('yyyy-MM-dd HH:mm').format(appointment['date'])),
                      trailing: IconButton(
                        icon: const Icon(Icons.notifications, color: Colors.blue),
                        onPressed: () {
                          _showNotification(appointment['date']);
                          _showMessage('Recordatorio configurado para la cita.');
                        },
                      ),
                    );
                  },
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  // Redirigir al registro de citas médicas
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RegisterAppointmentScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF203F8E),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Registrar Nueva Cita'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Mostrar mensaje
  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}

extension on FlutterLocalNotificationsPlugin {
  schedule(int i, String s, String t, DateTime subtract, NotificationDetails platformDetails) {}
}

class RegisterAppointmentScreen extends StatelessWidget {
  const RegisterAppointmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar Cita Médica'),
        backgroundColor: const Color(0xFF203F8E),
      ),
      body: const Center(
        child: Text('Aquí puedes registrar nuevas citas médicas.'),
      ),
    );
  }
}
