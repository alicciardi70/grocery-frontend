import 'package:flutter/material.dart';
import 'package:provider/provider.dart';               // ✅ required for Provider
import '../providers/user_provider.dart';              // ✅ your custom provider
import '../models/basket.dart';
import '../services/api_service.dart';
import 'add_to_basket_modal.dart';

class ProductTile extends StatelessWidget {
  final Map<String, dynamic> productData;

  const ProductTile({
    Key? key,
    required this.productData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    throw Exception('🚨 TEST EXCEPTION: ProductTile build triggered');
    print('🧪 productData: $productData');

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: Image.network(
          'https://upload.wikimedia.org/wikipedia/commons/thumb/a/a9/Example.jpg/640px-Example.jpg',
          width: 64,
          height: 64,
          fit: BoxFit.cover,
        ),
        title: const Text('TEST TILE'),
        subtitle: const Text('DEBUG: I am rendering subtitle'),
        trailing: IconButton(
          icon: const Icon(Icons.add_shopping_cart),
          onPressed: () async {
            final userId =
                Provider.of<UserProvider>(context, listen: false).userId!;
            final baskets = await ApiService.getBasketsByUser(userId);

            showDialog(
              context: context,
              builder: (_) => AddToBasketModal(
                userId: userId,
                baskets: baskets,
                product: productData,
              ),
            );
          },
        ),
        isThreeLine: true,
      ),
    );
  }
}

