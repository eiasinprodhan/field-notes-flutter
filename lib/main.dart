import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/network/token_storage.dart';
import 'core/network/dio_client.dart';
import 'core/storage/settings_storage.dart';
import 'data/remote/api_client.dart';
import 'data/local/app_database.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/field_repository.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

final prefs = await SharedPreferences.getInstance();
  final settings = SettingsStorage(prefs);
  final tokenStorage = TokenStorage(prefs);
  final dio = createDio(tokenStorage);
  final api = FieldNotesApi(dio);
  final db = AppDatabase.instance;
  final authRepo = AuthRepository(api, tokenStorage);
  final fieldRepo = FieldRepository(db, api, settings);

  runApp(App(
    authRepo: authRepo,
    fieldRepo: fieldRepo,
    settings: settings,
    tokenStorage: tokenStorage,
  ));
}
