class BasketItem {
  final String id;
  final String upc;
  final String producttext;
  final String brand;
  final String size;
  final String store;
  final double price;
  final int quantity;
  final double total;
  final String? imageUrl;
  final DateTime addedAt;

  BasketItem({
    required this.id,
    required this.upc,
    required this.producttext,
    required this.brand,
    required this.size,
    required this.store,
    required this.price,
    required this.quantity,
    required this.total,
    required this.addedAt,
    this.imageUrl,
  });

  factory BasketItem.fromJson(Map<String, dynamic> json) => BasketItem(
    id: json['id'],
    upc: json['upc'],
    producttext: json['producttext'],
    brand: json['brand'],
    size: json['size'],
    store: json['store'],
    price: (json['price'] as num).toDouble(),
    quantity: json['quantity'],
    total: (json['total'] as num).toDouble(),
    addedAt: DateTime.parse(json['added_at']),
    imageUrl: json['image_small_url'],
  );

  BasketItem copyWith({
    String? id,
    String? upc,
    String? producttext,
    String? brand,
    String? size,
    String? store,
    double? price,
    int? quantity,
    double? total,
    DateTime? addedAt,
    String? imageUrl,
  }) {
    return BasketItem(
      id: id ?? this.id,
      upc: upc ?? this.upc,
      producttext: producttext ?? this.producttext,
      brand: brand ?? this.brand,
      size: size ?? this.size,
      store: store ?? this.store,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      total: total ?? this.total,
      addedAt: addedAt ?? this.addedAt,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
