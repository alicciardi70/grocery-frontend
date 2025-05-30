import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;

void main() {
  runApp(GroceryScoutApp());
}

class GroceryScoutApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Grocery Scout',
      theme: ThemeData(primarySwatch: Colors.green),
      home: GrocerySearchScreen(),
    );
  }
}

class GrocerySearchScreen extends StatefulWidget {
  @override
  _GrocerySearchScreenState createState() => _GrocerySearchScreenState();
}

class _GrocerySearchScreenState extends State<GrocerySearchScreen> {
  TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _results = [];
  bool _loading = false;
  Timer? _debounce;

  void _searchProducts(String query) async {
    if (query.isEmpty) {
      setState(() {
        _results = [];
      });
      return;
    }

    setState(() {
      _loading = true;
    });

    final url = Uri.parse('https://api.groceryscout.net/search?query=$query');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _results =
              data.map((item) {
                final metadata = item['metadata'] ?? {};
                final prices = item['prices'] ?? [];

                return {
                  'description': metadata['description'] ?? '-',
                  'brand': metadata['Brand'] ?? '-',
                  'upc': metadata['UPC'] ?? '-',
                  'energy': metadata['energy-kcal_100g'] ?? '',
                  'protein': metadata['proteins_100g'] ?? '',
                  'fat': metadata['fat_100g'] ?? '',
                  'carbs': metadata['carbohydrates_100g'] ?? '',
                  'image': metadata['image_small_url'] ?? '',
                  'prices': prices,
                };
              }).toList();
        });
      } else {
        setState(() {
          _results = [];
        });
      }
    } catch (e) {
      print('Error fetching data: $e');
      setState(() {
        _results = [];
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Grocery Scout')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              onChanged: (text) {
                if (_debounce?.isActive ?? false) _debounce!.cancel();
                _debounce = Timer(const Duration(milliseconds: 400), () {
                  _searchProducts(text);
                });
              },
              decoration: InputDecoration(
                hintText: 'Search for a grocery item...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            _loading
                ? CircularProgressIndicator()
                : Expanded(
                  child:
                      _results.isEmpty
                          ? Center(child: Text('No results'))
                          : ListView.builder(
                            itemCount: _results.length,
                            itemBuilder: (context, index) {
                              final item = _results[index];
                              final prices = item['prices'] as List;

                              return Card(
                                margin: EdgeInsets.symmetric(vertical: 8),
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (item['image'] != '')
                                        Image.network(
                                          item['image'],
                                          height: 100,
                                        ),
                                      Text(
                                        item['description'],
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Text('Brand: ${item['brand']}'),
                                      Text('UPC: ${item['upc']}'),
                                      if (item['energy'] != '')
                                        Text(
                                          'Calories: ${double.parse(item['energy']).toStringAsFixed(2)} per 100g',
                                        ),

                                      if (item['protein'] != '')
                                        Text(
                                          'Protein: ${double.parse(item['protein']).toStringAsFixed(2)}g',
                                        ),

                                      if (item['fat'] != '')
                                        Text(
                                          'Fat: ${double.parse(item['fat']).toStringAsFixed(2)}g',
                                        ),

                                      if (item['carbs'] != '')
                                        Text(
                                          'Carbs: ${double.parse(item['carbs']).toStringAsFixed(2)}g',
                                        ),

                                      SizedBox(height: 8),
                                      Text(
                                        'Prices:',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                      ...prices.map<Widget>(
                                        (p) => Text(
                                          '${p['store']}: \$${p['price']} • ${p['unit_cost']}',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                ),
          ],
        ),
      ),
    );
  }
}
