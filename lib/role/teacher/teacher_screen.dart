import 'package:flutter/material.dart';
import 'package:sinergize/gradient_background.dart';
import 'package:sinergize/role/teacher/assign_activity_screen.dart';
import 'package:sinergize/role/father/group_chat_screen.dart'; // Chat grupal
import 'package:sinergize/role/teacher/settings_screen.dart'; // Ajustes del maestro

class TeacherScreen extends StatefulWidget {
  const TeacherScreen({super.key});

  @override
  _TeacherScreenState createState() => _TeacherScreenState();
}

class _TeacherScreenState extends State<TeacherScreen> {
  int _currentIndex = 0;

  // Lista de vistas del TabBar
  final List<Widget> _pages = [
    const ScheduleActivityScreen(), // Registro de actividades
    const GroupChatScreen(), // Foro o chat grupal
    const SettingsScreen(), // Vista de ajustes
  ];


  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        body: _pages[_currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.assignment),
              label: 'Actividades',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat),
              label: 'Foro',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Ajustes',
            ),
          ],
        ),
      ),
    );
  }
}
