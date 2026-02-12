import 'package:hive/hive.dart';
import 'package:local_auth/local_auth.dart';

class AuthRepository {
  AuthRepository(this.box);

  final Box box;

  bool hasAccount() {
    return box.get("username") != null;
  }

  bool biometricsEnabled() {
    return box.get("biometrics", defaultValue: false) as bool;
  }

  bool login(String username, String password) {
    return username.trim() == box.get("username") &&
        password.trim() == box.get("password");
  }

  Future<void> signup(String username, String password) async {
    await box.put("username", username.trim());
    await box.put("password", password.trim());
  }

  Future<Map<String, String>?> authenticateWithBiometrics() async {
    final LocalAuthentication auth = LocalAuthentication();

    final bool didAuthenticate = await auth.authenticate(
      localizedReason: 'Please authenticate Biometrics',
      biometricOnly: true,
    );

    if (!didAuthenticate) return null;

    return {
      "username": (box.get("username") ?? "").toString(),
      "password": (box.get("password") ?? "").toString(),
    };
  }

  Future<void> resetData() async {
    await box.delete("username");
    await box.delete("theme_color");
    await box.delete("theme_color_name");
    await box.delete("saved_city");
    await box.delete("biometrics");
  }
}