import 'package:flutter/material.dart';
import '../models/basket_item.dart';
import '../services/api_service.dart';
import 'quantity_editor.dart';

class BasketItemTile extends StatefulWidget {
  final BasketItem item;
  final String basketId;
  final Function(BasketItem) onUpdated;
  final Function(String upc) onDeleted;

  const BasketItemTile({
    Key? key,
    required this.item,
    required this.basketId,
    required this.onUpdated,
    required this.onDeleted,
  }) : super(key: key);

  @override
  State<BasketItemTile> createState() => _BasketItemTileState();
}

class _BasketItemTileState extends State<BasketItemTile> {
  late int _quantity;
  bool _edited = false;

  @override
  void initState() {
    super.initState();
    _quantity = widget.item.quantity;
  }

  Future<void> _updateQuantity() async {
    try {
      await ApiService.updateBasketItemQuantity(
        basketId: widget.basketId,
        upc: widget.item.upc,
        quantity: _quantity,
      );
      final updated = widget.item.copyWith(
        quantity: _quantity,
        total: _quantity * widget.item.price,
      );
      widget.onUpdated(updated);
      setState(() => _edited = false);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to update quantity")),
      );
    }
  }

  Future<void> _deleteItem() async {
    try {
      await ApiService.deleteBasketItems(
        basketId: widget.basketId,
        upcList: [widget.item.upc],
      );
      widget.onDeleted(widget.item.upc);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Failed to delete item")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // === Image ===
            SizedBox(
              width: 128,
              height: 128,
              child:
                  widget.item.imageUrl != null &&
                          widget.item.imageUrl!.isNotEmpty
                      ? Image.network(
                        widget.item.imageUrl!,
                        fit: BoxFit.contain,
                        errorBuilder:
                            (_, __, ___) =>
                                const Icon(Icons.broken_image, size: 40),
                      )
                      : const Icon(Icons.image_not_supported, size: 40),
            ),
            const SizedBox(width: 8),

            // === Product Info and Controls ===
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.item.producttext,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${widget.item.brand} • ${widget.item.size}',
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                  Text(
                    'Store: ${widget.item.store}',
                    style: const TextStyle(fontSize: 13),
                  ),
                  Text(
                    '\$${widget.item.price.toStringAsFixed(2)} each',
                    style: const TextStyle(fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      QuantityEditor(
                        quantity: _quantity,
                        onChanged: (newQty) {
                          setState(() {
                            _quantity = newQty;
                            _edited = (newQty != widget.item.quantity);
                          });
                        },
                      ),
                      if (_edited)
                        IconButton(
                          icon: const Icon(Icons.check, color: Colors.green),
                          onPressed: _updateQuantity,
                          iconSize: 20,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                    ],
                  ),
                ],
              ),
            ),

            // === Total & Delete
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '\$${(widget.item.price * _quantity).toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: _deleteItem,
                  iconSize: 20,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
