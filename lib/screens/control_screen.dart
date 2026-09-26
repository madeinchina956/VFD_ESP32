//Flutter Material Design package
//Provides widgets such as Text, Card, Row, and Column
import 'package:flutter/material.dart';

//VFD status model
import '../models/vfd_status.dart';

//Reusable widget for Start and Stop buttons
import '../widgets/motor_controls.dart';

//Reusable widget for adjusting commanded motor speed
import '../widgets/speed_control.dart';

//Control screen for motor operation
//Keeps the UI separate from the communication logic
class ControlScreen extends StatelessWidget {

  //Current VFD status
  final VfdStatus status;

  //RPM selected by the user
  final double requestedRpm;

  //Enables or disables motor controls
  final bool controlsEnabled;

  //Speed control callbacks
  final ValueChanged<double> onSpeedChanged;
  final ValueChanged<double> onSpeedSubmitted;

  //Direction and mode callbacks
  final ValueChanged<String> onDirectionChanged;
  final ValueChanged<String> onModeChanged;

  //Start and Stop callbacks
  final VoidCallback onStart;
  final VoidCallback onStop;

  const ControlScreen({
    super.key,
    required this.status,
    required this.requestedRpm,
    required this.controlsEnabled,
    required this.onSpeedChanged,
    required this.onSpeedSubmitted,
    required this.onDirectionChanged,
    required this.onModeChanged,
    required this.onStart,
    required this.onStop,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [

        //Screen title
        Text(
          "Motor Control",
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),

        const SizedBox(height: 6),

        //Shows whether controls are available
        Text(
          controlsEnabled
              ? "Adjust the operating command below."
              : "Controls are currently unavailable.",
        ),

        const SizedBox(height: 16),

        //Motor speed control
        SpeedControl(
          rpm: requestedRpm,
          maximumRpm: 3000,
          enabled: controlsEnabled,
          onChanged: onSpeedChanged,
          onChangeEnd: onSpeedSubmitted,
        ),

        const SizedBox(height: 16),

        //Direction control
        _buildDirectionControl(),

        const SizedBox(height: 16),

        //Operating mode control
        _buildModeControl(),

        const SizedBox(height: 16),

        //Start and Stop buttons
        MotorControls(
          running: status.running,
          enabled: controlsEnabled,
          onStart: onStart,
          onStop: onStop,
        ),
      ],
    );
  }

  //Builds Forward and Reverse controls
  Widget _buildDirectionControl() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            const Text(
              "Direction",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 14),

            Row(
              children: [

                // Forward direction
                Expanded(
                  child: ChoiceChip(
                    label: const Text("Forward"),
                    selected: status.direction == "forward",
                    onSelected: controlsEnabled
                        ? (_) => onDirectionChanged("forward")
                        : null,
                  ),
                ),

                const SizedBox(width: 10),

                // Reverse direction
                Expanded(
                  child: ChoiceChip(
                    label: const Text("Reverse"),
                    selected: status.direction == "reverse",
                    onSelected: controlsEnabled
                        ? (_) => onDirectionChanged("reverse")
                        : null,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  //Builds the operating mode dropdown
  Widget _buildModeControl() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const Text(
              "Operating Mode",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            // Operating mode selection
            DropdownButtonFormField<String>(
              initialValue: status.operatingMode,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              items: const [

                DropdownMenuItem(
                  value: "speed",
                  child: Text("Speed Control"),
                ),

                DropdownMenuItem(
                  value: "manual",
                  child: Text("Manual"),
                ),
              ],
              onChanged: controlsEnabled
                  ? (value) {
                      if (value != null) {
                        onModeChanged(value);
                      }
                    }
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}