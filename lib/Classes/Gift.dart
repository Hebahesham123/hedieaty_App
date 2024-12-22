class Gift {
  final String? id; // Primary key (nullable for new gifts)
  final String name;
  final String? description;
  final String category;
  final double price;
  final String status; // 'available', 'pledged', 'purchased'
  final bool published;
  final String eventId; // Foreign key referencing Events table
  final String? imageLink;
  final String? pledgedBy; // New field


  Gift({
    this.id,
    required this.name,
    this.description,
    required this.category,
    required this.price,
    this.status = 'available',
    this.published = false,
    required this.eventId,
    this.imageLink,
    this.pledgedBy,
  });

  // Convert Gift to Map for SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'price': price,
      'status': status,
      'published': published ? 1 : 0,
      'event_id': eventId,
      'imageLink': imageLink,
      'pledgedBy': pledgedBy, // Include the new field
    };
  }

  // Convert Map to Gift
  static Gift fromMap(Map<String, dynamic> map) {
    return Gift(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      category: map['category'],
      price: map['price'],
      status: map['status'],
      published: map['published'] == 1,
      eventId: map['event_id'],
      imageLink: map['imageLink'],
      pledgedBy: map['pledgedBy'], // Parse the new field
    );
  }
}
