class Basket {
  final String id;
  final String userId;
  final String name;
  final DateTime createdAt;
  final int itemCount;

  Basket({
    required this.id,
    required this.userId,
    required this.name,
    required this.createdAt,
    required this.itemCount,
  });

  factory Basket.fromJson(Map<String, dynamic> json) => Basket(
    id: json['id'],
    userId: json['user_id'],
    name: json['name'],
    createdAt: DateTime.parse(json['created_at']),
    itemCount: json['item_count'] ?? 0, //,
  );

  Basket copyWith({
    String? id,
    String? userId,
    String? name,
    DateTime? createdAt,
    int? itemCount,
  }) {
    return Basket(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      itemCount: itemCount ?? this.itemCount,
    );
  }
}
