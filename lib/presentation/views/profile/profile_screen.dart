import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_styles.dart';
import '../../viewmodels/auth_viewmodel.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isEnglish = true;
  bool _isLoggingOut = false;

  // Localization strings
  late final Map<String, Map<String, String>> _localizedStrings;

  @override
  void initState() {
    super.initState();
    _localizedStrings = {
      'en': {
        'myProfile': 'My Profile',
        'user': 'User',
        'notSet': 'Not Set',
        'personalInformation': 'Personal Information',
        'fullName': 'Full Name',
        'mobileNumber': 'Mobile Number',
        'fishingLicenseNumber': 'Fishing License Number',
        'emergencyContact': 'Emergency Contact',
        'appSettings': 'App Settings',
        'language': 'Language',
        'english': 'English',
        'tamil': 'தமிழ்',
        'termsConditions': 'Terms & Conditions',
        'privacyPolicy': 'Privacy Policy',
        'aboutCoastalMate': 'About Meenavar Thunai',
        'logOut': 'Log Out',
        'loggingOut': 'Logging Out...',
        'confirmLogout': 'Confirm Logout',
        'logoutConfirmation': 'Are you sure you want to log out?',
        'cancel': 'Cancel',
        'logout': 'Logout',
        'failedToLogout': 'Failed to logout',
      },
      'ta': {
        'myProfile': 'என் சுயவிவரம்',
        'user': 'பயனர்',
        'notSet': 'அமைக்கப்படவில்லை',
        'personalInformation': 'தனிப்பட்ட தகவல்',
        'fullName': 'முழு பெயர்',
        'mobileNumber': 'மொபைல் எண்',
        'fishingLicenseNumber': 'மீன்பிடி உரிமம் எண்',
        'emergencyContact': 'அவசர தொடர்பு',
        'appSettings': 'ஆப்ஸ் அமைப்புகள்',
        'language': 'மொழி',
        'english': 'English',
        'tamil': 'தமிழ்',
        'termsConditions': 'விதிமுறைகள் & நிபந்தனைகள்',
        'privacyPolicy': 'தனியுரிமை கொள்கை',
        'aboutCoastalMate': 'கடலோர துணை பற்றி',
        'logOut': 'வெளியேறு',
        'loggingOut': 'வெளியேறுகிறது...',
        'confirmLogout': 'வெளியேறுவதை உறுதிப்படுத்தவும்',
        'logoutConfirmation': 'நீங்கள் நிச்சயமாக வெளியேற விரும்புகிறீர்களா?',
        'cancel': 'ரத்து செய்',
        'logout': 'வெளியேறு',
        'failedToLogout': 'வெளியேற முடியவில்லை',
      },
    };
  }

  String _getText(String key) {
    final lang = _isEnglish ? 'en' : 'ta';
    return _localizedStrings[lang]?[key] ?? key;
  }

  Future<void> _handleLogout() async {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);

    setState(() {
      _isLoggingOut = true;
    });

    try {
      bool? shouldLogout = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(_getText('confirmLogout')),
            content: Text(_getText('logoutConfirmation')),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(_getText('cancel')),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(foregroundColor: AppColors.error),
                child: Text(_getText('logout')),
              ),
            ],
          );
        },
      );

      if (shouldLogout == true) {
        await authViewModel.signOut();
        if (mounted) {
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil('/login', (route) => false);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_getText('failedToLogout')}: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoggingOut = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);
    final user = authViewModel.user;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          _getText('myProfile'),
          style: AppStyles.titleLarge.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: AppColors.primaryLight,
                        child:
                            user?.photoURL != null
                                ? ClipRRect(
                                  borderRadius: BorderRadius.circular(60),
                                  child: Image.network(
                                    user!.photoURL!,
                                    width: 120,
                                    height: 120,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) => Text(
                                          user.displayName
                                                  ?.substring(0, 1)
                                                  .toUpperCase() ??
                                              'U',
                                          style: AppStyles.headlineLarge
                                              .copyWith(
                                                color: AppColors.primary,
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                  ),
                                )
                                : Text(
                                  user?.displayName
                                          ?.substring(0, 1)
                                          .toUpperCase() ??
                                      'U',
                                  style: AppStyles.headlineLarge.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: InkWell(
                            onTap: () {},
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user?.displayName ?? _getText('user'),
                    style: AppStyles.titleLarge.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.email ?? 'email@example.com',
                    style: AppStyles.bodyMedium.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            _buildSectionTitle(_getText('personalInformation')),
            const SizedBox(height: 16),
            _buildInfoCard(
              Icons.person,
              _getText('fullName'),
              user?.displayName ?? _getText('notSet'),
              onTap: () {},
            ),
            _buildInfoCard(
              Icons.phone,
              _getText('mobileNumber'),
              '+91 98765 43210',
              onTap: () {},
            ),
            _buildInfoCard(
              Icons.card_membership,
              _getText('fishingLicenseNumber'),
              'FL-12345-2025',
              onTap: () {},
            ),
            _buildInfoCard(
              Icons.emergency,
              _getText('emergencyContact'),
              '+91 98765 12345',
              onTap: () {},
            ),
            const SizedBox(height: 32),
            _buildSectionTitle(_getText('appSettings')),
            const SizedBox(height: 16),
            _buildLanguageSelector(),
            _buildSettingsCard(
              Icons.description,
              _getText('termsConditions'),
              onTap: () {},
            ),
            _buildSettingsCard(
              Icons.privacy_tip,
              _getText('privacyPolicy'),
              onTap: () {},
            ),
            _buildSettingsCard(
              Icons.info,
              _getText('aboutCoastalMate'),
              onTap: () {},
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoggingOut ? null : _handleLogout,
                icon:
                    _isLoggingOut
                        ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                        : const Icon(Icons.logout, color: Colors.white),
                label: Text(
                  _isLoggingOut ? _getText('loggingOut') : _getText('logOut'),
                  style: AppStyles.titleLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppStyles.titleMedium.copyWith(
        fontWeight: FontWeight.bold,
        color: AppColors.primary,
      ),
    );
  }

  Widget _buildInfoCard(
    IconData icon,
    String title,
    String value, {
    required VoidCallback onTap,
  }) {
    return _buildCustomCard(
      onTap: onTap,
      children: [
        Icon(icon, color: AppColors.primary),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppStyles.bodyMedium.copyWith(color: Colors.grey[600]),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: AppStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        Icon(Icons.chevron_right, color: Colors.grey[400]),
      ],
    );
  }

  Widget _buildLanguageSelector() {
    return _buildCustomCard(
      children: [
        Icon(Icons.language, color: AppColors.primary),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getText('language'),
                style: AppStyles.bodyMedium.copyWith(color: Colors.grey[600]),
              ),
              const SizedBox(height: 4),
              Text(
                _isEnglish ? _getText('english') : _getText('tamil'),
                style: AppStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: _isEnglish,
          onChanged: (value) {
            setState(() {
              _isEnglish = value;
            });
          },
          activeColor: AppColors.primary,
        ),
      ],
    );
  }

  Widget _buildSettingsCard(
    IconData icon,
    String title, {
    required VoidCallback onTap,
  }) {
    return _buildCustomCard(
      onTap: onTap,
      children: [
        Icon(icon, color: AppColors.primary),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            title,
            style: AppStyles.bodyLarge.copyWith(fontWeight: FontWeight.w500),
          ),
        ),
        Icon(Icons.chevron_right, color: Colors.grey[400]),
      ],
    );
  }

  Widget _buildCustomCard({
    VoidCallback? onTap,
    required List<Widget> children,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: Colors.grey[50],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: children),
        ),
      ),
    );
  }
}
