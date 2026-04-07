import 'package:talker_flutter/talker_flutter.dart';

// Setup and configure the global Talker instance
Talker setupLogger() {
  return TalkerFlutter.init(
    settings: TalkerSettings(
      // Enable console logs
      useConsoleLogs: true,
      // Keep track of the logs history
      useHistory: true,
      // Limit the history size to prevent memory leaks
      maxHistoryItems: 100,
    ),
    logger: TalkerLogger(
      settings: TalkerLoggerSettings(
        // Use colors in the console output
        enableColors: true,
      ),
    ),
  );
}