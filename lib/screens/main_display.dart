import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() => runApp(GroceryScoutApp());

class GroceryScoutApp extends StatelessWidget {
  const GroceryScoutApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Grocery Price & Nutrition Optimizer',
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const HomeScreen(),
    );
  }
}

class BasketItem {
  final dynamic product;
  int quantity;
  BasketItem({required this.product, this.quantity = 1});
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _products = [];
  final List<BasketItem> _basket = [];
  bool _loading = false;
  String? _error;
  int _currentIndex = 0; // Track the selected tab index

  Future<void> searchProduct(String query) async {
    setState(() {
      _loading = true;
      _error = null;
      _products = [];
    });

    try {
      final response = await http.get(Uri.parse('https://api.groceryscout.net/search?query=$query'));
      if (response.statusCode == 200) {
        setState(() {
          _products = json.decode(response.body);
          _loading = false;
        });
      } else {
        setState(() {
          _error = 'HTTP ${response.statusCode}';
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error: $e';
        _loading = false;
      });
    }
  }

  void addToBasket(dynamic product) {
    final index = _basket.indexWhere((item) => item.product['metadata']['UPC'] == product['metadata']['UPC']);
    setState(() {
      if (index >= 0) {
        _basket[index].quantity++;
      } else {
        _basket.add(BasketItem(product: product));
      }
    });
  }

  void removeFromBasket(BasketItem item) {
    setState(() {
      _basket.remove(item);
    });
  }

  Map<String, double> calculateStoreTotals() {
    final Map<String, double> storeTotals = {};

    for (var item in _basket) {
      final quantity = item.quantity;
      final prices = item.product['prices'] ?? [];
      for (var price in prices) {
        final store = price['store'];
        final priceVal = double.tryParse(price['price'].toString()) ?? 0;
        storeTotals[store] = (storeTotals[store] ?? 0) + (priceVal * quantity);
      }
    }

    return storeTotals;
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 600;

    return DefaultTabController(
      length: 2,
      child: Builder(
        builder: (context) => Scaffold(
          body: TabBarView(
            controller: DefaultTabController.of(context),
            children: [
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: TextField(
                      controller: _searchController,
                      onSubmitted: searchProduct,
                      decoration: const InputDecoration(
                        labelText: 'Search Product',
                        suffixIcon: Icon(Icons.search),
                      ),
                    ),
                  ),
                  if (_loading) const CircularProgressIndicator(),
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(_error!, style: const TextStyle(color: Colors.red)),
                    ),
                  Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: isDesktop ? 3 : 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 2 / 3,
                      ),
                      itemCount: _products.length,
                      itemBuilder: (context, index) {
                        final product = _products[index];
                        final bestPrice = product['prices']?.first;
                        final otherPrices = product['prices']?.skip(1).toList() ?? [];

                        return Card(
                          margin: const EdgeInsets.only(bottom: 2),
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(color: Colors.green.shade300, width: 1),
                          ),
                          elevation: 4,
                          child: Stack(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min, // Ensure the column takes only the necessary space
                                  children: [
                                    if (product['metadata']['image_small_url'] != null && product['metadata']['image_small_url'].toString().isNotEmpty)
                                      Center(
                                        child: Image.network(
                                          product['metadata']['image_small_url'],
                                          width: MediaQuery.of(context).size.width * 0.7 * 0.7, // 70% of the card's width
                                          height: MediaQuery.of(context).size.height * 0.15, // Constrain height to 15% of screen height to ensure it doesn't exceed half of the card
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    const SizedBox(height: 8),
                                    // Ensure only one 'Compare Price' link is displayed to the right of the store name
                                    if (bestPrice != null)
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "\$${bestPrice['price']}",
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                bestPrice['store'],
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                              // Show 'Compare Price' text only if more than 1 price exists
                                              if (product['prices'] != null && product['prices'].length > 1)
                                                GestureDetector(
                                                  onTap: () {
                                                    showDialog(
                                                      context: context,
                                                      builder: (BuildContext context) {
                                                        return AlertDialog(
                                                          title: const Text('Compare Prices'),
                                                          content: Column(
                                                            mainAxisSize: MainAxisSize.min,
                                                            children: product['prices']?.map<Widget>((price) => Text("\$${price['price']} - ${price['store']}"))?.toList() ?? [],
                                                          ),
                                                          actions: [
                                                            TextButton(
                                                              onPressed: () => Navigator.of(context).pop(),
                                                              child: const Text('Close'),
                                                            ),
                                                          ],
                                                        );
                                                      },
                                                    );
                                                  },
                                                  child: const Text(
                                                    'Compare Price',
                                                    style: TextStyle(
                                                      color: Colors.blue,
                                                      decoration: TextDecoration.underline,
                                                      fontSize: 10, // Smaller font size for 'Compare Price'
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    
                                    const SizedBox(height: 8),
                                    Text(
                                      product['metadata']['description'] ?? 'No description',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      product['metadata']['size'] ?? '',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: GestureDetector(
                                  onTap: () => addToBasket(product),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white, // White background
                                      shape: BoxShape.circle, // Circular shape
                                    ),
                                    padding: const EdgeInsets.all(0), // Padding to ensure proper spacing
                                    child: const Icon(
                                      Icons.add_circle,
                                      color: Colors.green,
                                      size: 32,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  )
                ],
              ),
              ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const Text('Basket Items', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 8),
                  ..._basket.map((item) {
                    final description = item.product['metadata']['description'];
                    return Card(
                      child: ListTile(
                        title: Text(description),
                        subtitle: Text('Qty: ${item.quantity}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => removeFromBasket(item),
                        ),
                      ),
                    );
                  }).toList(),
                  const SizedBox(height: 16),
                  const Text('Total Basket Cost per Store', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 8),
                  ...calculateStoreTotals().entries.map((entry) => ListTile(
                        title: Text(entry.key),
                        trailing: Text('\$${entry.value.toStringAsFixed(2)}'),
                        tileColor: entry == calculateStoreTotals().entries.first ? Colors.green.shade100 : null,
                      ))
                ],
              ),
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.search),
                label: 'Search',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.shopping_basket),
                label: 'Basket',
              ),
            ],
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
              DefaultTabController.of(context).animateTo(index);
            },
          ),
        ),
      ),
    );
  }
}

class NutritionPopup extends StatelessWidget {
  final dynamic product;

  const NutritionPopup({required this.product, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nutritional Information'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Calories per 100g: ${product['metadata']['energy-kcal_100g'] ?? 'N/A'}"),
          Text("Carbs per 100g: ${product['metadata']['carbohydrates_100g'] ?? 'N/A'}"),
          Text("Protein per 100g: ${product['metadata']['proteins_100g'] ?? 'N/A'}"),
          Text("Fat per 100g: ${product['metadata']['fat_100g'] ?? 'N/A'}"),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
