import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/basket.dart';
import '../services/api_service.dart';
import '../widgets/basket_tile.dart';
import '../providers/user_provider.dart';

class BasketsScreen extends StatefulWidget {
  const BasketsScreen({Key? key}) : super(key: key);

  @override
  State<BasketsScreen> createState() => _BasketsScreenState();
}

class _BasketsScreenState extends State<BasketsScreen> {
  List<Basket> _baskets = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadBaskets();
  }

  Future<void> _loadBaskets() async {
    final userId = Provider.of<UserProvider>(context, listen: false).userId!;
    try {
      final baskets = await ApiService.getBasketsByUser(userId);
      setState(() {
        _baskets = baskets;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      debugPrint('Error loading baskets: $e');
    }
  }

  void _showCreateBasketDialog() {
    final TextEditingController _nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Create New Basket"),
          content: TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: "Basket Name"),
          ),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              child: const Text("Create"),
              onPressed: () async {
                final name = _nameController.text.trim();
                if (name.isEmpty) return;

                final userId =
                    Provider.of<UserProvider>(context, listen: false).userId!;
                Navigator.pop(context);

                try {
                  await ApiService.createBasket(userId: userId, name: name);
                  await _loadBaskets();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Failed to create basket")),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteBasketLocally(String basketId) {
    setState(() {
      _baskets.removeWhere((b) => b.id == basketId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Baskets')),
      body:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : _baskets.isEmpty
              ? const Center(child: Text("No baskets found."))
              : ListView.builder(
                itemCount: _baskets.length,
                itemBuilder: (context, index) {
                  final basket = _baskets[index];
                  return BasketTile(
                    basket: basket,
                    onDelete: () => _deleteBasketLocally(basket.id),
                  );
                },
              ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text("New Basket"),
        onPressed: _showCreateBasketDialog,
      ),
    );
  }
}
