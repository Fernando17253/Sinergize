import 'package:spinkeeper/server/database_helper.dart';

class LocalDataStore {
  static final LocalDataStore _instance = LocalDataStore._internal();
  factory LocalDataStore() => _instance;
  LocalDataStore._internal();

  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> _children = []; // Datos de hijos en memoria

  // Obtener la lista de hijos
  List<Map<String, dynamic>> get children => _children;

  // Cargar datos desde la base de datos
  Future<void> loadChildren(int parentId) async {
    _children = await _dbHelper.getChildrenByParentId(parentId);
  }

  // Agregar un hijo y actualizar la base de datos
  Future<void> addChild(int parentId, String name, String birthdate, String address) async {
    final id = await _dbHelper.registerChild(parentId, name, birthdate, address);
    _children.add({
      'id': id,
      'parentId': parentId,
      'name': name,
      'birthdate': birthdate,
      'address': address,
    });
  }

  // Eliminar un hijo de memoria y base de datos
  Future<void> removeChild(int childId) async {
    await _dbHelper.deleteChild(childId);
    _children.removeWhere((child) => child['id'] == childId);
  }
}
