import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import '../../../app/routes.dart';
import '../../../core/services/connectivity_service.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_styles.dart';
import '../viewmodels/auth_viewmodel.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isConnected = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _checkConnectivity();
    _navigateToNextScreen();
  }

  Future<void> _checkConnectivity() async {
    final connectivityService = Provider.of<ConnectivityService>(
      context,
      listen: false,
    );
    _isConnected = await connectivityService.isConnected();
    setState(() {});
  }

  Future<void> _navigateToNextScreen() async {
    await Future.delayed(const Duration(seconds: 3));

    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final isLoggedIn = await authViewModel.isUserLoggedIn();

    if (!mounted) return;

    if (isLoggedIn) {
      Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.primaryLight, AppColors.primary],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Center(
                child: Column(
                  children: [
                    // App logo animation
                    SizedBox(
                      height: 200,
                      width: 200,
                      child: Lottie.asset(
                        'assets/animations/fishing_boat.json',
                        controller: _animationController,
                        onLoaded: (composition) {
                          _animationController
                            ..duration = composition.duration
                            ..forward();
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                    // App name
                    Text(
                      'Meenavar-Thunai',
                      style: AppStyles.headlineLarge.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // App tagline
                    Text(
                      'Fisherman\'s Companion',
                      style: AppStyles.bodyLarge.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // Connectivity status
              if (!_isConnected)
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 16,
                  ),
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.wifi_off, color: Colors.orange),
                      const SizedBox(width: 8),
                      Text(
                        'Offline Mode Enabled',
                        style: AppStyles.bodyMedium.copyWith(
                          color: Colors.orange[800],
                        ),
                      ),
                    ],
                  ),
                ),
              // Loading indicator
              Padding(
                padding: const EdgeInsets.only(bottom: 32.0),
                child: Column(
                  children: [
                    const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Loading your fishing paradise...',
                      style: AppStyles.bodyMedium.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
