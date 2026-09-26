// Flutter Material Design package
import 'package:flutter/material.dart';

// Current VFD status model
import '../models/vfd_status.dart';

// Settings screen for connection and app information
class SettingsScreen extends StatelessWidget {

  // Current VFD status
  final VfdStatus status;

  // ESP32 controller address
  final String controllerAddress;

  // Shows whether the app is in demo or live mode
  final bool demoMode;

  const SettingsScreen({
    super.key,
    required this.status,
    required this.controllerAddress,
    required this.demoMode,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),

      children: [

        // Screen title
        Text(
          "Settings",
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),

        const SizedBox(height: 16),

        // Connection information
        Card(
          child: Column(
            children: [

              // Shows connection status
              ListTile(
                leading: Icon(
                  status.connected
                      ? Icons.wifi
                      : Icons.wifi_off,
                ),

                title: const Text(
                  "Connection Status",
                ),

                trailing: Text(
                  status.connected
                      ? "Connected"
                      : "Disconnected",
                ),
              ),

              const Divider(height: 1),

              // Shows the ESP32 controller address
              ListTile(
                leading: const Icon(
                  Icons.router,
                ),

                title: const Text(
                  "Controller Address",
                ),

                trailing: Text(
                  controllerAddress,
                ),
              ),

              const Divider(height: 1),

              // Shows Demo or Live application mode
              ListTile(
                leading: const Icon(
                  Icons.developer_mode,
                ),

                title: const Text(
                  "Application Mode",
                ),

                trailing: Text(
                  demoMode ? "Demo" : "Live",
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Software and firmware information
        const Card(
          child: Column(
            children: [

              // VFD firmware version
              ListTile(
                leading: Icon(
                  Icons.memory,
                ),

                title: Text(
                  "Firmware Version",
                ),

                trailing: Text(
                  "TBD",
                ),
              ),

              Divider(height: 1),

              // Mobile application version
              ListTile(
                leading: Icon(
                  Icons.phone_android,
                ),

                title: Text(
                  "Application Version",
                ),

                trailing: Text(
                  "0.1.0",
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Project information
        const Card(
          child: ListTile(
            leading: Icon(
              Icons.info_outline,
            ),

            title: Text(
              "VFD Controller",
            ),

            subtitle: Text(
              "ECEN Capstone Group 71",
            ),
          ),
        ),
      ],
    );
  }
}