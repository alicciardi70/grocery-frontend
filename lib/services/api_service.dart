import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';
import '../models/basket.dart';
import '../models/user.dart';
import '../models/basket_item.dart';

class ApiService {
  static const String _baseUrl = 'https://api.groceryscout.net';
  //static const String _baseUrl = 'http://localhost:8000'; // replace if needed

  static Future<void> deleteBasket(String basketId) async {
    final uri = Uri.parse('$_baseUrl/baskets/$basketId');
    final response = await http.delete(uri);

    if (response.statusCode != 200) {
      throw Exception('Failed to delete basket');
    }
  }

  // === Product Search (typed result) ===
  static Future<List<Product>> searchProductsTyped(String query) async {
    final uri = Uri.parse('$_baseUrl/search?query=$query');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((item) => Product.fromJson(item)).toList();
    } else {
      throw Exception('Failed to search products');
    }
  }

  // === Product Search (raw result) ===
  static Future<List<Map<String, dynamic>>> searchProducts(String query) async {
    final uri = Uri.parse('$_baseUrl/search?query=$query');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    } else {
      throw Exception("Failed to search products");
    }
  }

  // === Get All Baskets for User ===
  static Future<List<Basket>> getBasketsByUser(String userId) async {
    final uri = Uri.parse('$_baseUrl/baskets/by-user/$userId');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((item) => Basket.fromJson(item)).toList();
    } else {
      throw Exception("Failed to load baskets");
    }
  }

  // === ✅ Get Items in Basket ===
  static Future<List<BasketItem>> getItemsInBasket(String basketId) async {
    final uri = Uri.parse('$_baseUrl/baskets/$basketId/items');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => BasketItem.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load items for basket $basketId');
    }
  }

  // === Create New Basket ===
  static Future<Basket> createBasket({
    required String userId,
    required String name,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/baskets/create'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'user_id': userId, 'name': name}),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return Basket.fromJson(json['basket']);
    } else {
      throw Exception("Failed to create basket");
    }
  }

  // === Get User by ID ===
  static Future<User> getUserById(String userId) async {
    final uri = Uri.parse('$_baseUrl/users/$userId');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return User.fromJson(json);
    } else {
      throw Exception('Failed to load user');
    }
  }

  // === Add Item to Basket ===
  static Future<void> addItemToBasket({
    required String basketId,
    required String upc,
    required int quantity,
    required String producttext,
    required String brand,
    required String size,
    required String store,
    required double price,
    String? imageUrl,
  }) async {
    //final url = '$_baseUrl/baskets/items/add';
    final uri = Uri.parse('$_baseUrl/baskets/items/add');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'basket_id': basketId,
        'upc': upc,
        'quantity': quantity,
        'producttext': producttext,
        'brand': brand,
        'size': size,
        'store': store,
        'price': price,
        'image_url': imageUrl,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to add item to basket');
    }
  }

  // === Update Item Quantity ===
  static Future<void> updateBasketItemQuantity({
    required String basketId,
    required String upc,
    required int quantity,
  }) async {
    final uri = Uri.parse(
      '$_baseUrl/baskets/$basketId/items/$upc/quantity',
    ); // ✅ FIXED: matches FastAPI route
    final response = await http.patch(
      // ✅ PATCH instead of PUT
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'quantity': quantity}),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update item quantity');
    }
  }

  // === Delete Items by UPC list ===
  static Future<void> deleteBasketItems({
    required String basketId,
    required List<String> upcList,
  }) async {
    final uri = Uri.parse('$_baseUrl/baskets/$basketId/items/delete');
    final response = await http.delete(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'upc_list': upcList}),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to delete basket items');
    }
  }
}
