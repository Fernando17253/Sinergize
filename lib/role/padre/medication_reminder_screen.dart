import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';

class MedicationReminderScreen extends StatefulWidget {
  const MedicationReminderScreen({super.key});

  @override
  _MedicationReminderScreenState createState() =>
      _MedicationReminderScreenState();
}

class _MedicationReminderScreenState extends State<MedicationReminderScreen> {
  final TextEditingController _medicationController = TextEditingController();
  final TextEditingController _doseController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  late FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    const androidSettings = AndroidInitializationSettings('app_icon');
    final initializationSettings = InitializationSettings(android: androidSettings);

    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _showNotification(DateTime scheduledTime) async {
    const androidDetails = AndroidNotificationDetails(
      'medication_channel',
      'Medication Reminders',
      importance: Importance.max,
      priority: Priority.high,
    );
    const platformDetails = NotificationDetails(android: androidDetails);

    await _flutterLocalNotificationsPlugin.schedule(
      0,
      '¡Es hora de tomar tu medicamento!',
      'Recuerda tomar el medicamento: ${_medicationController.text} de ${_doseController.text} dosis.',
      scheduledTime.subtract(const Duration(minutes: 5)),
      platformDetails,
    );
  }

  void _setReminder() {
    final medication = _medicationController.text.trim();
    final dose = _doseController.text.trim();
    final time = _timeController.text.trim();

    if (medication.isEmpty || dose.isEmpty || time.isEmpty) {
      _showMessage('Por favor, complete todos los campos');
      return;
    }

    try {
      final dateTime = DateFormat('yyyy-MM-dd HH:mm').parse(time);
      _showNotification(dateTime);
      _showMessage('Recordatorio para tomar $medication registrado correctamente');
    } catch (e) {
      _showMessage('Error con el formato de hora');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar Medicamento'),
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
              TextField(
                controller: _medicationController,
                decoration: const InputDecoration(labelText: 'Tipo de Medicamento'),
              ),
              TextField(
                controller: _doseController,
                decoration: const InputDecoration(labelText: 'Dosis'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _timeController,
                decoration: const InputDecoration(labelText: 'Hora de Toma (YYYY-MM-DD HH:mm)'),
                keyboardType: TextInputType.datetime,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _setReminder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF203F8E),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Registrar Recordatorio'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

extension on FlutterLocalNotificationsPlugin {
  schedule(int i, String s, String t, DateTime subtract, NotificationDetails platformDetails) {}
}
