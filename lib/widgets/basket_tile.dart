import 'package:flutter/material.dart';
import '../models/basket.dart';
import '../screens/basket_detail_screen.dart';
import '../services/api_service.dart'; // ✅ Needed for deleteBasket call

class BasketTile extends StatelessWidget {
  final Basket basket;
  final VoidCallback? onDelete; // ✅ Optional callback for refreshing parent

  const BasketTile({Key? key, required this.basket, this.onDelete})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.shopping_basket),
        title: Text(
          '${basket.name} (${basket.itemCount} item${basket.itemCount == 1 ? '' : 's'})',
        ),
        subtitle: Text('Created: ${basket.createdAt.toLocal()}'),
        isThreeLine: false,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (_) => BasketDetailScreen(
                    basketId: basket.id,
                    basketName: basket.name,
                  ),
            ),
          );
        },
        trailing: IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () async {
            await ApiService.deleteBasket(basket.id); // ✅ Call backend
            onDelete?.call(); // ✅ Notify parent to refresh UI
          },
        ),
      ),
    );
  }
}
