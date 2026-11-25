import 'package:flutter/material.dart';

class SpeedControl extends StatelessWidget {
  final double rpm;

  final double maximumRpm;

  final bool enabled;

  final ValueChanged<double> onChanged;

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
    final safeRpm = rpm.clamp(
      0.0,
      maximumRpm,
    ).toDouble();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.stretch,

          children: [
            const Text(
              'Commanded Speed',

              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              '${safeRpm.round()} RPM',
              textAlign: TextAlign.center,

              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),

            Slider(
              value: safeRpm,
              min: 0,
              max: maximumRpm,
              divisions: 60,

              label: '${safeRpm.round()} RPM',

              onChanged: enabled
                  ? onChanged
                  : null,

              onChangeEnd: enabled
                  ? onChangeEnd
                  : null,
            ),

            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,

              children: [
                const Text('0'),

                Text(
                  '${maximumRpm.round()} RPM',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}