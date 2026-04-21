import 'package:flutter/material.dart';
import '../models/order.dart';
import '../utils/formatting.dart';
import 'cached_image_widget.dart';

/// Reusable widget untuk menampilkan order item
class OrderItemCard extends StatelessWidget {
  final OrderItem item;
  final EdgeInsets padding;
  final bool showImage;
  final bool showPrice;

  const OrderItemCard({
    Key? key,
    required this.item,
    this.padding = const EdgeInsets.all(12),
    this.showImage = true,
    this.showPrice = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        children: [
          if (showImage) ...[
            CachedImageWidget(
              imageUrl: item.productImage,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              borderRadius: BorderRadius.circular(8),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'x${item.quantity} @ Rp${PriceFormatter.formatPrice(item.price)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          if (showPrice) ...[
            const SizedBox(width: 12),
            Text(
              'Rp${PriceFormatter.formatPrice(item.price * item.quantity)}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.right,
            ),
          ],
        ],
      ),
    );
  }
}
