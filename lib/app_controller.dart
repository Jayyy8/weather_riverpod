import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'app_providers.dart';
import 'app_state.dart';
import 'database_provider.dart';
import 'weather_repository.dart';

class AppController extends Notifier<AppState> {
  late final Box box;
  late final WeatherRepository weatherRepository;

  @override
  AppState build() {
    box = ref.read(databaseBoxProvider);
    weatherRepository = ref.read(weatherRepositoryProvider);
    return AppState.initial();
  }

  Future<void> initialize() async {
    final savedColorValue = box.get("theme_color");
    final savedColorName = box.get("theme_color_name");
    final biometrics = box.get("biometrics", defaultValue: false) as bool;

    if (savedColorValue != null && savedColorName != null) {
      state = state.copyWith(
        primaryColor: Color(savedColorValue),
        themeColorName: savedColorName.toString(),
      );
    }

    state = state.copyWith(biometricsEnabled: biometrics);

    final savedCity = box.get("saved_city");
    final resolvedCity =
    await weatherRepository.resolveInitialCity(savedCity?.toString());

    if (resolvedCity != null && resolvedCity.isNotEmpty) {
      state = state.copyWith(city: resolvedCity);
      await fetchWeather();
    }
  }

  Future<bool> fetchWeather() async {
    if (state.city.isEmpty) return false;

    try {
      final result = await weatherRepository.getWeatherData(
        city: state.city,
        isMetric: state.isMetric,
      );

      state = state.copyWith(
        weatherData: result.weatherData,
        city: result.city,
        temperature: result.temperature,
        weatherCondition: result.weatherCondition,
        weatherIcon: result.weatherIcon,
        humidity: result.humidity,
        windSpeed: result.windSpeed,
      );

      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> saveCity(String city) async {
    state = state.copyWith(city: city.trim());
    await box.put("saved_city", state.city);
    return fetchWeather();
  }

  Future<void> toggleMetric(bool value) async {
    state = state.copyWith(isMetric: value);
    await fetchWeather();
  }

  void toggleDarkMode(bool value) {
    state = state.copyWith(darkMode: value);
  }

  Future<void> toggleBiometrics(bool value) async {
    state = state.copyWith(biometricsEnabled: value);
    await box.put("biometrics", value);
  }

  Future<void> setThemeColor(String name, Color color) async {
    state = state.copyWith(
      primaryColor: color,
      themeColorName: name,
    );
    await box.put("theme_color", color.value);
    await box.put("theme_color_name", name);
  }
}