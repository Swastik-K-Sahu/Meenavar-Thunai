import 'package:flutter/material.dart';
import '../../presentation/viewmodels/fish_catch_viewmodel.dart';

class SustainabilityAlertDialog extends StatelessWidget {
  final SustainabilityCheck sustainabilityCheck;

  const SustainabilityAlertDialog({
    super.key,
    required this.sustainabilityCheck,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(
            sustainabilityCheck.isSustainable
                ? Icons.check_circle
                : Icons.warning,
            color:
                sustainabilityCheck.isSustainable
                    ? Colors.green
                    : Colors.orange,
          ),
          const SizedBox(width: 10),
          Text(
            sustainabilityCheck.isSustainable
                ? 'Sustainable Catch!'
                : 'Sustainability Warning',
            style: TextStyle(
              color:
                  sustainabilityCheck.isSustainable
                      ? Colors.green
                      : Colors.orange,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (sustainabilityCheck.warnings.isNotEmpty) ...[
            const Text(
              'Please consider the following:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ...sustainabilityCheck.warnings.map(
              (warning) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.orange,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Text(warning)),
                  ],
                ),
              ),
            ),
          ] else ...[
            const Text('This catch follows sustainable fishing practices.'),
          ],
          const SizedBox(height: 15),
          Row(
            children: [
              const Icon(Icons.emoji_events, color: Colors.amber),
              const SizedBox(width: 8),
              Text(
                'Points awarded: ${sustainabilityCheck.pointsAwarded}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Got it'),
        ),
      ],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
  }
}
