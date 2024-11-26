import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'user_database.db');
    return openDatabase(
      path,
      version: 5, // Incrementa la versión si haces cambios en la estructura
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Crear tabla de usuarios
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL,
        password TEXT NOT NULL,
        userType TEXT NOT NULL,
        fullName TEXT NOT NULL,
        phone TEXT NOT NULL
      )
    ''');

    // Crear tabla de maestros
    await db.execute('''
      CREATE TABLE teachers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        phone TEXT NOT NULL,
        email TEXT NOT NULL,
        address TEXT NOT NULL,
        area TEXT NOT NULL
      )
    ''');

    // Crear tabla de hijos
    await db.execute('''
      CREATE TABLE children (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        parentId INTEGER NOT NULL,
        name TEXT NOT NULL,
        birthdate TEXT NOT NULL,
        FOREIGN KEY (parentId) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 5) {
      // Crear tabla de hijos si no existe
      await db.execute('''
        CREATE TABLE IF NOT EXISTS children (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          parentId INTEGER NOT NULL,
          name TEXT NOT NULL,
          birthdate TEXT NOT NULL,
          FOREIGN KEY (parentId) REFERENCES users(id) ON DELETE CASCADE
        )
      ''');
    }
  }

  // ---------------- Usuarios ----------------

  Future<int> registerUserWithDetails(String username, String password, String userType, String fullName, String phone) async {
    final db = await database;
    return await db.insert('users', {
      'username': username,
      'password': password,
      'userType': userType,
      'fullName': fullName,
      'phone': phone,
    });
  }

  Future<Map<String, dynamic>?> loginUser(String username, String password) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<void> checkAndRegisterAdmin() async {
    final db = await database;

    final adminExists = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: ['admin'],
    );
    if (adminExists.isEmpty) {
      await registerUserWithDetails(
        'admin',
        'admin123',
        'admin',
        'Admin Default',
        '1234567890',
      );
    }
  }

  Future<List<Map<String, dynamic>>> getParents() async {
    final db = await database;
    return await db.query(
      'users',
      where: 'userType = ?',
      whereArgs: ['parent'],
    );
  }

  Future<int> deleteParent(int id) async {
    final db = await database;
    return await db.delete(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ---------------- Maestros ----------------

  Future<int> registerTeacherWithDetails(String name, String phone, String email, String address, String area) async {
    final db = await database;
    return await db.insert('teachers', {
      'name': name,
      'phone': phone,
      'email': email,
      'address': address,
      'area': area,
    });
  }

  Future<List<Map<String, dynamic>>> getTeachers() async {
    final db = await database;
    return await db.query('teachers');
  }

  Future<int> updateTeacher(int id, String name, String phone, String email, String address, String area) async {
    final db = await database;
    return await db.update(
      'teachers',
      {
        'name': name,
        'phone': phone,
        'email': email,
        'address': address,
        'area': area,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteTeacher(int id) async {
    final db = await database;
    return await db.delete(
      'teachers',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ---------------- Hijos ----------------

  Future<int> registerChild(int parentId, String name, String birthdate, String address) async {
    final db = await database;
    return await db.insert('children', {
      'parentId': parentId,
      'name': name,
      'birthdate': birthdate,
    });
  }

  Future<List<Map<String, dynamic>>> getChildrenByParentId(int parentId) async {
    final db = await database;
    return await db.query(
      'children',
      where: 'parentId = ?',
      whereArgs: [parentId],
    );
  }

  Future<int> deleteChild(int id) async {
    final db = await database;
    return await db.delete(
      'children',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
