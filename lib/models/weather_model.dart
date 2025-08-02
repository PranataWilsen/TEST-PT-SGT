class WeatherModel {
  final String description;
  final double temperature;
  final double tempMin;
  final double tempMax;

  WeatherModel({
    required this.description,
    required this.temperature,
    required this.tempMin,
    required this.tempMax,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    final weather = json['weather'];
    final main = json['main'];

    return WeatherModel(
      description: (weather != null && weather.isNotEmpty)
          ? weather[0]['description'] ?? 'No description'
          : 'No description',
      temperature: (main != null && main['temp'] != null)
          ? main['temp'].toDouble()
          : 0.0,
      tempMin: (main != null && main['temp_min'] != null)
          ? main['temp_min'].toDouble()
          : 0.0,
      tempMax: (main != null && main['temp_max'] != null)
          ? main['temp_max'].toDouble()
          : 0.0,
    );
  }

  @override
  String toString() =>
      'WeatherModel(description: $description, temperature: $temperature, tempMin: $tempMin, tempMax: $tempMax)';
}
