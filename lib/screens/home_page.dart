import 'dart:async';
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
  Timer? _timer;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    updateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      setState(() {
        updateTime();
      });
    });
    fetchWeather();
  }

  void updateTime() {
    currentTime = DateFormat('HH:mm:ss').format(DateTime.now());
  }

  Future<void> fetchWeather() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever) {
          setState(() {
            errorMessage = 'Location permission denied.';
          });
          return;
        }
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final data = await WeatherService.getWeather(
        lat: position.latitude,
        lon: position.longitude,
      );

      setState(() {
        weather = data;
        errorMessage = null;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to fetch weather data.';
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E1B2C), // Night background
      body: errorMessage != null
          ? Center(
              child: Text(errorMessage!,
                  style: const TextStyle(color: Colors.red)),
            )
          : weather == null
              ? const Center(child: CircularProgressIndicator())
              : SafeArea(
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      Image.asset(
                        'assets/images/home.png',
                        height: 150,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        '${weather!.temperature}°',
                        style: const TextStyle(
                          fontSize: 60,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        weather!.description,
                        style: const TextStyle(
                          fontSize: 24,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Min: ${weather!.tempMin}°  •  Max: ${weather!.tempMax}°',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Time: $currentTime',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white10,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        margin: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: List.generate(5, (index) {
                            final time = DateFormat.Hm().format(DateTime.now().add(Duration(hours: index + 1)));
                            return Column(
                              children: [
                                Text(
                                  time,
                                  style: const TextStyle(color: Colors.white),
                                ),
                                const SizedBox(height: 8),
                                const Icon(Icons.cloud, color: Colors.white),
                                const SizedBox(height: 8),
                                Text(
                                  '${weather!.temperature + index}°',
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ],
                            );
                          }),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LoginPage(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          child: Text('Logout', style: TextStyle(color: Colors.white)),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
    );
  }
}
