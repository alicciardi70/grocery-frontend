import 'package:flutter/material.dart';
import '../models/basket_item.dart';
import '../services/api_service.dart';
import '../widgets/basket_item_tile.dart';

class BasketDetailScreen extends StatefulWidget {
  final String basketId;
  final String basketName;

  const BasketDetailScreen({
    Key? key,
    required this.basketId,
    required this.basketName,
  }) : super(key: key);

  @override
  State<BasketDetailScreen> createState() => _BasketDetailScreenState();
}

class _BasketDetailScreenState extends State<BasketDetailScreen> {
  List<BasketItem> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    try {
      final items = await ApiService.getItemsInBasket(widget.basketId);
      setState(() {
        _items = items;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      debugPrint('Error loading basket items: \$e');
    }
  }

  double get totalPrice =>
      _items.fold(0, (sum, item) => sum + (item.price * item.quantity));

  void _onItemUpdated(BasketItem updatedItem) {
    setState(() {
      final index = _items.indexWhere((i) => i.id == updatedItem.id);
      if (index != -1) _items[index] = updatedItem;
    });
  }

  void _onItemDeleted(String upc) {
    setState(() {
      _items.removeWhere((i) => i.upc == upc);
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final columns =
        screenWidth > 1200
            ? 3
            : screenWidth > 800
            ? 2
            : 1;

    return Scaffold(
      appBar: AppBar(title: Text(widget.basketName)),
      body:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  Expanded(
                    child:
                        _items.isEmpty
                            ? const Center(child: Text("Basket is empty"))
                            : (isMobile
                                ? ListView.builder(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 12,
                                  ),
                                  itemCount: _items.length,
                                  itemBuilder:
                                      (context, index) => Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 10,
                                        ),
                                        child: BasketItemTile(
                                          item: _items[index],
                                          basketId: widget.basketId,
                                          onUpdated: _onItemUpdated,
                                          onDeleted: _onItemDeleted,
                                        ),
                                      ),
                                )
                                : GridView.builder(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 12,
                                  ),
                                  itemCount: _items.length,
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: columns,
                                        mainAxisSpacing: 10,
                                        crossAxisSpacing: 10,
                                        childAspectRatio: 2.8,
                                      ),
                                  itemBuilder:
                                      (context, index) => BasketItemTile(
                                        item: _items[index],
                                        basketId: widget.basketId,
                                        onUpdated: _onItemUpdated,
                                        onDeleted: _onItemDeleted,
                                      ),
                                )),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      "Total: \$${totalPrice.toStringAsFixed(2)}",
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                ],
              ),
    );
  }
}
