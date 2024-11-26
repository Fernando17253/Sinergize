import 'package:flutter/material.dart';
import 'package:spinkeeper/gradient_background.dart';

class TeacherScreen extends StatelessWidget {
  final int teacherId;

  const TeacherScreen({required this.teacherId, super.key});

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Center(
          child: Text(
            'Bienvenido Maestro (ID: $teacherId)',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
