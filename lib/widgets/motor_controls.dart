import 'package:flutter/material.dart';

class MotorControls extends StatelessWidget {
  final bool running;

  final bool enabled;

  final bool startAllowed;

  final VoidCallback onStart;
  final VoidCallback onStop;

  const MotorControls({
    super.key,
    required this.running,
    required this.enabled,
    this.startAllowed = true,
    required this.onStart,
    required this.onStop,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),

        child: Column(
          children: [
            Text(
              running ? 'RUNNING' : 'STOPPED',

              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,

                color: running
                    ? Colors.green
                    : Colors.orange,
              ),
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed:
                        enabled &&
                                startAllowed &&
                                !running
                            ? onStart
                            : null,

                    icon: const Icon(
                      Icons.play_arrow,
                    ),

                    label: const Text('START'),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: enabled && running
                        ? onStop
                        : null,

                    icon: const Icon(Icons.stop),

                    label: const Text('STOP'),
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