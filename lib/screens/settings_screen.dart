import 'package:flutter/material.dart';

import '../services/esp32_service.dart';
import '../services/session_access.dart';

class SettingsScreen extends StatelessWidget {
  final Esp32Service service;

  final String controllerAddress;

  final bool demoMode;

  const SettingsScreen({
    super.key,
    required this.service,
    required this.controllerAddress,
    required this.demoMode,
  });

  @override
  Widget build(BuildContext context) =>
      ListenableBuilder(
        listenable: service,
        builder: (context, _) =>
            _buildSettings(context),
      );

  Widget _buildSettings(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),

      children: [
        Text(
          'Settings',
          style: Theme.of(context)
              .textTheme
              .headlineSmall
              ?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),

        const SizedBox(height: 16),

        // Connection information

        Card(
          child: Column(
            children: [
              ListTile(
                leading: Icon(
                  service.access !=
                          SessionAccess.disconnected
                      ? Icons.wifi
                      : Icons.wifi_off,
                ),

                title: const Text(
                  'Connection Status',
                ),

                trailing: Text(
                  service.access !=
                          SessionAccess.disconnected
                      ? 'Controller reachable'
                      : 'Unavailable',
                ),
              ),

              const Divider(height: 1),

              ListTile(
                leading: const Icon(Icons.router),

                title: const Text(
                  'Controller Address',
                ),

                trailing: Text(controllerAddress),
              ),

              const Divider(height: 1),

              ListTile(
                leading: const Icon(
                  Icons.developer_mode,
                ),

                title: const Text(
                  'Application Mode',
                ),

                trailing: Text(
                  demoMode ? 'Demo' : 'Live',
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // WIRELESS SESSION ACCESS

        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),

            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.stretch,

              children: [
                Text(
                  'Wireless access',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge,
                ),

                const SizedBox(height: 8),

                Text(service.access.label),

                if (service.message != null)
                  Text(service.message!),

                const SizedBox(height: 8),

                // Simulated local selector.

                if (service.demoMode) ...[
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,

                    title: const Text(
                      'Simulate local source selector',
                    ),

                    subtitle: Text(
                      service.demoRemote
                          ? 'REMOTE (simulation)'
                          : 'LOCAL (simulation)',
                    ),

                    value: service.demoRemote,

                    onChanged: service.working
                        ? null
                        : service.setDemoRemote,
                  ),

                  const Text(
                    'Demo switch changes only simulated '
                    'ownership. It does not change '
                    'the physical VFD.',
                  ),
                ] else
                  const Text(
                    'Source selection belongs to the '
                    'local controller. This app supports '
                    'authorized monitoring only.',
                  ),

                const SizedBox(height: 12),

                // REQUEST ACCESS

                FilledButton.icon(
                  onPressed: !service.working &&
                          service.access ==
                              SessionAccess.available
                      ? () async {
                          await service.requestAccess();
                        }
                      : null,

                  icon: const Icon(Icons.vpn_key),

                  label: const Text(
                    'REQUEST ACCESS',
                  ),
                ),

                // RELEASE ACCESS

                OutlinedButton.icon(
                  onPressed: !service.working &&
                          service.access ==
                              SessionAccess.authorized
                      ? () async {
                          await service.releaseAccess();
                        }
                      : null,

                  icon: const Icon(Icons.logout),

                  label: const Text(
                    'RELEASE ACCESS',
                  ),
                ),

                if (service.working)
                  const LinearProgressIndicator(),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Firmware and application information

        const Card(
          child: Column(
            children: [
              ListTile(
                leading: Icon(Icons.memory),

                title: Text('Firmware Version'),

                trailing: Text('TBD'),
              ),

              Divider(height: 1),

              ListTile(
                leading: Icon(Icons.phone_android),

                title: Text('Application Version'),

                trailing: Text('0.1.0'),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Capstone project information

        const Card(
          child: ListTile(
            leading: Icon(Icons.info_outline),

            title: Text('VFD Controller'),

            subtitle: Text(
              'ECEN Capstone Group 71',
            ),
          ),
        ),
      ],
    );
  }
}