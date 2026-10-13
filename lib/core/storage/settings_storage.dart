import 'package:shared_preferences/shared_preferences.dart';
import '../constants.dart';

class SettingsStorage {
  final SharedPreferences _prefs;

  SettingsStorage(this._prefs);

  String getDefaultNoteStatus() {
    return _prefs.getString(StorageKeys.defaultNoteStatus) ?? 'PENDING';
  }

  Future<void> setDefaultNoteStatus(String status) async {
    await _prefs.setString(StorageKeys.defaultNoteStatus, status);
  }

  String? getLastSyncTime() {
    return _prefs.getString(StorageKeys.lastSyncTimestamp);
  }

  Future<void> setLastSyncTime(String isoString) async {
    await _prefs.setString(StorageKeys.lastSyncTimestamp, isoString);
  }

  Future<void> clearSyncTime() async {
    await _prefs.remove(StorageKeys.lastSyncTimestamp);
  }

  bool hasCompletedOnboarding() {
    return _prefs.getBool(StorageKeys.hasCompletedOnboarding) ?? false;
  }

  Future<void> setCompletedOnboarding(bool completed) async {
    await _prefs.setBool(StorageKeys.hasCompletedOnboarding, completed);
  }

  String getThemeMode() {
    return _prefs.getString(StorageKeys.themeMode) ?? 'system';
  }

  Future<void> setThemeMode(String mode) async {
    await _prefs.setString(StorageKeys.themeMode, mode);
  }
}
