import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_providers.dart';
import 'main_shell.dart';
import 'signup_page.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final TextEditingController _username = TextEditingController();
  final TextEditingController _password = TextEditingController();

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _biometrics() async {
    final authRepository = ref.read(authRepositoryProvider);

    try {
      final credentials = await authRepository.authenticateWithBiometrics();

      if (credentials != null) {
        _username.text = credentials["username"] ?? "";
        _password.text = credentials["password"] ?? "";
      }
    } catch (e) {
      if (!mounted) return;

      showCupertinoDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: const Text("Biometrics Unsupported"),
            content: Text(e.toString()),
            actions: [
              CupertinoButton(
                child: const Text("Close"),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final hidePassword = ref.watch(loginHidePasswordProvider);
    final msg = ref.watch(loginMessageProvider);
    final biometricsEnabled =
    ref.watch(authRepositoryProvider).biometricsEnabled();

    return CupertinoPageScaffold(
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Login",
              style: TextStyle(fontWeight: FontWeight.w200, fontSize: 35),
            ),
            const SizedBox(height: 10),
            CupertinoTextField(
              padding: const EdgeInsets.all(9),
              controller: _username,
              prefix: const Icon(CupertinoIcons.person),
              placeholder: "Username",
            ),
            CupertinoTextField(
              controller: _password,
              prefix: const Icon(CupertinoIcons.padlock),
              placeholder: "Password",
              obscureText: hidePassword,
              suffix: CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () {
                  ref.read(loginHidePasswordProvider.notifier).state = !hidePassword;
                },
                child: Icon(
                  hidePassword
                      ? CupertinoIcons.eye
                      : CupertinoIcons.eye_slash,
                ),
              ),
            ),
            Center(
              child: Column(
                children: [
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: const Text('Login'),
                    onPressed: () {
                      final isValid = ref
                          .read(authRepositoryProvider)
                          .login(_username.text, _password.text);

                      if (isValid) {
                        Navigator.pushReplacement(
                          context,
                          CupertinoPageRoute(
                            builder: (_) => const MainShell(),
                          ),
                        );
                      } else {
                        ref.read(loginMessageProvider.notifier).state =
                        "Invalid username or password";
                      }
                    },
                  ),
                  biometricsEnabled
                      ? CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: _biometrics,
                    child: const Icon(Icons.fingerprint, size: 30),
                  )
                      : const SizedBox(height: 30),
                  CupertinoButton(
                    child: const Text("Reset Data"),
                    onPressed: () async {
                      await ref.read(authRepositoryProvider).resetData();

                      if (!mounted) return;

                      Navigator.pushReplacement(
                        context,
                        CupertinoPageRoute(
                          builder: (_) => const SignupPage(),
                        ),
                      );
                    },
                  ),
                  Text(
                    msg,
                    style: const TextStyle(
                      color: CupertinoColors.destructiveRed,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}