// utils/constants.dart
class AppConstants {
  // Race types
  static const String triathlon = 'triathlon';
  static const String marathon = 'marathon';
  static const String cycling = 'cycling';
  static const String swimming = 'swimming';
  static const String aquathlon = 'aquathlon';
  static const String runAndBike = 'run_and_bike';

  // Segment names
  static const String swim = 'swim';
  static const String cycle = 'cycle';
  static const String run = 'run';

  // User roles
  static const String raceManager = 'race_manager';
  static const String timeTracker = 'time_tracker';

  // Default segments
  static const Map<String, List<Map<String, dynamic>>> defaultSegments = {
    triathlon: [
      {'name': swim, 'distance': '100m', 'order': 1},
      {'name': cycle, 'distance': '10km', 'order': 2},
      {'name': run, 'distance': '5km', 'order': 3},
    ],
    aquathlon: [
      {'name': swim, 'distance': '100m', 'order': 1},
      {'name': run, 'distance': '5km', 'order': 2},
    ],
    runAndBike: [
      {'name': run, 'distance': '5km', 'order': 1},
      {'name': cycle, 'distance': '20km', 'order': 2},
    ],
    marathon: [
      {'name': run, 'distance': '42.2km', 'order': 1},
    ],
    cycling: [
      {'name': cycle, 'distance': '40km', 'order': 1},
    ],
    swimming: [
      {'name': swim, 'distance': '1500m', 'order': 1},
    ],
  };

  // Error messages
  static const String networkError =
      'Network error. Please check your connection.';
  static const String authError = 'Authentication failed. Please try again.';
  static const String genericError = 'An error occurred. Please try again.';
  static const String permissionError =
      'Permission denied. Please contact an administrator.';

  // Success messages
  static const String raceCreated = 'Race created successfully';
  static const String raceUpdated = 'Race updated successfully';
  static const String raceDeleted = 'Race deleted successfully';
  static const String participantCreated = 'Participant added successfully';
  static const String participantUpdated = 'Participant updated successfully';
  static const String participantDeleted = 'Participant deleted successfully';
  static const String timeTracked = 'Time tracked successfully';
  static const String timeUntracked = 'Time untracked successfully';

  // Validation rules
  static const int minNameLength = 2;
  static const int maxNameLength = 50;
  static const int minAge = 1;
  static const int maxAge = 150;
  static const int bibNumberLength = 3;

  // Time formatting
  static const String timeFormat = 'HH:mm:ss';
  static const String dateFormat = 'dd/MM/yyyy';
  static const String dateTimeFormat = 'dd/MM/yyyy HH:mm';
}
