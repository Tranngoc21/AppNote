class Logger {
  static void log(String message) {
    print('📝 [Notes App] $message');
  }

  static void error(String message, [dynamic error]) {
    print('❌ [Notes App Error] $message');
    if (error != null) {
      print('Error details: $error');
    }
  }
} 