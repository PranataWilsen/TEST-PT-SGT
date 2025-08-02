import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import '../services/weather_service.dart';

class WeatherProvider extends ChangeNotifier {
  WeatherModel? _weather;
  bool _isLoading = false;
  String? _errorMessage;

  WeatherModel? get weather => _weather;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchWeather(String city) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await WeatherService.fetchWeather(city);
      _weather = result;
    } catch (e) {
      _errorMessage = 'Gagal memuat data cuaca: $e';
    }

    _isLoading = false;
    notifyListeners();
  }
}
