// Stores information about one recorded fault
class FaultHistoryEntry {

  // Fault code
  final int code;

  // Fault description
  final String description;

  // Time when the fault occurred
  final DateTime time;

  // Commanded RPM when the fault occurred
  final double commandedRpm;

  // Actual RPM when the fault occurred
  final double actualRpm;

  const FaultHistoryEntry({
    required this.code,
    required this.description,
    required this.time,
    required this.commandedRpm,
    required this.actualRpm,
  });
}