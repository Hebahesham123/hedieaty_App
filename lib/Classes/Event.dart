class Event {
  final String id; // UUID
  final String name;
  final String date;
  final String location;
  final String? description;
  final String? category;
  final bool published; // 0 or 1 in SQLite
  final String userId; // Foreign key referencing Users table

  Event({
    required this.id,
    required this.name,
    required this.date,
    required this.location,
    this.description,
    this.category,
    required this.published,
    required this.userId,
  });

  // Convert Event to Map for SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'date': date,
      'location': location,
      'description': description,
      'category': category,
      'published': published ? 1 : 0,
      'user_id': userId,
    };
  }

  // Create Event from Map
  static Event fromMap(Map<String, dynamic> map) {
    return Event(
      id: map['id'],
      name: map['name'],
      date: map['date'],
      location: map['location'],
      description: map['description'],
      category: map['category'],
      published: map['published'] == 1,
      userId: map['user_id'],
    );
  }
}
