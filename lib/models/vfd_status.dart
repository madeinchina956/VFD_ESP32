// Stores the current VFD operating status
class VfdStatus {

  // Connection and running state
  final bool connected;
  final bool running;

  // Commanded and actual motor speed
  final double commandedRpm;
  final double actualRpm;

  // Measured motor values
  final double motorCurrent;
  final double dcLinkVoltage;
  final double estimatedTorque;

  // Motor direction and operating mode
  final String direction;
  final String operatingMode;

  // Fault information
  final bool faultActive;
  final int faultCode;
  final String faultDescription;

  const VfdStatus({
    required this.connected,
    required this.running,
    required this.commandedRpm,
    required this.actualRpm,
    required this.motorCurrent,
    required this.dcLinkVoltage,
    required this.estimatedTorque,
    required this.direction,
    required this.operatingMode,
    required this.faultActive,
    required this.faultCode,
    required this.faultDescription,
  });

  // Creates the default VFD status
  factory VfdStatus.initial() {
    return const VfdStatus(
      connected: false,
      running: false,
      commandedRpm: 0,
      actualRpm: 0,
      motorCurrent: 0,
      dcLinkVoltage: 0,
      estimatedTorque: 0,
      direction: "forward",
      operatingMode: "speed",
      faultActive: false,
      faultCode: 0,
      faultDescription: "No fault",
    );
  }

  // Creates a VfdStatus object from ESP32 JSON data
  factory VfdStatus.fromJson(Map<String, dynamic> json) {
    return VfdStatus(
      connected: true,
      running: _toBool(json["running"]),
      commandedRpm: _toDouble(json["commanded_rpm"]),
      actualRpm: _toDouble(json["actual_rpm"]),
      motorCurrent: _toDouble(json["motor_current"]),
      dcLinkVoltage: _toDouble(json["dc_link_voltage"]),
      estimatedTorque: _toDouble(json["estimated_torque"]),
      direction: json["direction"]?.toString() ?? "forward",
      operatingMode: json["mode"]?.toString() ?? "speed",
      faultActive: _toBool(json["fault_active"]),
      faultCode: _toInt(json["fault_code"]),
      faultDescription:
          json["fault_description"]?.toString() ?? "No fault",
    );
  }

  // Creates a new status while keeping unchanged values
  VfdStatus copyWith({
    bool? connected,
    bool? running,
    double? commandedRpm,
    double? actualRpm,
    double? motorCurrent,
    double? dcLinkVoltage,
    double? estimatedTorque,
    String? direction,
    String? operatingMode,
    bool? faultActive,
    int? faultCode,
    String? faultDescription,
  }) {
    return VfdStatus(
      connected: connected ?? this.connected,
      running: running ?? this.running,
      commandedRpm: commandedRpm ?? this.commandedRpm,
      actualRpm: actualRpm ?? this.actualRpm,
      motorCurrent: motorCurrent ?? this.motorCurrent,
      dcLinkVoltage: dcLinkVoltage ?? this.dcLinkVoltage,
      estimatedTorque: estimatedTorque ?? this.estimatedTorque,
      direction: direction ?? this.direction,
      operatingMode: operatingMode ?? this.operatingMode,
      faultActive: faultActive ?? this.faultActive,
      faultCode: faultCode ?? this.faultCode,
      faultDescription: faultDescription ?? this.faultDescription,
    );
  }

  // Converts a value into a double
  static double _toDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value?.toString() ?? "") ?? 0.0;
  }

  // Converts a value into an integer
  static int _toInt(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(value?.toString() ?? "") ?? 0;
  }

  // Converts a value into a boolean
  static bool _toBool(dynamic value) {
    if (value is bool) {
      return value;
    }

    if (value is num) {
      return value != 0;
    }

    final text = value?.toString().toLowerCase();

    return text == "true" || text == "1";
  }
}