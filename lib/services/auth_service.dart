class AuthUser {
  final String name;
  final String email;
  final String password;
  const AuthUser(this.name, this.email, this.password);
}

enum AuthResult { success, noAccount, wrongPassword }

class AuthService {
  static final List<AuthUser> users = [];
  static AuthUser? currentUser;

  static String _norm(String e) => e.trim().toLowerCase();

  // SIMULATED login
  static Future<AuthResult> login(String email, String password) async {
    await Future<void>.delayed(const Duration(seconds: 2));
    final matches = users.where((u) => u.email == _norm(email));
    if (matches.isEmpty) return AuthResult.noAccount;
    if (matches.first.password != password) return AuthResult.wrongPassword;
    currentUser = matches.first;
    return AuthResult.success;
  }

  // SIMULATED register. Returns false if the email already exists.
  static Future<bool> register(String name, String email, String password) async {
    await Future<void>.delayed(const Duration(seconds: 2));
    if (users.any((u) => u.email == _norm(email))) return false;
    users.add(AuthUser(name.trim(), _norm(email), password));
    return true;
  }
}