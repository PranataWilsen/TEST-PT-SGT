import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
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
  String? cityName;

  @override
  void initState() {
    super.initState();
    updateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => updateTime());
    fetchWeather();
  }

  void updateTime() {
    setState(() {
      currentTime = DateFormat('HH:mm').format(DateTime.now());
    });
  }

  Future<void> fetchWeather() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
          setState(() {
            errorMessage = 'Location permission denied.';
          });
          return;
        }
      }

      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      final data = await WeatherService.getWeather(lat: position.latitude, lon: position.longitude);
      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);

      setState(() {
        weather = data;
        cityName = placemarks.first.locality ?? 'Unknown';
        errorMessage = null;
      });
    } catch (_) {
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

  Widget _buildWeatherIcon(String condition) {
    switch (condition.toLowerCase()) {
      case 'clear':
        return const Icon(Icons.wb_sunny, color: Colors.yellow, size: 20);
      case 'rain':
        return const Icon(Icons.water_drop, color: Colors.lightBlue, size: 20);
      case 'snow':
        return const Icon(Icons.ac_unit, color: Colors.white, size: 20);
      case 'clouds':
        return const Icon(Icons.cloud, color: Colors.grey, size: 20);
      default:
        return const Icon(Icons.cloud, color: Colors.grey, size: 20);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: errorMessage != null
          ? Center(child: Text(errorMessage!, style: const TextStyle(color: Colors.red)))
          : weather == null
              ? const Center(child: CircularProgressIndicator())
              : Stack(
                  children: [
                    Positioned.fill(
                      child: Image.asset(
                        'assets/images/home.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                    SafeArea(
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  currentTime,
                                  style: const TextStyle(color: Colors.white, fontSize: 16),
                                ),
                                Row(children: const [
                                  Icon(Icons.wifi, color: Colors.white, size: 16),
                                  SizedBox(width: 6),
                                  Icon(Icons.battery_full, color: Colors.white, size: 16),
                                ]),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),
                          Text(
                            cityName ?? 'Loading...',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.center,
                            child: Text(
                              '${weather!.temperature.toInt()}°',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 96,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ),
                          Text(
                            weather!.description,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 18,
                            ),
                          ),
                          Text(
                            'H:${weather!.tempMax.toInt()}°  L:${weather!.tempMin.toInt()}°',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 0),
                          Container(
                            width: 280,
                            height: 200,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(24),
                              child: Image.asset(
                                'assets/images/house.png',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: Image.asset(
                                    'assets/images/box.png',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                            child: const Text(
                                              'Hourly Forecast',
                                              style: TextStyle(color: Colors.white),
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                            child: const Text(
                                              'Weekly Forecast',
                                              style: TextStyle(color: Colors.white54),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      SizedBox(
                                        height: 110,
                                        child: ListView.builder(
                                          scrollDirection: Axis.horizontal,
                                          itemCount: 12,
                                          itemBuilder: (context, index) {
                                            final isNow = index == 0;
                                            final timeLabel = isNow
                                                ? 'Now'
                                                : DateFormat('h a').format(
                                                    DateTime.now().add(Duration(hours: index)),
                                                  );
                                            return Container(
                                              margin: const EdgeInsets.only(right: 12),
                                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
                                              decoration: BoxDecoration(
                                                color: isNow ? Colors.deepPurple[700] : Colors.deepPurple[400],
                                                borderRadius: BorderRadius.circular(24),
                                              ),
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    timeLabel,
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 8),
                                                  _buildWeatherIcon(weather!.description),
                                                  const SizedBox(height: 8),
                                                  Text(
                                                    '${(weather!.temperature + index).toInt()}°',
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.w500,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                      const Spacer(),
                                      Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          Image.asset(
                                            'assets/images/tab.png',
                                            width: MediaQuery.of(context).size.width,
                                            height: 110,
                                            fit: BoxFit.cover,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 0),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                IconButton(
                                                  iconSize: 30,
                                                  icon: const Icon(Icons.location_on_outlined, color: Colors.white70),
                                                  onPressed: () {},
                                                ),
                                                Container(
                                                  padding: const EdgeInsets.all(22),
                                                  decoration: const BoxDecoration(
                                                    color: Colors.white,
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: const Icon(
                                                    Icons.add,
                                                    color: Colors.deepPurple,
                                                    size: 25,
                                                  ),
                                                ),
                                                IconButton(
                                                  iconSize: 30,
                                                  icon: const Icon(Icons.menu, color: Colors.white70),
                                                  onPressed: () {
                                                    Navigator.pushReplacement(
                                                      context,
                                                      MaterialPageRoute(builder: (_) => const LoginPage()),
                                                    );
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }
}
