import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_providers.dart';
import 'login_page.dart';

class SignupPage extends ConsumerStatefulWidget {
  const SignupPage({super.key});

  @override
  ConsumerState<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends ConsumerState<SignupPage> {
  final TextEditingController _username = TextEditingController();
  final TextEditingController _password = TextEditingController();

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hidePassword = ref.watch(signupHidePasswordProvider);
    final msg = ref.watch(signupMessageProvider);

    return CupertinoPageScaffold(
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Create your local account",
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
                  ref.read(signupHidePasswordProvider.notifier).state = !hidePassword;
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
                    child: const Text('Sign Up'),
                    onPressed: () async {
                      if (_username.text.isEmpty || _password.text.isEmpty) {
                        ref.read(signupMessageProvider.notifier).state =
                        "Input text fields are empty";
                      } else {
                        await ref
                            .read(authRepositoryProvider)
                            .signup(_username.text, _password.text);

                        if (!mounted) return;

                        Navigator.pushReplacement(
                          context,
                          CupertinoPageRoute(
                            builder: (_) => const LoginPage(),
                          ),
                        );
                      }
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