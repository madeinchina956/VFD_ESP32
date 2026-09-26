// Used for the repeating status timer
import 'dart:async';

// Flutter Material Design package
import 'package:flutter/material.dart';

// Stores previous fault events
import '../models/fault_history_entry.dart';

// Current VFD status model
import '../models/vfd_status.dart';

// Handles ESP32 communication and demo mode
import '../services/esp32_service.dart';

// Main app screens
import 'control_screen.dart';
import 'dashboard_screen.dart';
import 'fault_page.dart';
import 'faults_screen.dart';
import 'settings_screen.dart';

// Main page for the VFD application
class VfdHomePage extends StatefulWidget {
  const VfdHomePage({
    super.key,
  });

  @override
  State<VfdHomePage> createState() {
    return _VfdHomePageState();
  }
}

// Controls the main app state and navigation
class _VfdHomePageState extends State<VfdHomePage> {

  // ESP32 address
  static const String controllerAddress =
      "http://192.168.4.1";

  // Keeps the app in demo mode
  static const bool demoMode = true;

  // ESP32 service
  late final Esp32Service _service;

  // Current VFD status
  VfdStatus _status =
      VfdStatus.initial();

  // Stores recent fault history
  final List<FaultHistoryEntry> _faultHistory = [];

  // Timer used to update VFD status
  Timer? _pollTimer;

  // Current selected navigation screen
  int _selectedIndex = 0;

  // Prevents multiple commands at the same time
  bool _busy = false;

  // RPM selected by the user
  double _requestedRpm = 0;

  @override
  void initState() {
    super.initState();

    // Starts the ESP32 service
    _service = Esp32Service(
      baseUrl: controllerAddress,
      demoMode: demoMode,
    );

    // Gets the first VFD status
    _refreshStatus();

    // Updates the VFD status every second
    _pollTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) {
        _refreshStatus();
      },
    );
  }

  @override
  void dispose() {

    // Stops the status timer
    _pollTimer?.cancel();

    // Closes the ESP32 service
    _service.dispose();

    super.dispose();
  }

  // Gets the latest VFD status
  Future<void> _refreshStatus() async {
    try {
      final newStatus =
          await _service.getStatus();

      // Stops if the screen is no longer active
      if (!mounted) {
        return;
      }

      // Records a new fault when it appears
      if (newStatus.faultActive &&
          (!_status.faultActive ||
              newStatus.faultCode !=
                  _status.faultCode)) {

        _faultHistory.insert(
          0,
          FaultHistoryEntry(
            code: newStatus.faultCode,
            description:
                newStatus.faultDescription,
            time: DateTime.now(),
            commandedRpm:
                newStatus.commandedRpm,
            actualRpm:
                newStatus.actualRpm,
          ),
        );

        // Keeps only the latest 20 faults
        if (_faultHistory.length > 20) {
          _faultHistory.removeLast();
        }
      }

      // Updates the displayed VFD status
      setState(() {
        _status = newStatus;

        // Updates RPM when no command is being processed
        if (!_busy) {
          _requestedRpm =
              newStatus.commandedRpm;
        }
      });

    } catch (e) {

      if (!mounted) {
        return;
      }

      // Marks the VFD as disconnected if status fails
      setState(() {
        _status = _status.copyWith(
          connected: false,
        );
      });
    }
  }

  // Runs a VFD command
  Future<void> _runCommand(
    Future<void> Function() command,
  ) async {

    // Stops another command from starting
    if (_busy) {
      return;
    }

    setState(() {
      _busy = true;
    });

    try {

      // Runs the selected command
      await command();

      // Updates the VFD status after the command
      await _refreshStatus();

    } catch (e) {

      if (!mounted) {
        return;
      }

      // Shows command errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString(),
          ),
        ),
      );

    } finally {

      if (mounted) {
        setState(() {
          _busy = false;
        });
      }
    }
  }

  // Sends a speed command
  Future<void> _setSpeed(
    double rpm,
  ) async {
    await _runCommand(
      () => _service.setSpeed(rpm),
    );
  }

  // Sends a Start request
  Future<void> _start() async {
    await _runCommand(
      _service.requestStart,
    );
  }

  // Sends a Stop request
  Future<void> _stop() async {
    await _runCommand(
      _service.requestStop,
    );
  }

  // Changes motor direction
  Future<void> _setDirection(
    String direction,
  ) async {
    await _runCommand(
      () => _service.setDirection(
        direction,
      ),
    );
  }

  // Changes the operating mode
  Future<void> _setOperatingMode(
    String mode,
  ) async {
    await _runCommand(
      () => _service.setOperatingMode(
        mode,
      ),
    );
  }

  // Sends a fault reset request
  Future<void> _resetFault() async {
    await _runCommand(
      _service.resetFault,
    );
  }

  // Opens the fault details screen
  void _openFaultDetails() {

    // Only opens if a fault is active
    if (!_status.faultActive) {
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return FaultPage(
            status: _status,
            onReset: _resetFault,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    // Enables controls only when the VFD is available
    final controlsEnabled =
        _status.connected &&
            !_status.faultActive &&
            !_busy;

    // Main app screens
    final screens = [

      // Dashboard screen
      DashboardScreen(
        status: _status,
        onFaultPressed:
            _openFaultDetails,
      ),

      // Control screen
      ControlScreen(
        status: _status,
        requestedRpm:
            _requestedRpm,
        controlsEnabled:
            controlsEnabled,

        // Updates RPM while moving the slider
        onSpeedChanged: (value) {
          setState(() {
            _requestedRpm = value;
          });
        },

        // Sends the final RPM command
        onSpeedSubmitted:
            _setSpeed,

        // Direction control
        onDirectionChanged:
            _setDirection,

        // Operating mode control
        onModeChanged:
            _setOperatingMode,

        // Start and Stop controls
        onStart:
            _start,

        onStop:
            _stop,
      ),

      // Fault screen
      FaultsScreen(
        status: _status,
        history:
            _faultHistory,
        onActiveFaultPressed:
            _openFaultDetails,
      ),

      // Settings screen
      SettingsScreen(
        status: _status,
        controllerAddress:
            controllerAddress,
        demoMode:
            demoMode,
      ),
    ];

    return Scaffold(

      // Main app title
      appBar: AppBar(
        title: const Text(
          "VFD Controller",
        ),
      ),

      // Keeps each screen loaded while switching tabs
      body: IndexedStack(
        index: _selectedIndex,
        children: screens,
      ),

      // Bottom navigation bar
      bottomNavigationBar:
          NavigationBar(

        // Current selected tab
        selectedIndex:
            _selectedIndex,

        // Changes the selected screen
        onDestinationSelected:
            (index) {
          setState(() {
            _selectedIndex =
                index;
          });
        },

        destinations: const [

          // Dashboard tab
          NavigationDestination(
            icon: Icon(
              Icons.dashboard_outlined,
            ),
            selectedIcon: Icon(
              Icons.dashboard,
            ),
            label: "Dashboard",
          ),

          // Control tab
          NavigationDestination(
            icon: Icon(
              Icons.tune_outlined,
            ),
            selectedIcon: Icon(
              Icons.tune,
            ),
            label: "Control",
          ),

          // Faults tab
          NavigationDestination(
            icon: Icon(
              Icons.warning_amber_outlined,
            ),
            selectedIcon: Icon(
              Icons.warning,
            ),
            label: "Faults",
          ),

          // Settings tab
          NavigationDestination(
            icon: Icon(
              Icons.settings_outlined,
            ),
            selectedIcon: Icon(
              Icons.settings,
            ),
            label: "Settings",
          ),
        ],
      ),
    );
  }
}