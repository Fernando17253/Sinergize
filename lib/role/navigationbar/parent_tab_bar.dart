import 'package:flutter/material.dart';
import 'package:spinkeeper/role/padre/parent_screen.dart';
import 'package:spinkeeper/role/padre/medical_appointment_screen.dart';
import 'package:spinkeeper/role/padre/group_chat_screen.dart';
import 'package:spinkeeper/role/padre/medical_history_screen.dart';
import 'package:spinkeeper/role/padre/children_list_screen.dart'; // Importar la nueva pantalla

class ParentTabBar extends StatefulWidget {
  final int parentId;

  const ParentTabBar({required this.parentId, super.key});

  @override
  _ParentTabBarState createState() => _ParentTabBarState();
}

class _ParentTabBarState extends State<ParentTabBar> {
  int _currentIndex = 0;

  final List<Widget> _screens = [];

  @override
  void initState() {
    super.initState();
    // Agrega las pantallas respectivas a la lista en initState
    _screens.addAll([
      ParentScreen(parentId: widget.parentId),
      const MedicalAppointmentsScreen(),
      const GroupChatScreen(),
      const MedicalHistoryScreen(),
      const ChildrenListScreen(), // Agregamos la nueva pantalla aquí
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Historial',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.child_care),
            label: 'Hijos', // Nuevo ítem para la lista de hijos
          ),
        ],
      ),
    );
  }
}
