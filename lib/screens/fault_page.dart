// Flutter Material Design package
import 'package:flutter/material.dart';

// Fault information model
import '../models/vfd_fault.dart';

// Current VFD status model
import '../models/vfd_status.dart';

// Displays detailed information about the active fault
class FaultPage extends StatelessWidget {

  // Current VFD status
  final VfdStatus status;

  // Callback used to request a fault reset
  final Future<void> Function() onReset;

  const FaultPage({
    super.key,
    required this.status,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {

    // Gets the full fault information from the fault code
    final fault = VfdFault.fromCode(
      status.faultCode,
      controllerDescription: status.faultDescription,
    );

    return Scaffold(

      // Page title
      appBar: AppBar(
        title: const Text("Fault Information"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            // Warning icon
            const Icon(
              Icons.warning_amber_rounded,
              size: 80,
              color: Colors.red,
            ),

            const SizedBox(height: 20),

            // Fault code
            Text(
              "FAULT ${fault.code}",
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            // Fault name
            Text(
              fault.name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 30),

            // Fault description label
            const Text(
              "Description",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            // Fault description
            Text(fault.description),

            const SizedBox(height: 25),

            // Recommended action label
            const Text(
              "Recommended Action",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            // Recommended action for the user
            Text(fault.action),

            const Spacer(),

            // Fault reset button
            ElevatedButton.icon(
              onPressed: () async {
                try {

                  // Sends the fault reset request
                  await onReset();

                  // Returns to the previous screen after reset
                  if (context.mounted) {
                    Navigator.pop(context);
                  }

                } catch (e) {

                  // Shows an error message if reset fails
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(e.toString()),
                      ),
                    );
                  }
                }
              },

              icon: const Icon(Icons.restart_alt),

              label: const Text(
                "REQUEST FAULT RESET",
              ),
            ),
          ],
        ),
      ),
    );
  }
}