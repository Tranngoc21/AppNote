import 'package:flutter/foundation.dart' show kIsWeb;
import 'database_service.dart';
import 'web_database_service.dart';
import '../models/note.dart';

abstract class IDatabaseService {
  Future<void> initialize();
  Future<List<Note>> getNotes();
  Future<Note> createNote(Note note);
  Future<void> updateNote(Note note);
  Future<void> deleteNote(int id);
  Future<List<Note>> searchNotes(String query);
  Future<void> dispose();
  bool get isInitialized;
}

class DatabaseServiceFactory {
  static IDatabaseService create() {
    if (kIsWeb) {
      return WebDatabaseService() as IDatabaseService;
    } else {
      return DatabaseService() as IDatabaseService;
    }
  }
}