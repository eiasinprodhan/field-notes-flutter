class ApiConstants {
  static const String baseUrl = 'http://127.0.0.1:8080';
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
}

class StorageKeys {
  static const String token = 'fn_auth_token';
  static const String userEmail = 'fn_user_email';
  static const String userName = 'fn_user_name';
  static const String defaultNoteStatus = 'fn_default_note_status';
  static const String lastSyncTimestamp = 'fn_last_sync_timestamp';
  static const String apiBaseUrl = 'fn_api_base_url';
  static const String hasCompletedOnboarding = 'fn_has_completed_onboarding';
  static const String themeMode = 'fn_theme_mode';
}
