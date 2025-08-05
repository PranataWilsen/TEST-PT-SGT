import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';

class WeatherService {
  static const String _apiKey = '8e4988ea2b2b89d198066ccdce66eee0';

  static Future<WeatherModel?> getWeather({
    required double lat,
    required double lon,
  }) async {
    final url =
        'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&units=metric&appid=$_apiKey';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return WeatherModel.fromJson(data);
      } else {
        debugPrint('Failed to load weather: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching weather: $e');
    }
    return null;
  }

  static Future<WeatherModel?> fetchWeather(String city) async {
    final url = Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?q=$city&units=metric&appid=$_apiKey');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return WeatherModel.fromJson(data);
      } else {
        debugPrint('Failed to load weather by city: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching weather by city: $e');
    }
    return null;
  }
}
