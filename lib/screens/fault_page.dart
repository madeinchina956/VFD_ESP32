import 'package:flutter/material.dart';

import '../models/vfd_fault.dart';
import '../models/vfd_status.dart';

import '../services/esp32_service.dart';
import '../widgets/session_notice.dart';

class FaultPage extends StatelessWidget {
  final Esp32Service service;

  final Future<void> Function() onReset;

  VfdStatus get status =>
      service.latestStatus ?? VfdStatus.initial();

  const FaultPage({
    super.key,
    required this.service,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) =>
      ListenableBuilder(
        listenable: service,

        builder: (context, _) {
          if (!service.hasMeasurements) {
            return Scaffold(
              appBar: AppBar(
                title: const Text(
                  'Fault Information',
                ),
              ),

              body: SessionNotice(
                service: service,
                title: 'Fault Information',
              ),
            );
          }

          return _buildAuthorized(context);
        },
      );

  Widget _buildAuthorized(BuildContext context) {
    if (!status.faultActive) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Fault Information'),
        ),

        body: const Center(
          child: Text(
            'No active fault in the current session.',
          ),
        ),
      );
    }

    final fault = VfdFault.fromCode(
      status.faultCode,

      controllerDescription:
          status.faultDescription,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fault Information'),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.stretch,

          children: [
            const Icon(
              Icons.warning_amber_rounded,
              size: 80,
              color: Colors.red,
            ),

            const SizedBox(height: 20),

            Text(
              'FAULT ${fault.code}',
              textAlign: TextAlign.center,

              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              fault.name,
              textAlign: TextAlign.center,

              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 30),

            const Text(
              'Description',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            Text(fault.description),

            const SizedBox(height: 25),

            const Text(
              'Recommended Action',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            Text(fault.action),

            const Spacer(),

            // Simulation-only fault reset.

            ElevatedButton.icon(
              onPressed: service.canUseDemoControls
                  ? () async {
                      try {
                        if (!service.canUseDemoControls) {
                          return;
                        }

                        await onReset();

                        if (context.mounted) {
                          Navigator.pop(context);
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(
                            SnackBar(
                              content: Text(
                                e.toString(),
                              ),
                            ),
                          );
                        }
                      }
                    }
                  : null,

              icon: const Icon(Icons.restart_alt),

              label: const Text(
                'REQUEST FAULT RESET',
              ),
            ),
          ],
        ),
      ),
    );
  }
}