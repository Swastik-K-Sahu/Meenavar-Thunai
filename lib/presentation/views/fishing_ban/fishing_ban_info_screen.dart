import 'package:flutter/material.dart';
import '../../../../../theme/app_colors.dart';
import '../../../../../theme/app_styles.dart';

class FishingBanInfoScreen extends StatelessWidget {
  const FishingBanInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Fishing Ban Information',
          style: AppStyles.titleMedium.copyWith(
            color: AppColors.lightGrey,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Why Fishing Bans Are Important',
              style: AppStyles.headlineSmall.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoSection(
              title: 'Conservation Efforts',
              description:
                  'Fishing bans during breeding seasons allow fish populations to replenish naturally. This ensures sustainable fishing for future generations.',
              imagePath: 'assets/images/conservation_effect.png',
            ),
            const SizedBox(height: 24),
            _buildInfoSection(
              title: 'Effects of Overfishing',
              description:
                  'Overfishing disrupts marine ecosystems, reduces biodiversity, and threatens food security for coastal communities that depend on fishing for livelihood.',
              imagePath: 'assets/images/effect_overfishing.jpg',
            ),
            const SizedBox(height: 24),
            Text(
              'Alternative Income Sources',
              style: AppStyles.titleLarge.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 16),
            _buildAlternativeIncomeCard(
              title: 'Aquaculture',
              description:
                  'Fish farming and aquaculture provide sustainable income during ban periods. Training programs are available through local fisheries departments.',
              icon: Icons.water,
            ),
            const SizedBox(height: 12),
            _buildAlternativeIncomeCard(
              title: 'Eco-Tourism',
              description:
                  'Guide tourists for marine wildlife viewing, fishing spots, and coastal tours. This helps promote conservation while generating income.',
              icon: Icons.landscape,
            ),
            const SizedBox(height: 12),
            _buildAlternativeIncomeCard(
              title: 'Net Repair & Boat Maintenance',
              description:
                  'Utilize the off-season to repair nets, maintain boats, and upgrade fishing equipment to improve efficiency for the next season.',
              icon: Icons.handyman,
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.backgroundWhite,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Get Support',
                    style: AppStyles.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Contact your local Fisheries Department for financial assistance programs and training opportunities during the fishing ban period.',
                    style: AppStyles.bodyMedium.copyWith(
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Contact Support'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection({
    required String title,
    required String description,
    required String imagePath,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Image.asset(
              imagePath,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[300],
                  child: const Center(
                    child: Icon(Icons.image_not_supported, size: 50),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          title,
          style: AppStyles.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          description,
          style: AppStyles.bodyMedium.copyWith(color: AppColors.textDark),
        ),
      ],
    );
  }

  Widget _buildAlternativeIncomeCard({
    required String title,
    required String description,
    required IconData icon,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: AppColors.primary, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppStyles.titleSmall.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: AppStyles.bodyMedium.copyWith(
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
