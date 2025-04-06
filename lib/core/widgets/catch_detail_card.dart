import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/fish_catch_model.dart';

class CatchDetailCard extends StatelessWidget {
  final FishCatchModel catchData;

  const CatchDetailCard({Key? key, required this.catchData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Content section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Fish species and timestamp
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        catchData.fishSpecies,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      DateFormat(
                        'MMM dd, yyyy • hh:mm a',
                      ).format(catchData.timestamp),
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Quantity and Net Type
                Row(
                  children: [
                    _buildInfoChip(
                      Icons.scale,
                      '${catchData.quantityInQuintal} quintals',
                      Colors.blue[100]!,
                    ),
                    const SizedBox(width: 10),
                    _buildInfoChip(
                      Icons.grid_on,
                      '${catchData.netType} net',
                      Colors.green[100]!,
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Sustainability indicator
                Row(
                  children: [
                    Icon(
                      catchData.isSustainable
                          ? Icons.check_circle
                          : Icons.warning,
                      color:
                          catchData.isSustainable
                              ? Colors.green
                              : Colors.orange,
                      size: 20,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      catchData.isSustainable ? 'Sustainable' : 'Warning',
                      style: TextStyle(
                        color:
                            catchData.isSustainable
                                ? Colors.green
                                : Colors.orange,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        const Icon(
                          Icons.emoji_events,
                          color: Colors.amber,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '+${catchData.pointsAwarded}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [Icon(icon, size: 16), const SizedBox(width: 6), Text(label)],
      ),
    );
  }
}
