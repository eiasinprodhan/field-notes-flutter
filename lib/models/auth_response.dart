class AuthResponse {
  final String token;
  final String email;
  final String name;

  AuthResponse({
    required this.token,
    required this.email,
    required this.name,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'] as String? ?? '',
      email: json['email'] as String? ?? '',
      name: json['name'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'token': token,
    'email': email,
    'name': name,
  };
}
