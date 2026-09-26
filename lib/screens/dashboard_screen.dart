// Flutter Material Design package
import 'package:flutter/material.dart';

// VFD status model
import '../models/vfd_status.dart';

// Shows Wi-Fi connection status
import '../widgets/connection_status.dart';

// Shows active fault information
import '../widgets/fault_banner.dart';

// Reusable card for measurements
import '../widgets/measurement_card.dart';

// Dashboard screen for monitoring VFD operation
class DashboardScreen extends StatelessWidget {

  // Current VFD status
  final VfdStatus status;

  // Opens fault details when a fault is pressed
  final VoidCallback onFaultPressed;

  const DashboardScreen({
    super.key,
    required this.status,
    required this.onFaultPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),

      children: [

        // Dashboard title and connection status
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "VFD Dashboard",
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),

            ConnectionStatus(
              connected: status.connected,
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Shows fault banner only if a fault is active
        if (status.faultActive) ...[
          FaultBanner(
            faultCode: status.faultCode,
            description: status.faultDescription,
            onPressed: onFaultPressed,
          ),

          const SizedBox(height: 16),
        ],

        // Actual and commanded motor speed
        Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 28,
              horizontal: 20,
            ),

            child: Column(
              children: [

                const Text(
                  "ACTUAL MOTOR SPEED",
                  style: TextStyle(
                    letterSpacing: 2,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  status.actualRpm.round().toString(),
                  style: const TextStyle(
                    fontSize: 52,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const Text(
                  "RPM",
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  "Commanded: ${status.commandedRpm.round()} RPM",
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Motor current and DC-link voltage
        Row(
          children: [
            Expanded(
              child: MeasurementCard(
                title: "Motor Current",
                value: status.motorCurrent.toStringAsFixed(2),
                unit: "A",
                icon: Icons.electric_bolt,
              ),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: MeasurementCard(
                title: "DC Link",
                value: status.dcLinkVoltage.toStringAsFixed(1),
                unit: "V",
                icon: Icons.battery_charging_full,
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        // Estimated torque and motor direction
        Row(
          children: [
            Expanded(
              child: MeasurementCard(
                title: "Torque",
                value: status.estimatedTorque.toStringAsFixed(2),
                unit: "N·m",
                icon: Icons.settings,
              ),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: MeasurementCard(
                title: "Direction",
                value: status.direction.toUpperCase(),
                unit: "",
                icon: Icons.sync_alt,
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // System status card
        _buildStatusCard(context),
      ],
    );
  }

  // Builds the system status card
  Widget _buildStatusCard(BuildContext context) {
    String text;
    IconData icon;
    Color color;

    // Sets status text, icon, and color
    if (!status.connected) {
      text = "DISCONNECTED";
      icon = Icons.wifi_off;
      color = Colors.red;
    } else if (status.faultActive) {
      text = "FAULT";
      icon = Icons.warning;
      color = Colors.red;
    } else if (status.running) {
      text = "RUNNING";
      icon = Icons.play_arrow;
      color = Colors.green;
    } else {
      text = "READY";
      icon = Icons.check_circle;
      color = Colors.blue;
    }

    return Card(
      child: ListTile(

        // Status icon
        leading: Icon(
          icon,
          color: color,
          size: 32,
        ),

        // Status label
        title: const Text(
          "System Status",
        ),

        // Current system state
        trailing: Text(
          text,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ),
    );
  }
}