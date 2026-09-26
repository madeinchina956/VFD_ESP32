// Flutter Material Design package
import 'package:flutter/material.dart';

// Reusable widget for adjusting commanded motor speed
class SpeedControl extends StatelessWidget {

  // Current RPM value
  final double rpm;

  // Maximum allowed RPM
  final double maximumRpm;

  // Enables or disables the speed control
  final bool enabled;

  // Updates RPM while moving the slider
  final ValueChanged<double> onChanged;

  // Sends the final RPM value after the slider is released
  final ValueChanged<double> onChangeEnd;

  const SpeedControl({
    super.key,
    required this.rpm,
    required this.onChanged,
    required this.onChangeEnd,
    required this.enabled,
    this.maximumRpm = 3000,
  });

  @override
  Widget build(BuildContext context) {

    // Keeps RPM within the allowed range
    final safeRpm = rpm.clamp(
      0.0,
      maximumRpm,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            // Section title
            const Text(
              "Commanded Speed",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            // Displays the selected RPM
            Text(
              "${safeRpm.round()} RPM",
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),

            // RPM adjustment slider
            Slider(
              value: safeRpm,
              min: 0,
              max: maximumRpm,
              divisions: 60,
              label: "${safeRpm.round()} RPM",

              // Updates while moving the slider
              onChanged: enabled ? onChanged : null,

              // Sends final RPM after slider is released
              onChangeEnd: enabled ? onChangeEnd : null,
            ),

            // Shows minimum and maximum RPM values
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("0"),
                Text("${maximumRpm.round()} RPM"),
              ],
            ),
          ],
        ),
      ),
    );
  }
}