import 'package:flutter/material.dart';
import '../../../models/product.dart';
import '../../../services/firebase_service.dart';
import '../../../widgets/stream_widgets.dart';
import '../../../widgets/cached_image_widget.dart';
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
          return const StreamLoadingWidget();
        }

        if (snapshot.hasError) {
          return StreamErrorWidget(
            error: snapshot.error,
            iconColor: Colors.red,
          );
        }

        var products = snapshot.data ?? [];
        products = _filterProducts(products);

        if (products.isEmpty) {
          return StreamEmptyWidget(
            message: searchQuery.isEmpty
                ? 'No products available'
                : 'Product not found',
            icon: Icons.fastfood,
            iconSize: 64,
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
