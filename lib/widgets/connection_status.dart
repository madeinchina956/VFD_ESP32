// Flutter Material Design package
import 'package:flutter/material.dart';

// Shows whether the VFD is connected
class ConnectionStatus extends StatelessWidget {

  // Current connection state
  final bool connected;

  const ConnectionStatus({
    super.key,
    required this.connected,
  });

  @override
  Widget build(BuildContext context) {

    // Displays connection icon and text
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [

        // Wi-Fi icon changes based on connection
        Icon(
          connected ? Icons.wifi : Icons.wifi_off,
          color: connected ? Colors.green : Colors.red,
        ),

        const SizedBox(width: 6),

        // Connection status text
        Text(
          connected ? "Connected" : "Disconnected",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: connected ? Colors.green : Colors.red,
          ),
        ),
      ],
    );
  }
}