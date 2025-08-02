import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';

class WeatherService {
  static const String apiKey = 'https://openweathermap.org/api';

  static Future<WeatherModel?> getWeather({required double lat, required double lon}) async {
    final url =
        'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$apiKey&units=metric';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return WeatherModel.fromJson(json);
      } else {
        print('Failed to load weather');
      }
    } catch (e) {
      print('Error: $e');
    }
    return null;
  }
}
