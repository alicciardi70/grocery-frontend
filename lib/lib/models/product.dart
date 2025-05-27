class Product {
  final String upc;
  final String description;
  final String brand;
  final String? size; // ✅ make sure this is here
  final String? imageUrl;
  final List<StorePrice>? storePrices;

  Product({
    required this.upc,
    required this.description,
    required this.brand,
    this.size, // ✅ include it in the constructor too
    this.imageUrl,
    this.storePrices,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      description: json['description'],
      brand: json['brand'],
      upc: json['upc'],
      imageUrl: json['image_url'],
      storePrices:
          json['store_prices'] != null
              ? (json['store_prices'] as List)
                  .map((e) => StorePrice.fromJson(e))
                  .toList()
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'brand': brand,
      'upc': upc,
      'image_url': imageUrl,
      'store_prices': storePrices?.map((e) => e.toJson()).toList(),
    };
  }
}

class StorePrice {
  final String store;
  final double price;

  StorePrice({required this.store, required this.price});

  factory StorePrice.fromJson(Map<String, dynamic> json) {
    return StorePrice(
      store: json['store'],
      price: (json['price'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'store': store, 'price': price};
  }
}
