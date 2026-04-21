import 'package:flutter/material.dart';
import '../../../models/product.dart';
import '../../../services/firebase_service.dart';
import 'product_card.dart';

class ProductList extends StatelessWidget {
  final void Function(Map<String, dynamic>) onAddToCart;
  final String searchQuery;

  const ProductList({
    Key? key,
    required this.onAddToCart,
    this.searchQuery = '',
  }) : super(key: key);

  /// Filter produk berdasarkan search query
  List<Product> _filterProducts(List<Product> products) {
    if (searchQuery.isEmpty) {
      return products;
    }

    final query = searchQuery.toLowerCase();
    return products
        .where((product) =>
            product.name.toLowerCase().contains(query) ||
            product.price.toString().contains(query))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final firebaseService = FirebaseService();

    return StreamBuilder<List<Product>>(
      stream: firebaseService.getProductsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 48, color: Colors.red),
                const SizedBox(height: 20),
                Text('Error: ${snapshot.error}'),
              ],
            ),
          );
        }

        var products = snapshot.data ?? [];
        products = _filterProducts(products);

        if (products.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.fastfood, size: 64, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text(
                  searchQuery.isEmpty
                      ? 'No products available'
                      : 'Product not found',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.55,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return ProductCard(product: product, onAddToCart: onAddToCart);
          },
        );
      },
    );
  }
}
