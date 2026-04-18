import 'package:flutter/material.dart';
import 'widgets/home_header.dart';
import 'widgets/search_bar.dart';
import 'widgets/product_list.dart';
import 'widgets/cart_bottom_sheet.dart';
import 'widgets/history_button.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Map<String, dynamic>> _cart = [];

  void _addToCart(Map<String, dynamic> product) {
    setState(() {
      final existingIndex =
          _cart.indexWhere((item) => item['name'] == product['name']);
      if (existingIndex >= 0) {
        _cart[existingIndex]['quantity'] =
            (_cart[existingIndex]['quantity'] ?? 1) + 1;
      } else {
        _cart.add({
          ...product,
          'quantity': product['quantity'] ?? 1,
          'price': 25000, // Harga default, bisa disesuaikan
        });
      }
    });
  }

  void _removeFromCart(int index) {
    setState(() {
      _cart.removeAt(index);
    });
  }

  void _updateQuantity(int index, int quantity) {
    setState(() {
      if (quantity <= 0) {
        _cart.removeAt(index);
      } else {
        _cart[index]['quantity'] = quantity;
      }
    });
  }

  int _getTotalPrice() {
    int total = 0;
    for (var item in _cart) {
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
      builder: (context) => CartBottomSheet(
        cart: _cart,
        onRemove: _removeFromCart,
        onUpdateQuantity: _updateQuantity,
        totalPrice: _getTotalPrice(),
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
            const SearchBarWidget(),
            const SizedBox(height: 16),
            Expanded(
              child: ProductList(onAddToCart: _addToCart),
            ),
          ],
        ),
        Positioned(
          top: 40,
          right: 24,
          child: HistoryButton(
            onPressed: () {
              Navigator.pushNamed(context, '/history');
            },
          ),
        ),
        if (_cart.isNotEmpty)
          Positioned(
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
                            'Keranjang (${_cart.length})',
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
                        'Konfirmasi',
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
          ),
      ],
    );
  }
}
