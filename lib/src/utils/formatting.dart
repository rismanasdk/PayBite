/// Price formatting utilities
class PriceFormatter {
  /// Format price to Indonesian Rupiah format with thousand separators
  /// Example: 15000 -> "15.000"
  static String formatPrice(int price) {
    return price.toString().replaceAllMapped(
          RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (match) => '.',
        );
  }

  /// Format price with Rp prefix
  /// Example: 15000 -> "Rp15.000"
  static String formatPriceWithCurrency(int price) {
    return 'Rp${formatPrice(price)}';
  }
}
