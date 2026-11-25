import 'package:flutter/material.dart';

import '../models/fault_history_entry.dart';
import '../models/vfd_fault.dart';
import '../models/vfd_status.dart';

import '../services/esp32_service.dart';
import '../widgets/session_notice.dart';

class FaultsScreen extends StatelessWidget {
  final Esp32Service service;

  final List<FaultHistoryEntry> history;

  final VoidCallback onActiveFaultPressed;

  VfdStatus get status =>
      service.latestStatus ?? VfdStatus.initial();

  const FaultsScreen({
    super.key,
    required this.service,
    required this.history,
    required this.onActiveFaultPressed,
  });

  @override
  Widget build(BuildContext context) =>
      ListenableBuilder(
        listenable: service,

        builder: (context, _) {
          if (!service.hasMeasurements) {
            return SessionNotice(
              service: service,
              title: 'Faults',
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
          'Faults',
          style: Theme.of(context)
              .textTheme
              .headlineSmall
              ?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),

        const SizedBox(height: 16),

        _buildActiveFault(),

        const SizedBox(height: 24),

        Text(
          'Fault History',
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),

        const SizedBox(height: 10),

        if (history.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(20),

              child: Text(
                'No fault history recorded.',
                textAlign: TextAlign.center,
              ),
            ),
          )
        else
          ...history.map(
            (entry) => _buildHistoryItem(entry),
          ),
      ],
    );
  }

  // Active fault card

  Widget _buildActiveFault() {
    if (!status.faultActive) {
      return const Card(
        child: ListTile(
          leading: Icon(
            Icons.check_circle,
            color: Colors.green,
          ),

          title: Text('No Active Fault'),

          subtitle: Text(
            'The controller is not currently '
            'reporting a fault.',
          ),
        ),
      );
    }

    final fault = VfdFault.fromCode(
      status.faultCode,
      controllerDescription:
          status.faultDescription,
    );

    return Card(
      color: Colors.red.shade900,

      child: ListTile(
        onTap: onActiveFaultPressed,

        leading: const Icon(
          Icons.warning_amber,
          size: 36,
        ),

        title: Text(
          "F${fault.code.toString().padLeft(2, '0')}"
          ' - ${fault.name}',

          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        subtitle: Text(fault.description),

        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }

  // Individual fault history entry

  Widget _buildHistoryItem(
    FaultHistoryEntry entry,
  ) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.history),

        title: Text(
          'Fault ${entry.code}: '
          '${entry.description}',
        ),

        subtitle: Text(
          '${_formatTime(entry.time)}\n'
          'Command: ${entry.commandedRpm.round()} RPM | '
          'Actual: ${entry.actualRpm.round()} RPM',
        ),

        isThreeLine: true,
      ),
    );
  }

  String _formatTime(DateTime time) {
    final hour =
        time.hour.toString().padLeft(2, '0');

    final minute =
        time.minute.toString().padLeft(2, '0');

    final second =
        time.second.toString().padLeft(2, '0');

    return '$hour:$minute:$second';
  }
}