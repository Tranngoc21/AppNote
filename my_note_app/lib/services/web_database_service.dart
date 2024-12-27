import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/note.dart';
import '../utils/logger.dart';
import 'database_service_factory.dart';

class WebDatabaseService implements IDatabaseService {
  static const String apiUrl = 'http://localhost:3000/api'; // Update with your API URL
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      Logger.log('Initializing web database service...');
      Logger.log('Checking API health at: $apiUrl/health');
      
      final response = await http.get(Uri.parse('$apiUrl/health'));
      
      Logger.log('Health check status: ${response.statusCode}');
      Logger.log('Health check response: ${response.body}');

      if (response.statusCode != 200) {
        throw Exception('API not available: Status ${response.statusCode}');
      }
      
      _isInitialized = true;
      Logger.log('Web database service initialized successfully');
    } catch (e) {
      Logger.error('Failed to initialize web database service', e);
      _isInitialized = false;
      throw Exception('Failed to initialize web database service: $e');
    }
  }

  @override
  Future<List<Note>> getNotes() async {
    try {
      Logger.log('Fetching notes from API: $apiUrl/notes');
      final response = await http.get(Uri.parse('$apiUrl/notes'));
      
      Logger.log('API Response Status: ${response.statusCode}');
      Logger.log('API Response Body: ${response.body}');

      if (response.statusCode != 200) {
        throw Exception('Failed to fetch notes: Status ${response.statusCode}');
      }
      
      final List<dynamic> data = json.decode(response.body);
      final notes = data.map((json) => Note.fromMap(json)).toList();
      Logger.log('Successfully fetched ${notes.length} notes');
      return notes;
    } catch (e) {
      Logger.error('Failed to fetch notes', e);
      throw Exception('Failed to fetch notes: $e');
    }
  }

  @override
  Future<Note> createNote(Note note) async {
    try {
      final response = await http.post(
        Uri.parse('$apiUrl/notes'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(note.toMap()),
      );

      if (response.statusCode != 201) {
        throw Exception('Failed to create note');
      }

      return Note.fromMap(json.decode(response.body));
    } catch (e) {
      Logger.error('Failed to create note', e);
      rethrow;
    }
  }

  @override
  Future<void> updateNote(Note note) async {
    try {
      final response = await http.put(
        Uri.parse('$apiUrl/notes/${note.id}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(note.toMap()),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update note');
      }
    } catch (e) {
      Logger.error('Failed to update note', e);
      rethrow;
    }
  }

  @override
  Future<void> deleteNote(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$apiUrl/notes/$id'),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete note');
      }
    } catch (e) {
      Logger.error('Failed to delete note', e);
      rethrow;
    }
  }

  @override
  Future<List<Note>> searchNotes(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$apiUrl/notes/search?q=$query'),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to search notes');
      }

      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Note.fromMap(json)).toList();
    } catch (e) {
      Logger.error('Failed to search notes', e);
      rethrow;
    }
  }

  @override
  Future<void> dispose() async {
    _isInitialized = false;
  }

  @override
  bool get isInitialized => _isInitialized;
} 