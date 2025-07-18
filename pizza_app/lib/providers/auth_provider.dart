import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthProvider with ChangeNotifier {
  String? _token;
  int? _userId;
  final storage = const FlutterSecureStorage();

  AuthProvider() {
    _loadToken();
  }

  String? get token => _token;
  int? get userId => _userId;
  bool get isAuthenticated => _token != null;

  Future<void> _loadToken() async {
    _token = await storage.read(key: 'auth_token');
    notifyListeners();
  }

  Future<void> setToken(String token, {int? userId}) async {
    _token = token;
    _userId = userId ?? 1; // Valor predeterminado para pruebas
    print('DEBUG: Token establecido, userId: $_userId');
    await storage.write(key: 'auth_token', value: token);
    notifyListeners();
  }

  Future<void> logout() async {
    _token = null;
    _userId = null;
    await storage.delete(key: 'auth_token');
    print('DEBUG: Sesión cerrada');
    notifyListeners();
  }
}