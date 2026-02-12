import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_providers.dart';

class HomeTab extends ConsumerWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appState = ref.watch(appControllerProvider);

    return CupertinoPageScaffold(
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              appState.city,
              style: const TextStyle(
                fontSize: 50,
                fontWeight: FontWeight.w300,
              ),
            ),
            Text(
              "${appState.temperature}°${appState.isMetric ? 'C' : 'F'}",
              style: const TextStyle(
                fontSize: 45,
                fontWeight: FontWeight.w200,
              ),
            ),
            Text(
              appState.weatherCondition,
              style: const TextStyle(
                fontSize: 35,
                fontWeight: FontWeight.w100,
              ),
            ),
            Icon(appState.weatherIcon, size: 100),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text("Humidity: ${appState.humidity}%"),
                Text("Wind: ${appState.windSpeed} km/h"),
              ],
            ),
          ],
        ),
      ),
    );
  }
}