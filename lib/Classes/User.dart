class User {
  final String uid;
  final String name;
  final String email;
  final String mobile;
  final String preferences;

  User({
    required this.uid,
    required this.name,
    required this.email,
    required this.mobile,
    this.preferences = '',
  });

  // Convert User to Map for SQLite
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'mobile': mobile,
      'preferences': preferences,
    };
  }

  // Convert User to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'mobile': mobile,
      'preferences': preferences,
    };
  }

  // Create User from Map
  static User fromMap(Map<String, dynamic> map) {
    return User(
      uid: map['uid'],
      name: map['name'],
      email: map['email'],
      mobile: map['mobile'],
      preferences: map['preferences'],
    );
  }
}
