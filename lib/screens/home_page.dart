import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import '../services/weather_service.dart';
import '../models/weather_model.dart';
import 'login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  WeatherModel? weather;
  String currentTime = '';

  @override
  void initState() {
    super.initState();
    updateTime();
    fetchWeather();
  }

  void updateTime() {
    currentTime = DateFormat('HH:mm:ss').format(DateTime.now());
  }

  Future<void> fetchWeather() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    final data = await WeatherService.getWeather(
      lat: position.latitude,
      lon: position.longitude,
    );
    setState(() {
      weather = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Center(
        child: weather == null
            ? const CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Welcome!', style: Theme.of(context).textTheme.headline6),
                  const SizedBox(height: 8),
                  Text('Current time: $currentTime'),
                  const SizedBox(height: 16),
                  Text('Weather: ${weather!.description}'),
                  Text('Temp: ${weather!.temperature}°C'),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginPage()),
                      );
                    },
                    child: const Text('Logout'),
                  ),
                ],
              ),
      ),
    );
  }
}
