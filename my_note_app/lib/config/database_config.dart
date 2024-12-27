class DatabaseConfig {
  static const String host = 'localhost';
  static const int port = 5432;
  static const String databaseName = 'notes_db';
  static const String username = 'postgres';  // Update with your PostgreSQL username
  static const String password = 'Hongngoc27112004';  // Update with your PostgreSQL password

  // Connection settings
  static const int timeoutSeconds = 30;
  static const bool useSSL = false;
} 