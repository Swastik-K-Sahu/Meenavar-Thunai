import 'package:flutter/material.dart';
import 'package:meenavar_thunai/presentation/views/weather/weather_widget.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_styles.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../../core/widgets/alerts_widget.dart';
import '../map/map_screen.dart';
import '../catch_log/fish_catch_screen.dart';
import '../../../core/widgets/fishing_ban_indicator.dart';
import '../../../core/services/fishing_ban_service.dart';
import '../sustainable_products/sustainable_prod_screen.dart';
import '../profile/profile_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;
  final List<Widget> _screens = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);
    final today = DateFormat('EEEE, MMMM d').format(DateTime.now());
    final user = authViewModel.user;
    final isFishingBanActive = FishingBanService.isBanActive();

    return WillPopScope(
      // Prevent back button navigation from dashboard
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          automaticallyImplyLeading: false, // Remove back button
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
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome${user?.displayName != null ? ', ${user!.displayName}' : ''}',
                          style: AppStyles.headlineSmall.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
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

            setState(() {
              _currentIndex = index;
            });

            if (index == 0) {
              return;
            } else if (index == 1) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MapsScreen(),
                  settings: const RouteSettings(name: 'MapsScreen'),
                ),
              ).then((_) {
                // Reset index to 0 when returning to dashboard
                setState(() {
                  _currentIndex = 0;
                });
              });
            } else if (index == 2) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FishCatchScreen(),
                  settings: const RouteSettings(name: 'FishCatchScreen'),
                ),
              ).then((_) {
                // Reset index to 0 when returning to dashboard
                setState(() {
                  _currentIndex = 0;
                });
              });
            } else if (index == 3) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SustainableProductsScreen(),
                  settings: const RouteSettings(
                    name: 'SustainableProductsScreen',
                  ),
                ),
              ).then((_) {
                // Reset index to 0 when returning to dashboard
                setState(() {
                  _currentIndex = 0;
                });
              });
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
              activeIcon: Icon(Icons.map),
              label: 'Map',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.add_circle_outline,
                color: isFishingBanActive ? Colors.grey.withOpacity(0.5) : null,
              ),
              activeIcon: Icon(Icons.add_circle),
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
      timeInSecForIosWeb: 3,
      backgroundColor: AppColors.error,
      textColor: Colors.white,
    );
  }
}
