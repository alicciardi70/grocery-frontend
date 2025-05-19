import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:grocery_scout/models/product.dart';
import 'package:grocery_scout/models/basket.dart';

class AddToBasketModal extends StatefulWidget {
  final Product product;
  final List<Basket> baskets;

  const AddToBasketModal({
    super.key,
    required this.product,
    required this.baskets,
  });

  @override
  State<AddToBasketModal> createState() => _AddToBasketModalState();
}

class _AddToBasketModalState extends State<AddToBasketModal> {
  late String selectedBasketId;
  int quantity = 1;

  @override
  void initState() {
    super.initState();
    selectedBasketId = widget.baskets.isNotEmpty ? widget.baskets.first.id : '';
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final defaultStorePrice =
        product.storePrices != null && product.storePrices!.isNotEmpty
            ? product.storePrices!.first
            : null;

    return AlertDialog(
      title: const Text('Add to Basket'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (product.imageUrl != null && product.imageUrl!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Image.network(
                  product.imageUrl!,
                  height: 120,
                  fit: BoxFit.contain,
                  errorBuilder:
                      (context, error, stackTrace) =>
                          const Icon(Icons.broken_image, size: 80),
                ),
              ),
            Text(
              product.description,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Brand: ${product.brand}',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),

            // 🧺 Basket selector
            DropdownButtonFormField<String>(
              value: selectedBasketId,
              decoration: const InputDecoration(labelText: 'Select Basket'),
              items:
                  widget.baskets.map((basket) {
                    return DropdownMenuItem<String>(
                      value: basket.id,
                      child: Text(basket.name),
                    );
                  }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    selectedBasketId = value;
                  });
                }
              },
            ),
            const SizedBox(height: 10),

            // 🔢 Quantity input
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed:
                      quantity > 1 ? () => setState(() => quantity -= 1) : null,
                ),
                Text(
                  '$quantity',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: () => setState(() => quantity += 1),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 🏷️ Price & store display
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Available at:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            if (product.storePrices != null && product.storePrices!.isNotEmpty)
              ...product.storePrices!.map(
                (storePrice) => ListTile(
                  title: Text(storePrice.store),
                  trailing: Text('\$${storePrice.price.toStringAsFixed(2)}'),
                ),
              ),
            if (product.storePrices == null || product.storePrices!.isEmpty)
              const Text("No pricing data available"),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton.icon(
          onPressed:
              defaultStorePrice == null
                  ? null
                  : () async {
                    final payload = {
                      'basket_id': selectedBasketId,
                      'upc': product.upc,
                      'producttext': product.description,
                      'brand': product.brand,
                      'size': product.size ?? '',
                      'store': defaultStorePrice.store,
                      'price': defaultStorePrice.price,
                      'quantity': quantity,
                      'image_url': product.imageUrl ?? '',
                    };

                    print("Sending payload: ${jsonEncode(payload)}");

                    final response = await http.post(
                      Uri.parse(
                        'https://api.groceryscout.net/baskets/items/add',
                      ),
                      headers: {'Content-Type': 'application/json'},
                      body: jsonEncode(payload),
                    );

                    if (response.statusCode == 200 ||
                        response.statusCode == 201) {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Item added to basket')),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Failed to add item: ${response.body}'),
                        ),
                      );
                    }
                  },
          icon: const Icon(Icons.add_shopping_cart),
          label: const Text('Add to Basket'),
        ),
      ],
    );
  }
}
