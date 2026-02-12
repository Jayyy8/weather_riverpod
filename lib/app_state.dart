import 'package:flutter/cupertino.dart';

class AppState {
  const AppState({
    required this.weatherData,
    required this.darkMode,
    required this.isMetric,
    required this.city,
    required this.temperature,
    required this.weatherCondition,
    required this.weatherIcon,
    required this.humidity,
    required this.windSpeed,
    required this.primaryColor,
    required this.themeColorName,
    required this.biometricsEnabled,
  });

  final Map<String, dynamic> weatherData;
  final bool darkMode;
  final bool isMetric;
  final String city;
  final String temperature;
  final String weatherCondition;
  final IconData weatherIcon;
  final String humidity;
  final String windSpeed;
  final Color primaryColor;
  final String themeColorName;
  final bool biometricsEnabled;

  factory AppState.initial() {
    return const AppState(
      weatherData: {},
      darkMode: true,
      isMetric: true,
      city: "",
      temperature: "",
      weatherCondition: "",
      weatherIcon: CupertinoIcons.sun_max,
      humidity: "",
      windSpeed: "",
      primaryColor: CupertinoColors.activeBlue,
      themeColorName: "Blue",
      biometricsEnabled: false,
    );
  }

  AppState copyWith({
    Map<String, dynamic>? weatherData,
    bool? darkMode,
    bool? isMetric,
    String? city,
    String? temperature,
    String? weatherCondition,
    IconData? weatherIcon,
    String? humidity,
    String? windSpeed,
    Color? primaryColor,
    String? themeColorName,
    bool? biometricsEnabled,
  }) {
    return AppState(
      weatherData: weatherData ?? this.weatherData,
      darkMode: darkMode ?? this.darkMode,
      isMetric: isMetric ?? this.isMetric,
      city: city ?? this.city,
      temperature: temperature ?? this.temperature,
      weatherCondition: weatherCondition ?? this.weatherCondition,
      weatherIcon: weatherIcon ?? this.weatherIcon,
      humidity: humidity ?? this.humidity,
      windSpeed: windSpeed ?? this.windSpeed,
      primaryColor: primaryColor ?? this.primaryColor,
      themeColorName: themeColorName ?? this.themeColorName,
      biometricsEnabled: biometricsEnabled ?? this.biometricsEnabled,
    );
  }
}