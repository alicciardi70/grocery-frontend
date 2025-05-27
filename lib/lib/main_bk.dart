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

    final url = Uri.parse('https://api.groceryscout.net/search?q=$query');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _results =
              data
                  .map(
                    (item) => {
                      'name': item['name'],
                      'price': item['price'],
                      'store': item['store'],
                      'brand': item['brand'],
                    },
                  )
                  .toList();
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
                              return Card(
                                child: ListTile(
                                  title: Text(item['name']),
                                  subtitle: Text(
                                    '${item['store']} • ${item['brand']}',
                                  ),
                                  trailing: Text(
                                    '\$${item['price'].toString()}',
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
