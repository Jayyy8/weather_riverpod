import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_providers.dart';
import 'auth_gate.dart';

class WeatherAppBiometrics extends ConsumerWidget {
  const WeatherAppBiometrics({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appState = ref.watch(appControllerProvider);

    return CupertinoApp(
      debugShowCheckedModeBanner: false,
      theme: CupertinoThemeData(
        brightness: appState.darkMode ? Brightness.dark : Brightness.light,
        primaryColor: appState.primaryColor,
      ),
      home: const AuthGate(),
    );
  }
}