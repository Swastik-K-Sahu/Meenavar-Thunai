// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../../core/services/connectivity_service.dart';
// import '../../../theme/app_colors.dart';
// import '../../../theme/app_styles.dart';
// import '../../viewmodels/weather_viewmodel.dart';

// class WeatherWidget extends StatelessWidget {
//   const WeatherWidget({Key? key}) : super(key: key);

//   String _getWeatherIcon(String? condition) {
//     if (condition == null) return 'assets/icons/weather/partly_cloudy.png';
    
//     condition = condition.toLowerCase();
    
//     if (condition.contains('sunny') || condition.contains('clear')) {
//       return 'assets/icons/weather/sunny.png';
//     } else if (condition.contains('rain')) {
//       return 'assets/icons/weather/rainy.png';
//     } else if (condition.contains('cloud')) {
//       return 'assets/icons/weather/cloudy.png';
//     } else if (condition.contains('storm') || condition.contains('thunder')) {
//       return 'assets/icons/weather/stormy.png';
//     } else if (condition.contains('fog') || condition.contains('mist')) {
//       return 'assets/icons/weather/foggy.png';
//     } else if (condition.contains('snow')) {
//       return 'assets/icons/weather/snowy.png';
//     } else if (condition.contains('wind')) {
//       return 'assets/icons/weather/windy.png';
//     }
    
//     return 'assets/icons/weather/partly_cloudy.png';
//   }

//   @override
//   Widget build(BuildContext context) {
//     final weatherViewModel = Provider.of<WeatherViewModel>(context);
//     final connectivityService = Provider.of<ConnectivityService>(context);
//     final isOffline = !connectivityService.isConnected;
    
//     // For demo purposes, use placeholder data
//     final currentTemp = 24;
//     final condition = 'Partly Cloudy';
//     final wind = '15 km/h';
//     final humidity = '65%';
//     final visibility = '12 km';
    
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topRight,
//           end: Alignment.bottomLeft,
//           colors: [
//             AppColors.primary,
//             AppColors.primary.withBlue(220),
//           ],
//         ),
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: AppColors.primary.withOpacity(0.3),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 'Today\'s Weather',
//                 style: AppStyles.titleMedium.copyWith(
//                   color: Colors.white,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               if (isOffline)
//                 Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                   decoration: BoxDecoration(
//                     color: Colors.white.withOpacity(0.2),
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Row(
//                     children: [
//                       const Icon(
//                         Icons.access_time,
//                         color: Colors.white,
//                         size: 12,
//                       ),
//                       const SizedBox(width: 4),
//                       Text(
//                         'Last updated 2h ago',
//                         style: AppStyles.bodySmall.copyWith(
//                           color: Colors.white,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//             ],
//           ),
//           const SizedBox(height: 16),
//           Row(
//             children: [
//               // Temperature and condition
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           '$currentTemp',
//                           style: AppStyles.headlineLarge.copyWith(
//                             color: Colors.white,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         Text(
//                           '°C',
//                           style: AppStyles.titleMedium.copyWith(
//                             color: Colors.white,
//                           ),
//                         ),
//                       ],
//                     ),
//                     Text(
//                       condition,
//                       style: AppStyles.bodyLarge.copyWith(
//                         color: Colors.white,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       'Feels like ${currentTemp - 1}°C',
//                       style: AppStyles.bodyMedium.copyWith(
//                         color: Colors.white.withOpacity(0.8),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               // Weather icon
//               Image.asset(
//                 _getWeatherIcon(condition),
//                 width: 80,
//                 height: 80,
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),
//           // Weather details
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceAround,
//             children: [
//               _buildWeatherDetail(
//                 icon: Icons.air,
//                 value: wind,
//                 label: 'Wind',
//               ),
//               _buildWeatherDetail(
//                 icon: Icons.water_drop_outlined,
//                 value: humidity,
//                 label: 'Humidity',
//               ),
//               _buildWeatherDetail(
//                 icon: Icons.visibility_outlined,
//                 value: visibility,
//                 label: 'Visibility',
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),
//           // Fishing conditions
//           Container(
//             padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
//             decoration: BoxDecoration(
//               color: Colors.white.withOpacity(0.2),
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Row(
//               children: [
//                 const Icon(
//                   Icons.waves,
//                   color: Colors.white,
//                 ),
//                 const SizedBox(width: 8),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Good Fishing Conditions',
//                         style: AppStyles.bodyMedium.copyWith(
//                           color: Colors.white,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       Text(
//                         'Moderate winds and clear skies - perfect for coastal fishing today!',
//                         style: AppStyles.bodySmall.copyWith(
//                           color: Colors.white.withOpacity(0.9),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildWeatherDetail({
//     required IconData icon,
//     required String value,
//     required String label,
//   }) {
//     return Column(
//       children: [
//         Icon(
//           icon,
//           color: Colors.white,
//           size: 20,
//         ),
//         const SizedBox(height: 4),
//         Text(
//           value,
//           style: AppStyles.bodyMedium.copyWith(
//             color: Colors.white,
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//         Text(
//           label,
//           style: AppStyles.bodySmall.copyWith(
//             color: Colors.white.withOpacity(0.8),
//           ),
//         ),
//       ],
//     );
//   }
// }