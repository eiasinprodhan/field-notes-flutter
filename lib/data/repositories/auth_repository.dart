import '../../models/auth_response.dart';
import '../remote/api_client.dart';
import '../../core/network/token_storage.dart';

class AuthRepository {
  final FieldNotesApi _api;
  final TokenStorage _tokenStorage;

  AuthRepository(this._api, this._tokenStorage);

  bool get isLoggedIn => _tokenStorage.hasToken;
  String? get currentEmail => _tokenStorage.getEmail();
  String? get currentName => _tokenStorage.getName();

  Future<AuthResponse> login(String email, String password) async {
    final response = await _api.login(email.trim(), password);
    await _tokenStorage.saveSession(
      token: response.token,
      email: response.email,
      name: response.name,
    );
    return response;
  }

  Future<AuthResponse> register(String email, String password, String name) async {
    final response = await _api.register(email.trim(), password, name.trim());
    await _tokenStorage.saveSession(
      token: response.token,
      email: response.email,
      name: response.name,
    );
    return response;
  }

  Future<void> logout() async {
    await _tokenStorage.clearSession();
  }
}
