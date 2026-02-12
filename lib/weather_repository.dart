import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class WeatherResult {
  const WeatherResult({
    required this.weatherData,
    required this.city,
    required this.temperature,
    required this.weatherCondition,
    required this.weatherIcon,
    required this.humidity,
    required this.windSpeed,
  });

  final Map<String, dynamic> weatherData;
  final String city;
  final String temperature;
  final String weatherCondition;
  final IconData weatherIcon;
  final String humidity;
  final String windSpeed;
}

class WeatherRepository {
  WeatherRepository({required this.apiKey});

  final String apiKey;

  Future<String?> resolveInitialCity(String? savedCity) async {
    if (savedCity != null && savedCity.toString().isNotEmpty) {
      return savedCity;
    }

    try {
      final bool serviceEnabled =
      await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      LocationPermission permission =
      await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }

      final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;

        return place.locality ??
            place.subAdministrativeArea ??
            place.administrativeArea ??
            "";
      }
    } catch (_) {}

    return null;
  }

  Future<WeatherResult> getWeatherData({
    required String city,
    required bool isMetric,
  }) async {
    final link =
        "https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey";

    final response = await http.get(Uri.parse(link));
    final weatherData = jsonDecode(response.body) as Map<String, dynamic>;

    if (weatherData["cod"] != 200) {
      throw Exception("Invalid city");
    }

    final double tempKelvin = weatherData["main"]["temp"];
    final String tempConverted = isMetric
        ? (tempKelvin - 273.15).toStringAsFixed(0)
        : ((tempKelvin - 273.15) * 9 / 5 + 32).toStringAsFixed(0);

    final String weatherCondition = weatherData["weather"][0]["main"];

    return WeatherResult(
      weatherData: weatherData,
      city: weatherData["name"].toString(),
      temperature: tempConverted,
      weatherCondition: weatherCondition,
      weatherIcon: _mapWeatherIcon(weatherCondition),
      humidity: weatherData["main"]["humidity"].toString(),
      windSpeed: weatherData["wind"]["speed"].toString(),
    );
  }

  IconData _mapWeatherIcon(String condition) {
    if (condition == "Clouds") {
      return CupertinoIcons.cloud;
    } else if (condition == "Rain") {
      return CupertinoIcons.cloud_bolt_rain;
    } else if (condition == "Clear") {
      return CupertinoIcons.sun_max;
    }

    return CupertinoIcons.sun_max;
  }
}