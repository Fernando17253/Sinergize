import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static const String _userIdKey = 'lastUserId';
  static const String _userTypeKey = 'lastUserType';

  Future<void> saveLastUser(int userId, String userType) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_userIdKey, userId);
    await prefs.setString(_userTypeKey, userType);
  }

Future<Map<String, dynamic>?> getLastUser() async {
  final prefs = await SharedPreferences.getInstance();
  final userId = prefs.getInt(_userIdKey);
  final userType = prefs.getString(_userTypeKey);

  final lastUser = (userId != null && userType != null)
      ? {'id': userId, 'userType': userType}
      : null;

  print('Datos recuperados en SessionManager: $lastUser'); // Aquí

  return lastUser;
}

  Future<void> clearLastUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userIdKey);
    await prefs.remove(_userTypeKey);
  }
}
