import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../../core/services/connectivity_service.dart';
// import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/offline_indicator.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_styles.dart';
import '../../viewmodels/auth_viewmodel.dart';
// import '../../viewmodels/weather_viewmodel.dart';
// import '../dashboard/weather_widget.dart';
import '../dashboard/alerts_widget.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;
  final List<String> _featureImages = [
    'assets/images/map_feature.jpg',
    'assets/images/weather_feature.jpg',
    'assets/images/catch_feature.jpg',
    'assets/images/offline_feature.jpg',
  ];

  final List<String> _featureTitles = [
    'Interactive Maps',
    'Weather Forecast',
    'Catch Reports',
    'Offline Mode',
  ];

  final List<String> _featureDescriptions = [
    'Navigate with precision using our detailed coastal maps',
    'Stay ahead with real-time weather updates for your location',
    'Track and log your catches with our easy reporting system',
    'Access essential features even without internet connection',
  ];

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
  }

  Future<void> _checkConnectivity() async {
    final connectivityService = Provider.of<ConnectivityService>(
      context,
      listen: false,
    );
    await connectivityService.isConnected();
  }

  Widget _buildQuickActionItem({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: AppStyles.bodySmall.copyWith(fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturesCarousel() {
    return SizedBox(
      height: 240,
      child: PageView.builder(
        itemCount: _featureImages.length,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Feature image
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    _featureImages[index],
                    height: 240,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                // Gradient overlay
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                ),
                // Text content
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _featureTitles[index],
                          style: AppStyles.titleMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _featureDescriptions[index],
                          style: AppStyles.bodyMedium.copyWith(
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);
    final connectivityService = Provider.of<ConnectivityService>(context);
    // final weatherViewModel = Provider.of<WeatherViewModel>(context);

    return FutureBuilder<bool>(
      future: connectivityService.isConnected(),
      builder: (context, snapshot) {
        final isOffline = !(snapshot.data ?? false);
        final today = DateFormat('EEEE, MMMM d').format(DateTime.now());
        final user = authViewModel.user;

        return Scaffold(
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            title: Text(
              'Coastal Mate',
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
                onPressed: () {},
              ),
            ],
          ),
          body: Stack(
            children: [
              // Main content
              SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Greeting section
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome${user != null ? ', ${user.displayName}' : ''}',
                                style: AppStyles.headlineSmall.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                today,
                                style: AppStyles.bodyMedium.copyWith(
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isOffline) const OfflineIndicator(),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Weather section
                    // const WeatherWidget(),
                    // const SizedBox(height: 24),

                    // Important alerts
                    const AlertsWidget(),
                    const SizedBox(height: 24),

                    // Quick actions
                    Text(
                      'Quick Actions',
                      style: AppStyles.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _buildQuickActionItem(
                          icon: Icons.map_outlined,
                          label: 'Maps',
                          color: Colors.blue[700]!,
                          onTap: () {},
                        ),
                        _buildQuickActionItem(
                          icon: Icons.add_a_photo_outlined,
                          label: 'Report',
                          color: Colors.green[700]!,
                          onTap: () {},
                        ),
                        _buildQuickActionItem(
                          icon: Icons.cloud_download_outlined,
                          label: 'Offline',
                          color: Colors.orange[700]!,
                          onTap: () {},
                        ),
                        _buildQuickActionItem(
                          icon: Icons.help_outline,
                          label: 'Help',
                          color: Colors.purple[700]!,
                          onTap: () {},
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Features carousel
                    Text(
                      'App Features',
                      style: AppStyles.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildFeaturesCarousel(),
                    const SizedBox(height: 24),

                    // Local fishing regulations
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Local Fishing Regulations',
                                style: AppStyles.titleMedium.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Always check local regulations before fishing.',
                            style: AppStyles.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 80,
                    ), // Bottom spacing for FAB and navigation
                  ],
                ),
              ),

              // Floating action button for emergency
              Positioned(
                right: 16,
                bottom: 80,
                child: FloatingActionButton(
                  backgroundColor: Colors.red,
                  child: const Icon(Icons.sos_outlined),
                  onPressed: () {},
                ),
              ),
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: Colors.grey,
            type: BottomNavigationBarType.fixed,
            onTap: (index) {
              // Only update if the index is 0 (home)
              // Other tabs not implemented
              if (index == 0) {
                setState(() {
                  _currentIndex = index;
                });
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('This feature is coming soon!'),
                    duration: Duration(seconds: 1),
                  ),
                );
              }
            },
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.map_outlined),
                activeIcon: Icon(Icons.map),
                label: 'Map',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.add_circle_outline),
                activeIcon: Icon(Icons.add_circle),
                label: 'Report',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          ),
        );
      },
    );
  }
}
