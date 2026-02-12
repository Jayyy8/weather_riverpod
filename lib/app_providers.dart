import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_controller.dart';
import 'app_state.dart';
import 'database_provider.dart';
import 'weather_repository.dart';

final weatherRepositoryProvider = Provider<WeatherRepository>((ref) {
  return WeatherRepository(
    apiKey: "4a702b6d783570a69a84b7d6ac2f3a44",
  );
});

final appControllerProvider = NotifierProvider<AppController, AppState>(() {
  return AppController();
});