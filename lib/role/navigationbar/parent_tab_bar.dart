import 'package:flutter/material.dart';
import 'package:sinergize/role/father/parent_screen.dart';
import 'package:sinergize/role/father/medical_appointment_screen.dart';
import 'package:sinergize/role/father/group_chat_screen.dart';
import 'package:sinergize/role/father/medical_history_screen.dart';
import 'package:sinergize/role/father/children_list_screen.dart';
import 'package:sinergize/role/teacher/settings_screen.dart';

class ParentTabBar extends StatefulWidget {
  const ParentTabBar({super.key});

  @override
  _ParentTabBarState createState() => _ParentTabBarState();
}

class _ParentTabBarState extends State<ParentTabBar> {
  int _currentIndex = 0;
  String userEmail = ''; // Variable para almacenar el correo

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    // Inicializa las pantallas
    _screens = [
      const ParentScreen(),
      const MedicalAppointmentsScreen(),
      const GroupChatScreen(),
      const MedicalHistoryScreen(),
      const ChildrenListScreen(),
      const SettingsScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_currentIndex != 0) {
          setState(() {
            _currentIndex = 0;
          });
          return false;
        }
        return true;
      },
      child: Scaffold(
        body: _screens[_currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          selectedItemColor: const Color(0xFF203F8E),
          unselectedItemColor: Colors.grey,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.task),
              label: 'Tareas',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today),
              label: 'Citas',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat),
              label: 'Foro',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history),
              label: 'Historial',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.child_care),
              label: 'Hijo(s)',
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
