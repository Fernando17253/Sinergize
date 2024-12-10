import 'package:flutter/material.dart';
import 'package:spinkeeper/server/database_helper.dart';
import 'package:spinkeeper/role/iniciosesion/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Asegúrate de inicializar Flutter
  final dbHelper = DatabaseHelper();
  await dbHelper.checkAndRegisterAdmin(); // Verifica y registra el admin si es necesario
  runApp(const MyApp());
}

extension on DatabaseHelper {
  checkAndRegisterAdmin() {}
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Spinkeeper 9no',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const LoginScreen(), // Cambiado para mostrar la pantalla de inicio de sesión
    );
  }
}
