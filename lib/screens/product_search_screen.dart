import 'package:flutter/material.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../providers/user_provider.dart';
import '../widgets/add_to_basket_modal.dart';
import '../models/basket.dart';
import '../models/product.dart';
import '../widgets/barcode_scanner_web.dart';

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
  Set<int> _expandedItems = {};

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

  Future<void> _onScannedUPC(String scannedUpc) async {
    final upc = scannedUpc.padLeft(14, '0').substring(0, 13);

    Navigator.of(context).pop();
    final userId = Provider.of<UserProvider>(context, listen: false).userId!;
    List<Basket> baskets = await ApiService.getBasketsByUser(userId);

    if (baskets.isEmpty) {
      final newBasket = await ApiService.createBasket(
        userId: userId,
        name: "Basket 1",
      );
      baskets = [newBasket];
    }

    try {
      final results = await ApiService.searchByUPC(upc);
      if (results.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("No product found for UPC: $upc")),
        );
        return;
      }

      final meta = results.first["metadata"];
      final prices = results.first["prices"];

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder:
            (context) => DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.75,
              minChildSize: 0.5,
              maxChildSize: 0.95,
              builder:
                  (_, controller) => Padding(
                    padding: const EdgeInsets.all(16),
                    child: ListView(
                      controller: controller,
                      children: [
                        const Text(
                          'Compare Prices',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...prices.map<Widget>((p) {
                          final store = p['store'] ?? '-';
                          final price = p['price'] ?? '-';
                          final unitCost = p['unit_cost'] ?? '';
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Text(
                              '$store: \$$price${unitCost.isNotEmpty ? ', Unit Cost: $unitCost' : ''}',
                              style: const TextStyle(fontSize: 14),
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
            ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error scanning UPC: $e")));
    }
  }

  Widget _buildTile(Map<String, dynamic> item, int index, bool isMobile) {
    final meta = item['metadata'] ?? item;
    final prices = item['prices'] as List<dynamic>? ?? [];
    final imageUrl = (meta['image_small_url'] ?? '').toString().replaceFirst(
      'http://',
      'https://',
    );
    final isExpanded = _expandedItems.contains(index);

    return GestureDetector(
      onTap:
          isMobile
              ? () {
                setState(() {
                  if (isExpanded) {
                    _expandedItems.remove(index);
                  } else {
                    _expandedItems.add(index);
                  }
                });
              }
              : null,
      child: Card(
        elevation: 3,
        margin: const EdgeInsets.symmetric(vertical: 6),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: isMobile ? 100 : 140,
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.contain,
                      errorBuilder:
                          (_, __, ___) =>
                              const Icon(Icons.broken_image, size: 48),
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () async {
                        final userId =
                            Provider.of<UserProvider>(
                              context,
                              listen: false,
                            ).userId!;
                        List<Basket> baskets =
                            await ApiService.getBasketsByUser(userId);
                        if (baskets.isEmpty) {
                          final newBasket = await ApiService.createBasket(
                            userId: userId,
                            name: "Basket 1",
                          );
                          baskets = [newBasket];
                        }

                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          builder:
                              (_) => AddToBasketModal(
                                product: Product(
                                  upc: meta['UPC'] ?? '',
                                  description: meta['description'] ?? '',
                                  brand: meta['Brand'] ?? '',
                                  size: meta['Size'] ?? '',
                                  imageUrl: imageUrl,
                                  storePrices:
                                      prices.map<StorePrice>((p) {
                                        return StorePrice(
                                          store: p['store'] ?? '-',
                                          price:
                                              double.tryParse(
                                                p['price'] ?? '0',
                                              ) ??
                                              0,
                                        );
                                      }).toList(),
                                ),
                                baskets: baskets,
                              ),
                        );
                      },
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        padding: EdgeInsets.zero,
                        child: const Icon(
                          Icons.add_circle,
                          color: Colors.green,
                          size: 28,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                meta['description'] ?? 'Unnamed Product',
                style: const TextStyle(fontWeight: FontWeight.bold),
                maxLines: isMobile && !isExpanded ? 2 : null,
                overflow:
                    isMobile && !isExpanded
                        ? TextOverflow.ellipsis
                        : TextOverflow.visible,
              ),
              const SizedBox(height: 4),
              Text('Brand: ${meta['Brand'] ?? 'N/A'}'),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${prices[0]['store'] ?? '-'}: \$${prices[0]['price'] ?? '-'}',
                    style: const TextStyle(fontSize: 13),
                  ),
                  if (prices.length > 1)
                    TextButton(
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          builder:
                              (_) => DraggableScrollableSheet(
                                expand: false,
                                initialChildSize: 0.75,
                                minChildSize: 0.5,
                                maxChildSize: 0.95,
                                builder:
                                    (_, controller) => Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: ListView(
                                        controller: controller,
                                        children: [
                                          const Text(
                                            'Compare Prices',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          ...prices.map<Widget>((p) {
                                            final store = p['store'] ?? '-';
                                            final price = p['price'] ?? '-';
                                            final unitCost =
                                                p['unit_cost'] ?? '';
                                            return Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 4,
                                                  ),
                                              child: Text(
                                                '$store: \$$price${unitCost.isNotEmpty ? ', Unit Cost: $unitCost' : ''}',
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                        ],
                                      ),
                                    ),
                              ),
                        );
                      },
                      child: const Text(
                        'Compare Prices',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 800;
    final columns =
        screenWidth >= 1200
            ? 5
            : screenWidth >= 800
            ? 2
            : 2;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.qr_code_scanner),
                label: const Text("Scan Barcode"),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder:
                        (_) => AlertDialog(
                          title: const Text("Scan Barcode"),
                          content: SizedBox(
                            width: 350,
                            height: 380,
                            child: BarcodeScannerWeb(
                              key: UniqueKey(),
                              onScanned: _onScannedUPC,
                            ),
                          ),
                          actions: [
                            TextButton(
                              child: const Text("Close"),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                          ],
                        ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
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
                        childAspectRatio: isMobile ? 0.75 : 1.1,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),

                      itemBuilder: (context, index) {
                        return _buildTile(_results[index], index, isMobile);
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
