class OceanData {
  final double latitude;
  final double longitude;
  final String timezone;
  final CurrentOceanData current;
  final HourlyOceanData hourly;

  OceanData({
    required this.latitude,
    required this.longitude,
    required this.timezone,
    required this.current,
    required this.hourly,
  });

  factory OceanData.fromJson(Map<String, dynamic> json) {
    return OceanData(
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
      timezone: json['timezone'] ?? '',
      current: CurrentOceanData.fromJson(json['current']),
      hourly: HourlyOceanData.fromJson(json['hourly']),
    );
  }
}

class CurrentOceanData {
  final String time;
  final double seaSurfaceTemperature;
  final double oceanCurrentVelocity;
  final double oceanCurrentDirection;

  CurrentOceanData({
    required this.time,
    required this.seaSurfaceTemperature,
    required this.oceanCurrentVelocity,
    required this.oceanCurrentDirection,
  });

  factory CurrentOceanData.fromJson(Map<String, dynamic> json) {
    return CurrentOceanData(
      time: json['time'] ?? '',
      seaSurfaceTemperature:
          (json['sea_surface_temperature'] ?? 0.0).toDouble(),
      oceanCurrentVelocity: (json['ocean_current_velocity'] ?? 0.0).toDouble(),
      oceanCurrentDirection:
          (json['ocean_current_direction'] ?? 0.0).toDouble(),
    );
  }
}

class HourlyOceanData {
  final List<String> time;
  final List<double> waveHeight;
  final List<double> seaLevelHeightMsl;

  HourlyOceanData({
    required this.time,
    required this.waveHeight,
    required this.seaLevelHeightMsl,
  });

  factory HourlyOceanData.fromJson(Map<String, dynamic> json) {
    return HourlyOceanData(
      time: List<String>.from(json['time'] ?? []),
      waveHeight:
          (json['wave_height'] as List?)
              ?.map<double>((e) => (e ?? 0.0).toDouble())
              .toList() ??
          <double>[],
      seaLevelHeightMsl:
          (json['sea_level_height_msl'] as List?)
              ?.map<double>((e) => (e ?? 0.0).toDouble())
              .toList() ??
          <double>[],
    );
  }
}
