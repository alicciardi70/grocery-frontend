import 'package:flutter/material.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../providers/user_provider.dart';
import '../widgets/add_to_basket_modal.dart';

class ProductSearchScreen extends StatefulWidget {
  const ProductSearchScreen({Key? key}) : super(key: key);

  @override
  _ProductSearchScreenState createState() => _ProductSearchScreenState();
}

class _ProductSearchScreenState extends State<ProductSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _results = [];
  bool _loading = false;
  Timer? _debounce;

  void _searchProducts(String query) async {
    if (query.isEmpty) {
      setState(() => _results = []);
      return;
    }

    setState(() => _loading = true);

    try {
      final results = await ApiService.searchProducts(query);
      setState(() => _results = results);
    } catch (e) {
      debugPrint('Error during search: $e');
    }

    setState(() => _loading = false);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final columns =
        screenWidth > 1200
            ? 3
            : screenWidth > 800
            ? 2
            : 1;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: 'Search Products',
              prefixIcon: const Icon(Icons.search),
              border: const OutlineInputBorder(),
              suffixIcon:
                  _searchController.text.isNotEmpty
                      ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _searchProducts('');
                        },
                      )
                      : null,
            ),
            onChanged: (query) {
              if (_debounce?.isActive ?? false) _debounce!.cancel();
              _debounce = Timer(const Duration(milliseconds: 500), () {
                _searchProducts(query);
              });
            },
          ),
          const SizedBox(height: 8),
          if (_loading) const LinearProgressIndicator(),
          const SizedBox(height: 8),
          Expanded(
            child:
                _results.isEmpty
                    ? const Center(child: Text("No results found"))
                    : GridView.builder(
                      itemCount: _results.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columns,
                        childAspectRatio: 2.8,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemBuilder: (context, index) {
                        final item = _results[index];
                        final meta = item['metadata'] ?? item;
                        final prices = item['prices'] as List<dynamic>? ?? [];

                        final imageUrl = (meta['image_small_url'] ?? '')
                            .toString()
                            .replaceFirst('http://', 'https://');

                        return Card(
                          child: ListTile(
                            isThreeLine: true,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 8.0,
                              horizontal: 16.0,
                            ),

                            leading: SizedBox(
                              width: 128,
                              height: 128,
                              child: Image.network(
                                imageUrl,
                                fit:
                                    BoxFit
                                        .contain, // ✅ No distortion, full image shown
                                errorBuilder:
                                    (_, __, ___) => const Icon(
                                      Icons.broken_image,
                                      size: 64,
                                    ),
                              ),
                            ),

                            title: Text(
                              meta['description'] ?? 'Unnamed Product',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Brand: ${meta['Brand'] ?? 'N/A'}'),
                                if (prices.isNotEmpty)
                                  ...prices.map((p) {
                                    final store = p['store'] ?? '-';
                                    final price = p['price'] ?? '-';
                                    final unitCost = p['unit_cost'] ?? '';
                                    return Text(
                                      '$store: \$$price${unitCost.isNotEmpty ? ', Unit Cost: $unitCost' : ''}',
                                    );
                                  }).toList(),
                              ],
                            ),

                            trailing: IconButton(
                              icon: const Icon(Icons.add_shopping_cart),
                              onPressed: () async {
                                final userId =
                                    Provider.of<UserProvider>(
                                      context,
                                      listen: false,
                                    ).userId!;
                                final baskets =
                                    await ApiService.getBasketsByUser(userId);

                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  builder:
                                      (_) => AddToBasketModal(
                                        userId: userId,
                                        baskets: baskets,
                                        product: {
                                          'upc': meta['UPC'] ?? '',
                                          'producttext':
                                              meta['description'] ?? '',
                                          'brand': meta['Brand'] ?? '',
                                          'size': meta['Size'] ?? '',
                                          'store':
                                              prices.isNotEmpty
                                                  ? prices[0]['store'] ?? '-'
                                                  : '-',
                                          'price':
                                              prices.isNotEmpty
                                                  ? double.tryParse(
                                                        prices[0]['price'] ??
                                                            '0',
                                                      ) ??
                                                      0
                                                  : 0,
                                        },
                                      ),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
