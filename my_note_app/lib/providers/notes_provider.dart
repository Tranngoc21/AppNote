import 'package:flutter/foundation.dart';
import '../models/note.dart';
import '../services/database_service_factory.dart';
import '../utils/logger.dart';

class NotesProvider with ChangeNotifier {
  final IDatabaseService _db = DatabaseServiceFactory.create();
  List<Note> _notes = [];
  String _searchQuery = '';
  bool _isLoading = true;
  String? _error;

  List<Note> get notes => _notes;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> initialize() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      Logger.log('Initializing NotesProvider');
      await _db.initialize();
      await refreshNotes();
      
      Logger.log('NotesProvider initialized successfully');
    } catch (e) {
      Logger.error('Failed to initialize NotesProvider', e);
      _error = 'Failed to initialize the app: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshNotes() async {
    try {
      Logger.log('Refreshing notes');
      if (_searchQuery.isEmpty) {
        _notes = await _db.getNotes();
      } else {
        _notes = await _db.searchNotes(_searchQuery);
      }
      Logger.log('Notes refreshed successfully. Total notes: ${_notes.length}');
      notifyListeners();
    } catch (e) {
      Logger.error('Failed to refresh notes', e);
      rethrow;
    }
  }

  Future<void> addNote(String title, String content) async {
    try {
      Logger.log('Adding new note: $title');
      final note = Note(
        title: title,
        content: content,
        dateCreated: DateTime.now(),
        dateModified: DateTime.now(),
      );
      await _db.createNote(note);
      await refreshNotes();
      Logger.log('Note added successfully');
    } catch (e) {
      Logger.error('Failed to add note', e);
      rethrow;
    }
  }

  Future<void> updateNote(Note note) async {
    try {
      Logger.log('Updating note: ${note.id}');
      await _db.updateNote(note);
      await refreshNotes();
      Logger.log('Note updated successfully');
    } catch (e) {
      Logger.error('Failed to update note', e);
      rethrow;
    }
  }

  Future<void> deleteNote(int id) async {
    try {
      Logger.log('Deleting note: $id');
      await _db.deleteNote(id);
      await refreshNotes();
      Logger.log('Note deleted successfully');
    } catch (e) {
      Logger.error('Failed to delete note', e);
      rethrow;
    }
  }

  Future<void> search(String query) async {
    try {
      Logger.log('Searching notes with query: $query');
      _searchQuery = query;
      await refreshNotes();
    } catch (e) {
      Logger.error('Failed to search notes', e);
      rethrow;
    }
  }
} 