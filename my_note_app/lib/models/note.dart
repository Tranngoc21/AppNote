class Note {
  final int? id;
  String title;
  String content;
  DateTime dateCreated;
  DateTime dateModified;

  Note({
    this.id,
    required this.title,
    required this.content,
    required this.dateCreated,
    required this.dateModified,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'date_created': dateCreated.toIso8601String(),
      'date_modified': dateModified.toIso8601String(),
    };
  }

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'],
      title: map['title'],
      content: map['content'],
      dateCreated: DateTime.parse(map['date_created']),
      dateModified: DateTime.parse(map['date_modified']),
    );
  }
} 