import 'package:flutter/material.dart';

import '../services/esp32_service.dart';
import '../services/session_access.dart';

class SessionNotice extends StatelessWidget {
  final Esp32Service service;
  final String title;

  const SessionNotice({
    super.key,
    required this.service,
    required this.title,
  });

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),

      child: Column(
        mainAxisSize: MainAxisSize.min,

        children: [
          Text(
            title,
            style: Theme.of(context)
                .textTheme.headlineSmall,
          ),

          const SizedBox(height: 20),

          const Icon(
            Icons.lock_outline,
            size: 48,
          ),

          const SizedBox(height: 12),

          Text(
            service.working
                ? 'Updating session…'
                : service.access.label,
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 8),

          Text(
            service.access == SessionAccess.authorized
                ? 'Waiting for an authorized measurement.'
                : 'Open Settings to check or request access. '
                  'Measurements and controls are unavailable.',
            textAlign: TextAlign.center,
          ),

          if (service.message != null) ...[
            const SizedBox(height: 8),

            Text(
              service.message!,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    ),
  );
}