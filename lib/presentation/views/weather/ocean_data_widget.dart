import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:meenavar_thunai/secrets.dart';
import 'dart:convert';
import 'dart:math' as math;
import '../../../theme/app_styles.dart';

class OceanDataWidget extends StatefulWidget {
  const OceanDataWidget({super.key});

  @override
  State<OceanDataWidget> createState() => _OceanDataWidgetState();
}

class _OceanDataWidgetState extends State<OceanDataWidget> {
  Map<String, dynamic>? oceanData;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchOceanData();
  }

  Future<void> _fetchOceanData() async {
    try {
      const String apiUrl = AppSecrets.oceanWeatherApiUrl;

      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        setState(() {
          oceanData = jsonData;
          isLoading = false;
          errorMessage = null;
        });
      } else {
        setState(() {
          isLoading = false;
          errorMessage = 'Failed to load ocean data';
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Error: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey,
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child:
          isLoading
              ? _buildLoadingWidget()
              : errorMessage != null
              ? _buildErrorWidget()
              : _buildOceanContent(),
    );
  }

  Widget _buildLoadingWidget() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(),
        SizedBox(width: 16),
        Text('Loading ocean data...'),
      ],
    );
  }

  Widget _buildErrorWidget() {
    return Column(
      children: [
        Icon(Icons.error_outline, color: Colors.red, size: 32),
        const SizedBox(height: 8),
        Text(
          errorMessage!,
          style: AppStyles.bodyMedium.copyWith(color: Colors.red),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: () {
            setState(() {
              isLoading = true;
              errorMessage = null;
            });
            _fetchOceanData();
          },
          child: const Text('Retry'),
        ),
      ],
    );
  }

  Widget _buildOceanContent() {
    final current = oceanData!['current'];
    final hourly = oceanData!['hourly'];

    final double seaTemp =
        current['sea_surface_temperature']?.toDouble() ?? 31.1;
    final double currentVelocity =
        current['ocean_current_velocity']?.toDouble() ?? 0.6;
    final double currentDirection =
        current['ocean_current_direction']?.toDouble() ?? 18.0;

    final List<double> waveHeights =
        (hourly['wave_height'] as List)
            .map<double>((e) => e?.toDouble() ?? 0.0)
            .toList();
    final List<double> seaLevels =
        (hourly['sea_level_height_msl'] as List)
            .map<double>((e) => e?.toDouble() ?? 0.0)
            .toList();
    final List<String> times =
        (hourly['time'] as List).map<String>((e) => e.toString()).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            Icon(Icons.waves, color: Colors.blue[600], size: 24),
            const SizedBox(width: 8),
            Text(
              'Ocean Data',
              style: AppStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Current Ocean Conditions Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue[50]!, Colors.blue[100]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildCurrentDataItem(
                    'Sea Temp',
                    '${seaTemp.round()}°C',
                    Icons.thermostat,
                    Colors.orange[600]!,
                  ),
                  _buildCurrentDataItem(
                    'Current',
                    '${currentVelocity.toStringAsFixed(1)} km/h',
                    Icons.trending_up,
                    Colors.blue[600]!,
                  ),
                  _buildCurrentDirectionItem(
                    'Direction',
                    '${currentDirection.round()}°',
                    currentDirection,
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Wave Height Chart
        _buildChartSection(
          'Waves',
          waveHeights,
          times,
          Colors.blue[400]!,
          'm',
          Icons.waves,
        ),

        const SizedBox(height: 20),

        // Sea Level Chart
        _buildChartSection(
          'Tides',
          seaLevels,
          times,
          Colors.cyan[400]!,
          'm',
          Icons.water,
        ),
      ],
    );
  }

  Widget _buildCurrentDataItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: AppStyles.bodyLarge.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: AppStyles.bodySmall.copyWith(color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildCurrentDirectionItem(
    String label,
    String value,
    double direction,
  ) {
    return Column(
      children: [
        Transform.rotate(
          angle: direction * math.pi / 180,
          child: Icon(Icons.navigation, color: Colors.green[600], size: 28),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: AppStyles.bodyLarge.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.green[600],
          ),
        ),
        Text(
          label,
          style: AppStyles.bodySmall.copyWith(color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildChartSection(
    String title,
    List<double> data,
    List<String> times,
    Color color,
    String unit,
    IconData icon,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: AppStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Current value display
        Row(
          children: [
            Text(
              data.isNotEmpty
                  ? data[DateTime.now().hour < data.length
                          ? DateTime.now().hour
                          : 0]
                      .toStringAsFixed(2)
                  : "0.00",
              style: AppStyles.headlineMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              unit,
              style: AppStyles.bodyLarge.copyWith(color: Colors.grey[600]),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Chart
        SizedBox(
          height: 100,
          child: CustomPaint(
            size: Size(double.infinity, 100),
            painter: ChartPainter(data, color),
          ),
        ),

        const SizedBox(height: 8),

        // Time labels
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '00:00',
              style: AppStyles.bodySmall.copyWith(color: Colors.grey[600]),
            ),
            Text(
              '06:00',
              style: AppStyles.bodySmall.copyWith(color: Colors.grey[600]),
            ),
            Text(
              '12:00',
              style: AppStyles.bodySmall.copyWith(color: Colors.grey[600]),
            ),
            Text(
              '18:00',
              style: AppStyles.bodySmall.copyWith(color: Colors.grey[600]),
            ),
            Text(
              '23:00',
              style: AppStyles.bodySmall.copyWith(color: Colors.grey[600]),
            ),
          ],
        ),
      ],
    );
  }
}

class ChartPainter extends CustomPainter {
  final List<double> data;
  final Color color;

  ChartPainter(this.data, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint =
        Paint()
          ..color = color.withOpacity(0.3)
          ..style = PaintingStyle.fill;

    final linePaint =
        Paint()
          ..color = color
          ..strokeWidth = 2.0
          ..style = PaintingStyle.stroke;

    final pointPaint =
        Paint()
          ..color = color
          ..style = PaintingStyle.fill;

    final path = Path();
    final linePath = Path();

    final double maxValue = data.reduce(math.max);
    final double minValue = data.reduce(math.min);
    final double range = maxValue - minValue;

    // Create points
    final points = <Offset>[];
    for (int i = 0; i < data.length; i++) {
      final double x = (i / (data.length - 1)) * size.width;
      final double y =
          size.height - ((data[i] - minValue) / range) * size.height;
      points.add(Offset(x, y));
    }

    // Create filled area path
    path.moveTo(0, size.height);
    for (int i = 0; i < points.length; i++) {
      if (i == 0) {
        path.lineTo(points[i].dx, points[i].dy);
      } else {
        path.lineTo(points[i].dx, points[i].dy);
      }
    }
    path.lineTo(size.width, size.height);
    path.close();

    // Create line path
    linePath.moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < points.length; i++) {
      linePath.lineTo(points[i].dx, points[i].dy);
    }

    // Draw filled area
    canvas.drawPath(path, paint);

    // Draw line
    canvas.drawPath(linePath, linePaint);

    // Draw points
    for (final point in points) {
      canvas.drawCircle(point, 3, pointPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
