// Flutter Material Design package
import 'package:flutter/material.dart';

// Reusable card for displaying VFD measurements
class MeasurementCard extends StatelessWidget {

  // Measurement name
  final String title;

  // Measurement value
  final String value;

  // Measurement unit
  final String unit;

  // Icon shown above the measurement
  final IconData icon;

  const MeasurementCard({
    super.key,
    required this.title,
    required this.value,
    required this.unit,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {

    // Card that displays one measurement
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [

            // Measurement icon
            Icon(
              icon,
              size: 28,
            ),

            const SizedBox(height: 8),

            // Measurement title
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 6),

            // Measurement value
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),

            // Measurement unit
            Text(
              unit,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}