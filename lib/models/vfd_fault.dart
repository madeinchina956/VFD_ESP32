// Stores information about one VFD fault
class VfdFault {

  // Fault code
  final int code;

  // Fault name
  final String name;

  // Fault description
  final String description;

  // Recommended action
  final String action;

  const VfdFault({
    required this.code,
    required this.name,
    required this.description,
    required this.action,
  });

  // List of known VFD fault codes
  static const Map<int, VfdFault> catalog = {

    // No fault
    0: VfdFault(
      code: 0,
      name: "No Fault",
      description: "The drive is not reporting a fault.",
      action: "No action required.",
    ),

    // DC-link undervoltage fault
    1: VfdFault(
      code: 1,
      name: "DC-Link Undervoltage",
      description: "The controller reported a DC-link voltage fault.",
      action:
          "Keep the drive stopped and have the system inspected according to the team's approved test procedure.",
    ),

    // DC-link overvoltage fault
    2: VfdFault(
      code: 2,
      name: "DC-Link Overvoltage",
      description: "The controller reported a DC-link overvoltage fault.",
      action:
          "Keep the drive stopped and have the system inspected according to the team's approved test procedure.",
    ),

    // Motor overcurrent fault
    3: VfdFault(
      code: 3,
      name: "Motor Overcurrent",
      description: "The controller reported excessive motor current.",
      action:
          "Keep the drive stopped and have the motor-control system inspected by the project team.",
    ),

    // Overtemperature fault
    4: VfdFault(
      code: 4,
      name: "Overtemperature",
      description: "The controller reported an excessive temperature.",
      action:
          "Keep the drive stopped until the system has been inspected by the project team.",
    ),

    // Overspeed fault
    5: VfdFault(
      code: 5,
      name: "Overspeed",
      description: "The controller reported a speed outside its permitted range.",
      action:
          "Keep the drive stopped and verify the controller configuration during supervised testing.",
    ),

    // Sensor or feedback fault
    6: VfdFault(
      code: 6,
      name: "Sensor Fault",
      description: "A required feedback signal is missing or invalid.",
      action:
          "Keep the drive stopped and inspect the feedback system using the team's approved procedure.",
    ),

    // Communication fault
    7: VfdFault(
      code: 7,
      name: "Communication Fault",
      description:
          "Communication between VFD system components was interrupted.",
      action:
          "Keep controls disabled until communication has been restored.",
    ),

    // General drive hardware fault
    8: VfdFault(
      code: 8,
      name: "Drive Fault",
      description: "The motor controller reported a hardware-related fault.",
      action:
          "Keep the drive stopped and have the motor-control hardware inspected.",
    ),

    // Emergency Stop fault
    9: VfdFault(
      code: 9,
      name: "Emergency Stop",
      description: "The system reports that an emergency stop is active.",
      action:
          "The mobile app must not override the emergency-stop condition.",
    ),
  };

  // Finds fault information using a fault code
  static VfdFault fromCode(
    int code, {
    String? controllerDescription,
  }) {

    // Looks for the fault in the catalog
    final knownFault = catalog[code];

    // Returns the known fault if found
    if (knownFault != null) {
      return knownFault;
    }

    // Returns a default fault if the code is unknown
    return VfdFault(
      code: code,
      name: "Unknown Fault",
      description:
          controllerDescription ?? "An unknown controller fault was reported.",
      action:
          "Keep controls disabled until the project team identifies the fault.",
    );
  }
}