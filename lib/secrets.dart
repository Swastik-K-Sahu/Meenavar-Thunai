class AppSecrets {
  static const String geminiApiKey = 'Add_GeminiAPI_Key';
  static const String weatherApiUrl =
      'https://api.open-meteo.com/v1/forecast?latitude=13.0878&longitude=80.2785&daily=sunrise,sunset&hourly=rain,wind_speed_80m,wind_direction_80m,temperature_80m&current=temperature_2m,wind_speed_10m,is_day&timezone=auto&forecast_days=1'; // Weather forecast for Chennai Coast, India
  static const String oceanWeatherApiUrl =
      'https://marine-api.open-meteo.com/v1/marine?latitude=12.958336&longitude=80.375015&current=sea_surface_temperature,ocean_current_velocity,ocean_current_direction&hourly=wave_height,sea_level_height_msl&timezone=auto&forecast_days=1'; // Ocean weather for Chennai Coast, India
}
