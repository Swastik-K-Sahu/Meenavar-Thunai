import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

import '../../../app/routes.dart';
import '../../../core/services/fishing_ban_service.dart';
import '../../../core/widgets/alerts_widget.dart';
import '../../../core/widgets/fishing_ban_indicator.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_styles.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../catch_log/fish_catch_screen.dart';
import '../map/map_screen.dart';
import '../profile/profile_screen.dart';
import '../sustainable_products/sustainable_prod_screen.dart';
import '../weather/weather_widget.dart';
import 'package:meenavar_thunai/core/widgets/last_trip_summary_widget.dart';

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
    final today = DateFormat('EEEE, MMMM d').format(DateTime.now());
    final user = authViewModel.user;
    final isFishingBanActive = FishingBanService.isBanActive();

    return WillPopScope(
      onWillPop: () async => false,
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
              onPressed: () {},
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
                      'Welcome${user?.displayName != null ? ', ${user!.displayName}' : ''}',
                      style: AppStyles.headlineSmall.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              const AlertsWidget(),
              const SizedBox(height: 24),

              const WeatherWidget(),
              const SizedBox(height: 24),
              // Fishing Hotspots Card
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/fishing-hotspots'),
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: 8),
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue[400]!, Colors.blue[600]!],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.3),
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.search,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Find Fishing Hotspots',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'AI-powered predictions for the best fishing spots',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
              const FishingBanIndicator(),
              const SizedBox(height: 24),
              const LastTripSummary(),
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
                  builder: (context) => const MapsScreen(),
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
