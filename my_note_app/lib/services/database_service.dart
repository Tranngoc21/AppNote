import 'package:postgres/postgres.dart';
import '../models/note.dart';
import '../utils/logger.dart';
import 'database_service_factory.dart';

class DatabaseException implements Exception {
  final String message;
  final dynamic cause;

  DatabaseException(this.message, [this.cause]);

  @override
  String toString() => 'DatabaseException: $message${cause != null ? ' ($cause)' : ''}';
}

class DatabaseService implements IDatabaseService {
  PostgreSQLConnection? _conn;
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) {
      Logger.log('Database already initialized');
      return;
    }

    try {
      Logger.log('Initializing database connection');
      _conn = PostgreSQLConnection(
        'localhost',  // host
        5432,         // port
        'notes_db',   // database name
        username: 'postgres',
        password: 'Hongngoc27112004',
      );

      await _conn?.open();
      await _createTable(); // Add this line to create table on initialization
      _isInitialized = true; // Add this line to set initialized flag
      Logger.log('Database connection established');
    } catch (e) {
      Logger.error('Failed to initialize database', e);
      rethrow;
    }
  }

  Future<void> _createTable() async {
    if (_conn == null || _conn!.isClosed) {
      throw Exception('Database connection not available');
    }
    try {
      await _conn?.query(''' 
        CREATE TABLE IF NOT EXISTS notes (
          id SERIAL PRIMARY KEY,
          title TEXT NOT NULL,
          content TEXT NOT NULL,
          date_created TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
          date_modified TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
        )
      ''');
      Logger.log('Notes table created or already exists');
    } catch (e) {
      Logger.error('Failed to create table', e);
      rethrow;
    }
  }

  Future<List<Note>> getNotes() async {
    if (_conn == null || _conn!.isClosed) {
      throw Exception('Database connection not available');
    }
    try {
      Logger.log('Fetching all notes');
      final results = await _conn?.query(
        'SELECT * FROM notes ORDER BY date_modified DESC',
      );

      if (results == null || results.isEmpty) {
        throw Exception('No notes found');
      }

      Logger.log('Retrieved ${results.length} notes');
      return results.map((row) {
        return Note.fromMap({
          'id': row[0],
          'title': row[1],
          'content': row[2],
          'date_created': row[3].toString(),
          'date_modified': row[4].toString(),
        });
      }).toList();
    } catch (e) {
      Logger.error('Failed to fetch notes', e);
      rethrow;
    }
  }

  Future<Note> createNote(Note note) async {
    if (_conn == null || _conn!.isClosed) {
      throw Exception('Database connection not available');
    }
    try {
      Logger.log('Creating new note: ${note.title}');
      final results = await _conn?.query(
        '''
        INSERT INTO notes (title, content, date_created, date_modified)
        VALUES (@title, @content, @dateCreated, @dateModified)
        RETURNING *
        ''',
        substitutionValues: {
          'title': note.title,
          'content': note.content,
          'dateCreated': note.dateCreated.toIso8601String(),
          'dateModified': note.dateModified.toIso8601String(),
        },
      );

      if (results == null || results.isEmpty) {
        throw Exception('Failed to create note');
      }

      final row = results.first;
      Logger.log('Note created successfully with ID: ${row[0]}');
      return Note.fromMap({
        'id': row[0],
        'title': row[1],
        'content': row[2],
        'date_created': row[3].toString(),
        'date_modified': row[4].toString(),
      });
    } catch (e) {
      Logger.error('Failed to create note', e);
      rethrow;
    }
  }

  Future<void> updateNote(Note note) async {
    if (_conn == null || _conn!.isClosed) {
      throw Exception('Database connection not available');
    }

    try {
      await _conn?.query('BEGIN');
      Logger.log('Updating note with ID: ${note.id}');
      
      final results = await _conn?.query(
        '''
        UPDATE notes 
        SET title = @title, content = @content, date_modified = @dateModified
        WHERE id = @id
        ''',
        substitutionValues: {
          'id': note.id,
          'title': note.title,
          'content': note.content,
          'dateModified': DateTime.now().toIso8601String(),
        },
      );

      if (results == null || results.isEmpty) {
        throw Exception('Failed to update note');
      }

      await _conn?.query('COMMIT');
      Logger.log('Note updated successfully');
    } catch (e) {
      await _conn?.query('ROLLBACK');
      Logger.error('Failed to update note', e);
      rethrow;
    }
  }

  Future<void> deleteNote(int id) async {
    if (_conn == null || _conn!.isClosed) {
      throw Exception('Database connection not available');
    }

    try {
      Logger.log('Deleting note with ID: $id');
      final results = await _conn?.query(
        'DELETE FROM notes WHERE id = @id',
        substitutionValues: {'id': id},
      );

      if (results == null || results.isEmpty) {
        throw Exception('Failed to delete note');
      }

      Logger.log('Note deleted successfully');
    } catch (e) {
      Logger.error('Failed to delete note', e);
      rethrow;
    }
  }

  Future<List<Note>> searchNotes(String query) async {
    if (_conn == null || _conn!.isClosed) {
      throw Exception('Database connection not available');
    }

    try {
      Logger.log('Searching notes with query: $query');
      final results = await _conn?.query(
        '''
        SELECT * FROM notes 
        WHERE title ILIKE @query OR content ILIKE @query
        ORDER BY date_modified DESC
        ''',
        substitutionValues: {
          'query': '%$query%',
        },
      );

      if (results == null || results.isEmpty) {
        return [];
      }

      Logger.log('Found ${results.length} matching notes');
      return results.map((row) {
        return Note.fromMap({
          'id': row[0],
          'title': row[1],
          'content': row[2],
          'date_created': row[3].toString(),
          'date_modified': row[4].toString(),
        });
      }).toList();
    } catch (e) {
      Logger.error('Failed to search notes', e);
      rethrow;
    }
  }

  Future<void> dispose() async {
    try {
      if (_conn != null && !_conn!.isClosed) {
        await _conn?.close();
        Logger.log('Database connection closed');
      }
      _isInitialized = false;
    } catch (e) {
      Logger.error('Error closing database connection', e);
      throw DatabaseException('Failed to close database connection', e);
    }
  }

  bool get isInitialized => _isInitialized;

  bool get isConnected => _conn != null && !_conn!.isClosed;
}
