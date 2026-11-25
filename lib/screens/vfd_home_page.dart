import 'dart:async';

import 'package:flutter/material.dart';

import '../models/fault_history_entry.dart';
import '../models/vfd_status.dart';
import '../services/esp32_service.dart';

import 'control_screen.dart';
import 'dashboard_screen.dart';
import 'fault_page.dart';
import 'faults_screen.dart';
import 'settings_screen.dart';

class VfdHomePage extends StatefulWidget {
  const VfdHomePage({super.key});

  @override
  State<VfdHomePage> createState() =>
      _VfdHomePageState();
}

class _VfdHomePageState extends State<VfdHomePage>
    with WidgetsBindingObserver {

  static const String controllerAddress =
      'http://192.168.4.1';

  // Keep simulation enabled.
  static const bool demoMode = false;

  late final Esp32Service _service;

  VfdStatus _status = VfdStatus.initial();

  final List<FaultHistoryEntry> _faultHistory = [];

  Timer? _pollTimer;

  int _selectedIndex = 0;

  bool _busy = false;
  bool _foreground = true;
  bool _polling = false;
  bool _editingSpeed = false;

  double _requestedRpm = 0;

  @override
  void initState() {
    super.initState();

    _service = Esp32Service(
      baseUrl: controllerAddress,
      demoMode: demoMode,
    );

    _service.addListener(_sessionChanged);

    WidgetsBinding.instance.addObserver(this);

    _startPolling();
  }

  // Polls once every second.

  void _startPolling() {
    _pollTimer?.cancel();

    _refreshStatus();

    _pollTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) {
        _refreshStatus();
      },
    );
  }

  // Invalidates access when the app enters
  // the background.

  @override
  void didChangeAppLifecycleState(
    AppLifecycleState state,
  ) {
    if (state == AppLifecycleState.resumed) {
      _foreground = true;

      _startPolling();
    } else if (_foreground) {
      _foreground = false;

      _pollTimer?.cancel();

      _service.invalidateAccess();
    }
  }

  @override
  void dispose() {
    _pollTimer?.cancel();

    WidgetsBinding.instance.removeObserver(this);

    _service.removeListener(_sessionChanged);

    _service.dispose();

    super.dispose();
  }

  // Updates all screens using the shared service.

  void _sessionChanged() {
    if (!mounted) return;

    final next = _service.latestStatus;

    setState(() {
      // Clears previous data if access is lost.

      if (next == null || !next.connected) {
        _status = VfdStatus.initial();

        _faultHistory.clear();

        _requestedRpm = 0;
        _editingSpeed = false;

        return;
      }

      // Records newly reported faults.

      if (next.faultActive &&
          (!_status.faultActive ||
              next.faultCode != _status.faultCode)) {
        _faultHistory.insert(
          0,
          FaultHistoryEntry(
            code: next.faultCode,
            description: next.faultDescription,
            time: DateTime.now(),
            commandedRpm: next.commandedRpm,
            actualRpm: next.actualRpm,
          ),
        );

        if (_faultHistory.length > 20) {
          _faultHistory.removeLast();
        }
      }

      _status = next;

      if (!_editingSpeed) {
        _requestedRpm = next.commandedRpm;
      }
    });
  }

  // Prevents overlapping polling requests.

  Future<void> _refreshStatus() async {
    if (!_foreground || _polling || !mounted) {
      return;
    }

    _polling = true;

    try {
      await _service.getStatus();
    } finally {
      _polling = false;
    }
  }

  // Executes authorized simulation commands only.

  Future<void> _runCommand(
    Future<void> Function() command, {
    bool propagateError = false,
  }) async {
    if (_busy ||
        !_foreground ||
        !_service.canUseDemoControls) {
      if (propagateError) {
        throw StateError(
          'Demo controls unavailable',
        );
      }

      return;
    }

    setState(() {
      _busy = true;
    });

    try {
      await command();

      await _refreshStatus();
    } catch (e) {
      if (propagateError) rethrow;

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
        });
      }
    }
  }

  Future<void> _setSpeed(double rpm) async {
    if (!mounted) return;

    setState(() {
      _editingSpeed = false;
    });

    await _runCommand(
      () => _service.setSpeed(rpm),
    );
  }

  Future<void> _start() =>
      _runCommand(_service.requestStart);

  Future<void> _stop() =>
      _runCommand(_service.requestStop);

  Future<void> _setDirection(String direction) =>
      _runCommand(
        () => _service.setDirection(direction),
      );

  Future<void> _setOperatingMode(String mode) =>
      _runCommand(
        () => _service.setOperatingMode(mode),
      );

  Future<void> _resetFault() =>
      _runCommand(
        _service.resetFault,
        propagateError: true,
      );

  // Opens fault information only while authorized.

  void _openFaultDetails() {
    if (!_service.hasMeasurements ||
        !_status.faultActive) {
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FaultPage(
          service: _service,
          onReset: _resetFault,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controlsEnabled =
        _foreground &&
        _service.canUseDemoControls &&
        !_busy;

    final screens = [
      DashboardScreen(
        service: _service,
        onFaultPressed: _openFaultDetails,
      ),

      ControlScreen(
        service: _service,
        requestedRpm: _requestedRpm,
        controlsEnabled: controlsEnabled,

        onSpeedChanged: (value) {
          if (!controlsEnabled ||
              !_service.canUseDemoControls) {
            return;
          }

          setState(() {
            _editingSpeed = true;
            _requestedRpm = value;
          });
        },

        onSpeedSubmitted: _setSpeed,
        onDirectionChanged: _setDirection,
        onModeChanged: _setOperatingMode,
        onStart: _start,
        onStop: _stop,
      ),

      FaultsScreen(
        service: _service,
        history: _faultHistory,
        onActiveFaultPressed: _openFaultDetails,
      ),

      SettingsScreen(
        service: _service,
        controllerAddress: controllerAddress,
        demoMode: demoMode,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('VFD Controller'),
      ),

      body: IndexedStack(
        index: _selectedIndex,
        children: screens,
      ),

      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,

        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },

        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),

          NavigationDestination(
            icon: Icon(Icons.tune_outlined),
            selectedIcon: Icon(Icons.tune),
            label: 'Control',
          ),

          NavigationDestination(
            icon: Icon(Icons.warning_amber_outlined),
            selectedIcon: Icon(Icons.warning),
            label: 'Faults',
          ),

          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}