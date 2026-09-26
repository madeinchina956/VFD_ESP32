// Flutter Material Design package
import 'package:flutter/material.dart';

// Displays a warning banner when a fault is active
class FaultBanner extends StatelessWidget {

  // Current fault code
  final int faultCode;

  // Fault description
  final String description;

  // Opens the fault details page
  final VoidCallback onPressed;

  const FaultBanner({
    super.key,
    required this.faultCode,
    required this.description,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {

    // Red card used to highlight an active fault
    return Card(
      color: Colors.red.shade900,

      // Makes the fault banner clickable
      child: InkWell(
        onTap: onPressed,

        child: Padding(
          padding: const EdgeInsets.all(16),

          child: Row(
            children: [

              // Warning icon
              const Icon(
                Icons.warning_amber_rounded,
                size: 36,
              ),

              const SizedBox(width: 14),

              // Fault code and description
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // Fault code
                    Text(
                      "FAULT $faultCode",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 4),

                    // Fault description
                    Text(description),
                  ],
                ),
              ),

              // Shows that the banner can be opened
              const Icon(
                Icons.chevron_right,
              ),
            ],
          ),
        ),
      ),
    );
  }
}