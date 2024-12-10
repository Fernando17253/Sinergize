import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sinergize/role/father/medication_reminder_screen.dart';
import 'medical_appointment_registration_screen.dart';
import 'food_registration_screen.dart';

class MedicalAppointmentsScreen extends StatefulWidget {
  const MedicalAppointmentsScreen({super.key});

  @override
  _MedicalAppointmentsScreenState createState() =>
      _MedicalAppointmentsScreenState();
}

class _MedicalAppointmentsScreenState extends State<MedicalAppointmentsScreen> {
  late FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;
  String userId = '';
  String token = '';
  int _currentIndex = 0;
  bool _isMenuVisible = false;

  final List<Widget> _screens = [
    const MedicalAppointmentRegistrationScreen(),
    const FoodRegistrationScreen(),
    const MedicationRegistrationScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _loadUserData();
  }

  Future<void> _initializeNotifications() async {
    _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    const androidSettings = AndroidInitializationSettings('app_icon');
    const initializationSettings =
        InitializationSettings(android: androidSettings);
    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('user_id')!;
    token = prefs.getString('auth_token')!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar Navigation (collapsible)
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: _isMenuVisible ? 120 : 0,
            color: const Color(0xFFE0FFFF),
            child: _isMenuVisible
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.calendar_today),
                        color: _currentIndex == 0 ? Colors.blue : Colors.black,
                        onPressed: () {
                          setState(() {
                            _currentIndex = 0;
                            _isMenuVisible = false;
                          });
                        },
                      ),
                      const Text('Citas Médicas'),
                      const SizedBox(height: 16),
                      IconButton(
                        icon: const Icon(Icons.food_bank),
                        color: _currentIndex == 1 ? Colors.blue : Colors.black,
                        onPressed: () {
                          setState(() {
                            _currentIndex = 1;
                            _isMenuVisible = false;
                          });
                        },
                      ),
                      const Text('Comidas'),
                      const SizedBox(height: 16),
                      IconButton(
                        icon: const Icon(Icons.medication),
                        color: _currentIndex == 2 ? Colors.blue : Colors.black,
                        onPressed: () {
                          setState(() {
                            _currentIndex = 2;
                            _isMenuVisible = false;
                          });
                        },
                      ),
                      const Text('Medicamentos'),
                    ],
                  )
                : null,
          ),

          // Main Screen Content
          Expanded(
            child: IndexedStack(
              index: _currentIndex,
              children: _screens,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF203F8E),
        onPressed: () {
          setState(() {
            _isMenuVisible = !_isMenuVisible;
          });
        },
        child: const Icon(Icons.menu, color: Colors.white),
      ),
    );
  }
}
