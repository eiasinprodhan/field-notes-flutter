import 'package:shared_preferences/shared_preferences.dart';
import '../constants.dart';

class TokenStorage {
  final SharedPreferences _prefs;

  TokenStorage(this._prefs);

  Future<void> saveSession({
    required String token,
    required String email,
    required String name,
  }) async {
    await _prefs.setString(StorageKeys.token, token);
    await _prefs.setString(StorageKeys.userEmail, email);
    await _prefs.setString(StorageKeys.userName, name);
  }

  String? getToken() => _prefs.getString(StorageKeys.token);
  String? getEmail() => _prefs.getString(StorageKeys.userEmail);
  String? getName() => _prefs.getString(StorageKeys.userName);
  bool get hasToken => getToken() != null && getToken()!.isNotEmpty;

  Future<void> updateProfile({required String name}) async {
    await _prefs.setString(StorageKeys.userName, name);
  }

  Future<void> clearSession() async {
    await _prefs.remove(StorageKeys.token);
    await _prefs.remove(StorageKeys.userEmail);
    await _prefs.remove(StorageKeys.userName);
  }
}
