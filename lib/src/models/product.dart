class Product {
  final String id;
  final String name;
  final String image;
  final int stock;
  final int price;

  Product({
    required this.id,
    required this.name,
    required this.image,
    required this.stock,
    required this.price,
  });

  // Convert Firestore document to Product
  factory Product.fromFirestore(Map<String, dynamic> data, String docId) {
    return Product(
      id: docId,
      name: data['name'] ?? '',
      image: data['image'] ?? '',
      stock: data['stock'] ?? 0,
      price: data['price'] ?? 0,
    );
  }

  // Convert Product to Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'image': image,
      'stock': stock,
      'price': price,
    };
  }
}
