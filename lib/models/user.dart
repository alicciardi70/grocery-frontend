class User {
  final String id;
  final String username;
  final String email;
  final String? phone;
  final String? fullName;
  final bool isActive;
  final DateTime createdAt;

  User({
    required this.id,
    required this.username,
    required this.email,
    this.phone,
    this.fullName,
    required this.isActive,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      phone: json['phone'],
      fullName: json['full_name'],
      isActive: json['is_active'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
