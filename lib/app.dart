import 'package:flutter/cupertino.dart';

import 'auth_gate.dart';

class WeatherAppBiometrics extends StatelessWidget {
  const WeatherAppBiometrics({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoApp(
      debugShowCheckedModeBanner: false,
      home: AuthGate(),
    );
  }
}