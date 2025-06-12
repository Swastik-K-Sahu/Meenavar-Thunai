class WeatherData {
  final double temperature;
  final double windSpeed;
  final int isDay;
  final double rain;
  final String timezone;
  final List<String> hourlyTimes;
  final List<double> hourlyTemperatures;
  final List<double> hourlyRain;
  final List<double> hourlyWindSpeed;
  final List<double> hourlyWindDirection;
  final String sunrise;
  final String sunset;

  WeatherData({
    required this.temperature,
    required this.windSpeed,
    required this.isDay,
    required this.rain,
    required this.timezone,
    required this.hourlyTimes,
    required this.hourlyTemperatures,
    required this.hourlyRain,
    required this.hourlyWindSpeed,
    required this.hourlyWindDirection,
    required this.sunrise,
    required this.sunset,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    final currentHour = DateTime.now().hour;

    return WeatherData(
      temperature: json['current']['temperature_2m'].toDouble(),
      windSpeed: json['current']['wind_speed_10m'].toDouble(),
      isDay: json['current']['is_day'],
      rain: json['hourly']['rain'][currentHour].toDouble(),
      timezone: json['timezone'],
      hourlyTimes: List<String>.from(json['hourly']['time']),
      hourlyTemperatures: List<double>.from(
        json['hourly']['temperature_80m'].map((temp) => temp.toDouble()),
      ),
      hourlyRain: List<double>.from(
        json['hourly']['rain'].map((rain) => rain.toDouble()),
      ),
      hourlyWindSpeed: List<double>.from(
        json['hourly']['wind_speed_80m'].map((speed) => speed.toDouble()),
      ),
      hourlyWindDirection: List<double>.from(
        json['hourly']['wind_direction_80m'].map((dir) => dir.toDouble()),
      ),
      sunrise: json['daily']['sunrise'][0],
      sunset: json['daily']['sunset'][0],
    );
  }
}
