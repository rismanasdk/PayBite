import 'package:flutter/material.dart';
import 'widgets/home_header.dart';
import 'widgets/search_bar.dart';
import 'widgets/product_list.dart';
import 'widgets/cart_bottom_sheet.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final ValueNotifier<List<Map<String, dynamic>>> _cartNotifier;
  late final ValueNotifier<String> _searchNotifier;

  @override
  void initState() {
    super.initState();
    _cartNotifier = ValueNotifier<List<Map<String, dynamic>>>([]);
    _searchNotifier = ValueNotifier<String>('');
  }

  @override
  void dispose() {
    _cartNotifier.dispose();
    _searchNotifier.dispose();
    super.dispose();
  }

  void _addToCart(Map<String, dynamic> product) {
    final cart = _cartNotifier.value;
    final existingIndex =
        cart.indexWhere((item) => item['name'] == product['name']);
    if (existingIndex >= 0) {
      cart[existingIndex]['quantity'] =
          (cart[existingIndex]['quantity'] ?? 1) + 1;
    } else {
      cart.add({
        ...product,
        'quantity': product['quantity'] ?? 1,
        'price': product['price'],
      });
    }
    _cartNotifier.value = [...cart]; // Trigger rebuild only for cart
  }

  void _removeFromCart(int index) {
    final cart = _cartNotifier.value;
    cart.removeAt(index);
    _cartNotifier.value = [...cart];
  }

  void _updateQuantity(int index, int quantity) {
    final cart = _cartNotifier.value;
    if (quantity <= 0) {
      cart.removeAt(index);
    } else {
      cart[index]['quantity'] = quantity;
    }
    _cartNotifier.value = [...cart];
  }

  int _getTotalPrice() {
    int total = 0;
    for (var item in _cartNotifier.value) {
      total +=
          (((item['price'] ?? 0) as int) * (item['quantity'] ?? 1)).toInt();
    }
    return total;
  }

  void _showCartBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      builder: (context) => ValueListenableBuilder<List<Map<String, dynamic>>>(
        valueListenable: _cartNotifier,
        builder: (context, cart, _) => CartBottomSheet(
          cart: cart,
          onRemove: _removeFromCart,
          onUpdateQuantity: _updateQuantity,
          totalPrice: _getTotalPrice(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            const HomeHeader(),
            const SizedBox(height: 16),
            SearchBarWidget(searchNotifier: _searchNotifier),
            const SizedBox(height: 16),
            Expanded(
              child: ValueListenableBuilder<String>(
                valueListenable: _searchNotifier,
                builder: (context, searchQuery, _) {
                  return ProductList(
                    onAddToCart: _addToCart,
                    searchQuery: searchQuery,
                  );
                },
              ),
            ),
          ],
        ),
        ValueListenableBuilder<List<Map<String, dynamic>>>(
          valueListenable: _cartNotifier,
          builder: (context, cart, _) {
            if (cart.isEmpty) {
              return const SizedBox.shrink();
            }
            return Positioned(
              bottom: 24,
              left: 24,
              right: 24,
              child: GestureDetector(
                onTap: () => _showCartBottomSheet(context),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.shopping_cart, color: Colors.orange),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Cart (${cart.length})',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Total: Rp${_getTotalPrice().toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => '.')}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFC447),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Confirm Order',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
