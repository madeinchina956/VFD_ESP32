// Flutter Material Design package
import 'package:flutter/material.dart';

// Reusable Start and Stop control widget
class MotorControls extends StatelessWidget {

  // Shows whether the motor is currently running
  final bool running;

  // Enables or disables the motor controls
  final bool enabled;

  // Start and Stop callbacks
  final VoidCallback onStart;
  final VoidCallback onStop;

  const MotorControls({
    super.key,
    required this.running,
    required this.enabled,
    required this.onStart,
    required this.onStop,
  });

  @override
  Widget build(BuildContext context) {

    // Card that contains motor status and controls
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),

        child: Column(
          children: [

            // Shows current motor state
            Text(
              running ? "RUNNING" : "STOPPED",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: running ? Colors.green : Colors.orange,
              ),
            ),

            const SizedBox(height: 20),

            // Start and Stop buttons
            Row(
              children: [

                // Start button
                Expanded(
                  child: ElevatedButton.icon(

                    // Only enabled when controls are active
                    // and the motor is stopped
                    onPressed:
                        enabled && !running ? onStart : null,

                    icon: const Icon(
                      Icons.play_arrow,
                    ),

                    label: const Text(
                      "START",
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // Stop button
                Expanded(
                  child: ElevatedButton.icon(

                    // Only enabled when controls are active
                    // and the motor is running
                    onPressed:
                        enabled && running ? onStop : null,

                    icon: const Icon(
                      Icons.stop,
                    ),

                    label: const Text(
                      "STOP",
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}