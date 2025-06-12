import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../core/services/firebase_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SustainabilityBadge extends StatefulWidget {
  const SustainabilityBadge({super.key});

  @override
  State<SustainabilityBadge> createState() => _SustainabilityBadgeState();
}

class _SustainabilityBadgeState extends State<SustainabilityBadge> {
  int _totalPoints = 0;
  String _level = 'Loading Level...';
  String _nextMilestone = 'Loading Milestone...';
  int _pointsToNextLevel = 0;
  double _progressFactor = 0.0;

  final int _silverFisherThreshold = 1000;
  final int _goldFisherThreshold = 2000;

  @override
  void initState() {
    super.initState();
    _fetchAndSetSustainabilityPoints();
  }

  Future<void> _fetchAndSetSustainabilityPoints() async {
    final firebaseService = FirebaseService();
    final user = FirebaseAuth.instance.currentUser!;

    int fetchedPoints = await firebaseService.fetchTotalSustainabilityPoints(
      user.uid,
    );

    setState(() {
      _totalPoints = fetchedPoints;
      _updateBadgeDetails();
    });
  }

  void _updateBadgeDetails() {
    if (_totalPoints >= _goldFisherThreshold) {
      _level = 'Gold Fisher';
      _nextMilestone = 'Master Fisher';
      _pointsToNextLevel = 0;
      _progressFactor = 1.0;
    } else if (_totalPoints >= _silverFisherThreshold) {
      _level = 'Silver Fisher';
      _nextMilestone = 'Gold Fisher';
      _pointsToNextLevel = _goldFisherThreshold - _totalPoints;
      // Calculate progress based on the points within the current tier
      _progressFactor =
          (_totalPoints - _silverFisherThreshold) /
          (_goldFisherThreshold - _silverFisherThreshold);
      if (_progressFactor.isNaN) _progressFactor = 0.0;
    } else {
      _level = 'Bronze Fisher';
      _nextMilestone = 'Silver Fisher';
      _pointsToNextLevel = _silverFisherThreshold - _totalPoints;
      _progressFactor = _totalPoints / _silverFisherThreshold;
    }
    if (_progressFactor > 1.0) _progressFactor = 1.0;
    if (_progressFactor < 0.0) _progressFactor = 0.0;
  }

  String _getBadgeImage() {
    if (_totalPoints >= _goldFisherThreshold) {
      return 'assets/images/bronze_badge.png'; // Dummy image
    } else if (_totalPoints >= _silverFisherThreshold) {
      return 'assets/images/bronze_badge.png'; // Dummy image
    }
    return 'assets/images/bronze_badge.png'; // Default
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary.withOpacity(0.7), AppColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        children: [
          // Badge image
          Container(
            height: 64,
            width: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: AppColors.accent.withOpacity(0.3),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Center(
              child: Image.asset(_getBadgeImage(), height: 40, width: 40),
            ),
          ),
          const SizedBox(width: 16),
          // Points information
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.workspace_premium,
                      color: Colors.white,
                      size: 18,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _level,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Points counter
                Text(
                  '$_totalPoints Points',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                // Progress to next level
                Stack(
                  children: [
                    Container(
                      height: 6,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: _progressFactor,
                      child: SizedBox(
                        height: 6,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '$_pointsToNextLevel points to $_nextMilestone',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                // Redemption text
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    '🎁 Redeem points for discounts on sustainable products!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
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
