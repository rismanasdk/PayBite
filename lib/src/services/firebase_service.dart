import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';
import '../models/order.dart' as order_model;

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  late final FirebaseFirestore _firestore;

  factory FirebaseService() {
    return _instance;
  }

  FirebaseService._internal() {
    _firestore = FirebaseFirestore.instance;
  }

  // ============ PRODUK ============

  /// Get realtime stream of all products
  Stream<List<Product>> getProductsStream() {
    return _firestore.collection('products').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Product.fromFirestore(doc.data(), doc.id))
          .toList();
    });
  }

  /// Get single product by ID
  Future<Product?> getProduct(String productId) async {
    try {
      final doc = await _firestore.collection('products').doc(productId).get();
      if (doc.exists) {
        return Product.fromFirestore(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      print('Error getting product: $e');
      return null;
    }
  }

  /// Update product stock (decrease when bought)
  Future<bool> updateProductStock(String productId, int newStock) async {
    try {
      await _firestore
          .collection('products')
          .doc(productId)
          .update({'stock': newStock});
      print('Stock updated: $productId -> $newStock');
      return true;
    } catch (e) {
      print('Error updating stock for $productId: $e');
      rethrow;
    }
  }

  /// Add new product (Admin only)
  Future<String?> addProduct(Product product) async {
    try {
      final docRef =
          await _firestore.collection('products').add(product.toFirestore());
      return docRef.id;
    } catch (e) {
      print('Error adding product: $e');
      return null;
    }
  }

  /// Delete product (Admin only)
  Future<void> deleteProduct(String productId) async {
    try {
      await _firestore.collection('products').doc(productId).delete();
    } catch (e) {
      print('Error deleting product: $e');
    }
  }

  /// Update product (Admin only)
  Future<void> updateProduct(String productId, Product product) async {
    try {
      await _firestore
          .collection('products')
          .doc(productId)
          .update(product.toFirestore());
    } catch (e) {
      print('Error updating product: $e');
    }
  }

  // ============ ORDERS ============

  /// Create new order
  Future<String?> createOrder(order_model.Order order) async {
    try {
      final docRef =
          await _firestore.collection('orders').add(order.toFirestore());
      return docRef.id;
    } catch (e) {
      print('Error creating order: $e');
      return null;
    }
  }

  /// Get user's order history
  Stream<List<order_model.Order>> getUserOrdersStream(String userId) {
    return _firestore
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => order_model.Order.fromFirestore(doc.data(), doc.id))
          .toList();
    });
  }

  /// Get all orders (Admin only)
  Stream<List<order_model.Order>> getAllOrdersStream() {
    return _firestore
        .collection('orders')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => order_model.Order.fromFirestore(doc.data(), doc.id))
          .toList();
    });
  }

  /// Update order status
  Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      await _firestore
          .collection('orders')
          .doc(orderId)
          .update({'status': status});
    } catch (e) {
      print('Error updating order status: $e');
    }
  }

  // ============ USERS ============

  /// Get user role (admin or user)
  Future<String?> getUserRole(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return doc.data()?['role'] as String?;
      }
      return 'user'; // Default role
    } catch (e) {
      print('Error getting user role: $e');
      return 'user';
    }
  }

  /// Create user document
  Future<void> createUserDocument(String userId, {String role = 'user'}) async {
    try {
      await _firestore.collection('users').doc(userId).set({
        'role': role,
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error creating user document: $e');
    }
  }
}
