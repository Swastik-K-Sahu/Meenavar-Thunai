import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

import '../../../app/routes.dart';
import '../../../core/services/fishing_ban_service.dart';
import '../../../core/widgets/alerts_widget.dart';
import '../../../core/widgets/fishing_ban_indicator.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_styles.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../fish_catch_log/fish_catch_screen.dart';
import '../map/fishing_maps_screen.dart';
import '../profile/profile_screen.dart';
import '../sustainable_products/sustainable_prod_screen.dart';
import '../weather/weather_widget.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);
    final user = authViewModel.user;
    final isFishingBanActive = FishingBanService.isBanActive();

    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) {
        if (didPop == false) {
          // Prevent popping the dashboard screen
        }
      },
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          automaticallyImplyLeading: false,
          title: Text(
            'Meenavar Thunai',
            style: AppStyles.titleLarge.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(
                Icons.notifications_outlined,
                color: AppColors.textDark,
              ),
              onPressed: () {
                // Dummy notifications action
              },
            ),
            IconButton(
              icon: CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.primaryLight,
                child: Text(
                  user?.displayName?.substring(0, 1).toUpperCase() ?? 'U',
                  style: AppStyles.bodyMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfileScreen(),
                  ),
                );
              },
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.pushNamed(context, AppRoutes.chat);
          },
          backgroundColor: Colors.blue.shade800,
          child: const Icon(Icons.chat),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Vanakkam${user?.displayName != null ? ', ${user!.displayName}' : ''}',
                      style: AppStyles.headlineSmall.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Find Fishing Hotspots Card
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/fishing-hotspots'),
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.search,
                          color: AppColors.primary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Find Fishing Hotspots',
                              style: TextStyle(
                                color: AppColors.textDark,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'AI-powered predictions for the best fishing spots',
                              style: TextStyle(
                                color: AppColors.textDark.withOpacity(0.7),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: AppColors.textDark.withOpacity(0.6),
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              const AlertsWidget(),
              const SizedBox(height: 24),

              const WeatherWidget(),
              const SizedBox(height: 24),
              const FishingBanIndicator(),
              const SizedBox(height: 24),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          onTap: (index) {
            if (isFishingBanActive && (index == 1 || index == 2)) {
              _showFishingBanToast();
              return;
            }

            setState(() => _currentIndex = index);

            if (index == 1) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FishingMapsScreen(),
                  settings: const RouteSettings(name: 'MapsScreen'),
                ),
              ).then((_) => setState(() => _currentIndex = 0));
            } else if (index == 2) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FishCatchScreen(),
                  settings: const RouteSettings(name: 'FishCatchScreen'),
                ),
              ).then((_) => setState(() => _currentIndex = 0));
            } else if (index == 3) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SustainableProductsScreen(),
                  settings: const RouteSettings(
                    name: 'SustainableProductsScreen',
                  ),
                ),
              ).then((_) => setState(() => _currentIndex = 0));
            }
          },
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.map_outlined,
                color: isFishingBanActive ? Colors.grey.withOpacity(0.5) : null,
              ),
              activeIcon: const Icon(Icons.map),
              label: 'Map',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.add_circle_outline,
                color: isFishingBanActive ? Colors.grey.withOpacity(0.5) : null,
              ),
              activeIcon: const Icon(Icons.add_circle),
              label: 'Report',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.shopping_bag_outlined),
              activeIcon: Icon(Icons.shopping_bag),
              label: 'Shop',
            ),
          ],
        ),
      ),
    );
  }

  void _showFishingBanToast() {
    Fluttertoast.showToast(
      msg: "Fishing Ban Period: Feature Disabled",
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: AppColors.error,
      textColor: Colors.white,
    );
  }
}
