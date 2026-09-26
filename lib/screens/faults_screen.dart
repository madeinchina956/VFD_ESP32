// Flutter Material Design package
import 'package:flutter/material.dart';

// Stores previous fault events
import '../models/fault_history_entry.dart';

// Fault information model
import '../models/vfd_fault.dart';

// Current VFD status model
import '../models/vfd_status.dart';

// Screen for active faults and fault history
class FaultsScreen extends StatelessWidget {

  // Current VFD status
  final VfdStatus status;

  // List of previous faults
  final List<FaultHistoryEntry> history;

  // Opens the active fault details
  final VoidCallback onActiveFaultPressed;

  const FaultsScreen({
    super.key,
    required this.status,
    required this.history,
    required this.onActiveFaultPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),

      children: [

        // Screen title
        Text(
          "Faults",
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),

        const SizedBox(height: 16),

        // Shows the current active fault
        _buildActiveFault(),

        const SizedBox(height: 24),

        // Fault history title
        Text(
          "Fault History",
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),

        const SizedBox(height: 10),

        // Shows a message if no faults have been recorded
        if (history.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                "No fault history recorded.",
                textAlign: TextAlign.center,
              ),
            ),
          )

        // Displays all recorded faults
        else
          ...history.map(
            (entry) => _buildHistoryItem(entry),
          ),
      ],
    );
  }

  // Builds the active fault section
  Widget _buildActiveFault() {

    // Shows normal status when there is no active fault
    if (!status.faultActive) {
      return const Card(
        child: ListTile(
          leading: Icon(
            Icons.check_circle,
            color: Colors.green,
          ),

          title: Text(
            "No Active Fault",
          ),

          subtitle: Text(
            "The controller is not currently reporting a fault.",
          ),
        ),
      );
    }

    // Gets fault information using the current fault code
    final fault = VfdFault.fromCode(
      status.faultCode,
      controllerDescription: status.faultDescription,
    );

    // Active fault card
    return Card(
      color: Colors.red.shade900,

      child: ListTile(

        // Opens the detailed fault page
        onTap: onActiveFaultPressed,

        leading: const Icon(
          Icons.warning_amber,
          size: 36,
        ),

        // Fault code and name
        title: Text(
          "F${fault.code.toString().padLeft(2, '0')} - ${fault.name}",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        // Fault description
        subtitle: Text(
          fault.description,
        ),

        trailing: const Icon(
          Icons.chevron_right,
        ),
      ),
    );
  }

  // Builds one fault history entry
  Widget _buildHistoryItem(
    FaultHistoryEntry entry,
  ) {
    return Card(
      child: ListTile(

        leading: const Icon(
          Icons.history,
        ),

        // Fault number and description
        title: Text(
          "Fault ${entry.code}: ${entry.description}",
        ),

        // Time and motor speed when the fault occurred
        subtitle: Text(
          "${_formatTime(entry.time)}\n"
          "Command: ${entry.commandedRpm.round()} RPM | "
          "Actual: ${entry.actualRpm.round()} RPM",
        ),

        isThreeLine: true,
      ),
    );
  }

  // Formats the fault time as HH:MM:SS
  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, "0");
    final minute = time.minute.toString().padLeft(2, "0");
    final second = time.second.toString().padLeft(2, "0");

    return "$hour:$minute:$second";
  }
}