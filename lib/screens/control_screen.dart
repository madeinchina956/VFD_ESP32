import 'package:flutter/material.dart';

import '../models/vfd_status.dart';
import '../services/esp32_service.dart';

import '../widgets/session_notice.dart';
import '../widgets/motor_controls.dart';
import '../widgets/speed_control.dart';

class ControlScreen extends StatelessWidget {
  final Esp32Service service;

  final double requestedRpm;

  final bool controlsEnabled;

  final ValueChanged<double> onSpeedChanged;
  final ValueChanged<double> onSpeedSubmitted;

  final ValueChanged<String> onDirectionChanged;
  final ValueChanged<String> onModeChanged;

  final VoidCallback onStart;
  final VoidCallback onStop;

  VfdStatus get status =>
      service.latestStatus ?? VfdStatus.initial();

  bool get _enabled =>
      controlsEnabled && service.canUseDemoControls;

  bool get _settingsEnabled =>
      _enabled && !status.faultActive;

  const ControlScreen({
    super.key,
    required this.service,
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
  Widget build(BuildContext context) =>
      ListenableBuilder(
        listenable: service,

        builder: (context, _) {
          if (!service.hasMeasurements) {
            return SessionNotice(
              service: service,
              title: 'Motor Control',
            );
          }

          return _buildAuthorized(context);
        },
      );

  Widget _buildAuthorized(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),

      children: [
        Text(
          'Motor Control',
          style: Theme.of(context)
              .textTheme
              .headlineSmall
              ?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),

        const SizedBox(height: 6),

        Text(
          _enabled
              ? 'SIMULATION ONLY — adjust the demo command below.'
              : 'Controls are unavailable or busy. '
                'Live operation is not enabled in this build.',
        ),

        const SizedBox(height: 16),

        SpeedControl(
          rpm: requestedRpm,
          maximumRpm: 3000,
          enabled: _settingsEnabled,
          onChanged: onSpeedChanged,
          onChangeEnd: onSpeedSubmitted,
        ),

        const SizedBox(height: 16),

        _buildDirectionControl(),

        const SizedBox(height: 16),

        _buildModeControl(),

        const SizedBox(height: 16),

        MotorControls(
          running: status.running,
          enabled: _enabled,
          startAllowed: !status.faultActive,
          onStart: onStart,
          onStop: onStop,
        ),
      ],
    );
  }

  // Direction selector

  Widget _buildDirectionControl() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.stretch,

          children: [
            const Text(
              'Direction',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 14),

            Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    label: const Text('Forward'),

                    selected:
                        status.direction == 'forward',

                    onSelected: _settingsEnabled
                        ? (_) =>
                            onDirectionChanged('forward')
                        : null,
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: ChoiceChip(
                    label: const Text('Reverse'),

                    selected:
                        status.direction == 'reverse',

                    onSelected: _settingsEnabled
                        ? (_) =>
                            onDirectionChanged('reverse')
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

  // Operating mode selector

  Widget _buildModeControl() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
            const Text(
              'Operating Mode',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            DropdownButtonFormField<String>(
              key: ValueKey(status.operatingMode),

              initialValue:
                  const ['speed', 'manual']
                          .contains(status.operatingMode)
                      ? status.operatingMode
                      : null,

              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),

              items: const [
                DropdownMenuItem(
                  value: 'speed',
                  child: Text('Speed Control'),
                ),

                DropdownMenuItem(
                  value: 'manual',
                  child: Text('Manual'),
                ),
              ],

              onChanged: _settingsEnabled
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