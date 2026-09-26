// Used to convert JSON data
import 'dart:convert';

// Used to generate demo values
import 'dart:math';

// HTTP package for ESP32 communication
import 'package:http/http.dart' as http;

// VFD status model
import '../models/vfd_status.dart';

// Handles communication between the app and ESP32
class Esp32Service {

  // ESP32 IP address
  final String baseUrl;

  // Enables demo mode for testing
  final bool demoMode;

  // HTTP client used for network requests
  final http.Client _client = http.Client();

  // Stores the current demo VFD status
  VfdStatus _demoStatus = VfdStatus.initial().copyWith(
    connected: true,
    dcLinkVoltage: 48.0,
  );

  Esp32Service({
    this.baseUrl = "http://192.168.4.1",
    this.demoMode = true,
  });

  // Gets the current VFD status
  Future<VfdStatus> getStatus() async {

    // Uses simulated data in demo mode
    if (demoMode) {
      return _getDemoStatus();
    }

    // ESP32 status endpoint
    final uri = Uri.parse(
      "$baseUrl/api/status",
    );

    // Sends GET request to the ESP32
    final response = await _client
        .get(uri)
        .timeout(
          const Duration(seconds: 2),
        );

    // Checks for a successful response
    if (response.statusCode != 200) {
      throw Exception(
        "ESP32 returned status code ${response.statusCode}",
      );
    }

    // Converts JSON response into Dart data
    final Map<String, dynamic> json =
        jsonDecode(response.body)
            as Map<String, dynamic>;

    // Converts JSON data into a VfdStatus object
    return VfdStatus.fromJson(json);
  }

  // --------------------------------------------------
  // DEMO CONTROLS
  // --------------------------------------------------

  // Starts the motor in demo mode
  Future<void> requestStart() async {

    if (demoMode) {

      // Prevents starting while a fault is active
      if (_demoStatus.faultActive) {
        throw Exception(
          "Cannot start while a fault is active.",
        );
      }

      _demoStatus = _demoStatus.copyWith(
        running: true,
      );

      return;
    }

    // Live control will be added later
    throw UnsupportedError(
      "Live Start control is not enabled yet. "
      "Connect this only after your ESP32/dsPIC command protocol "
      "and safety interlocks are finalized.",
    );
  }

  // Stops the motor in demo mode
  Future<void> requestStop() async {

    if (demoMode) {
      _demoStatus = _demoStatus.copyWith(
        running: false,
        actualRpm: 0,
      );

      return;
    }

    // Live control will be added later
    throw UnsupportedError(
      "Live Stop control has not been connected to the hardware API yet.",
    );
  }

  // Changes the commanded motor speed
  Future<void> setSpeed(double rpm) async {

    if (demoMode) {
      _demoStatus = _demoStatus.copyWith(
        commandedRpm: rpm,
      );

      return;
    }

    // Live speed control will be added later
    throw UnsupportedError(
      "Live speed commands have not been enabled yet.",
    );
  }

  // Changes the motor direction
  Future<void> setDirection(
    String direction,
  ) async {

    // Checks for a valid direction
    if (direction != "forward" &&
        direction != "reverse") {
      throw ArgumentError(
        "Direction must be 'forward' or 'reverse'.",
      );
    }

    if (demoMode) {
      _demoStatus = _demoStatus.copyWith(
        direction: direction,
      );

      return;
    }

    // Live direction control will be added later
    throw UnsupportedError(
      "Live direction commands have not been enabled yet.",
    );
  }

  // Resets the active fault in demo mode
  Future<void> resetFault() async {

    if (demoMode) {
      _demoStatus = _demoStatus.copyWith(
        faultActive: false,
        faultCode: 0,
        faultDescription: "No fault",
      );

      return;
    }

    // Live fault reset will be added later
    throw UnsupportedError(
      "Live fault reset has not been enabled yet.",
    );
  }

  // Changes the operating mode
  Future<void> setOperatingMode(
    String mode,
  ) async {

    if (demoMode) {
      _demoStatus = _demoStatus.copyWith(
        operatingMode: mode,
      );

      return;
    }

    // Live mode control will be added later
    throw UnsupportedError(
      "Live operating-mode commands have not been enabled yet.",
    );
  }

  // --------------------------------------------------
  // DEMO SIMULATION
  // --------------------------------------------------

  // Creates simulated VFD measurements
  VfdStatus _getDemoStatus() {

    final random = Random();

    double actualRpm =
        _demoStatus.actualRpm;

    // Simulates RPM while the motor is running
    if (_demoStatus.running) {

      final error =
          _demoStatus.commandedRpm -
          _demoStatus.actualRpm;

      // Moves actual RPM toward commanded RPM
      actualRpm += error * 0.25;

      // Adds a small amount of RPM variation
      actualRpm +=
          random.nextDouble() * 4 - 2;

      if (actualRpm < 0) {
        actualRpm = 0;
      }

    } else {

      // Reduces RPM when the motor is stopped
      actualRpm *= 0.5;

      if (actualRpm < 1) {
        actualRpm = 0;
      }
    }

    // Simulated motor current
    final current =
        _demoStatus.running
            ? 1.5 +
                random.nextDouble() * 0.5
            : 0.0;

    // Simulated estimated torque
    final torque =
        _demoStatus.running
            ? 1.0 +
                random.nextDouble() * 0.3
            : 0.0;

    // Simulated DC-link voltage
    final voltage =
        47.5 + random.nextDouble();

    // Updates the demo VFD status
    _demoStatus = _demoStatus.copyWith(
      connected: true,
      actualRpm: actualRpm,
      motorCurrent: current,
      dcLinkVoltage: voltage,
      estimatedTorque: torque,
    );

    return _demoStatus;
  }

  // Closes the HTTP client
  void dispose() {
    _client.close();
  }
}