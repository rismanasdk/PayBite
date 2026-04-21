import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import '../models/product.dart';
import '../models/order.dart' as order_model;
import '../models/complaint.dart';
import '../config/cloudinary_config.dart';

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

  /// Upload product image to Cloudinary
  Future<String> uploadProductImage(XFile imageFile) async {
    try {
      if (!CloudinaryConfig.isConfigured()) {
        print('Cloudinary not configured!');
        return imageFile.path;
      }

      final bytes = await imageFile.readAsBytes();
      final request =
          http.MultipartRequest('POST', Uri.parse(CloudinaryConfig.uploadUrl));

      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: imageFile.name,
        ),
      );
      request.fields['upload_preset'] = CloudinaryConfig.uploadPreset;

      final response = await request.send();

      if (response.statusCode == 200) {
        final responseData = await response.stream.toBytes();
        final responseString = String.fromCharCodes(responseData);
        final imageUrl = _extractUrlFromResponse(responseString);
        print('Cloudinary upload success: $imageUrl');
        return imageUrl;
      } else {
        print('Cloudinary upload failed: ${response.statusCode}');
        // Fallback ke local path
        return imageFile.path;
      }
    } catch (e) {
      print('Error uploading to Cloudinary: $e');
      // Fallback ke local path
      return imageFile.path;
    }
  }

  /// Extract URL from Cloudinary response
  String _extractUrlFromResponse(String response) {
    try {
      // Simple JSON parsing untuk extract secure_url
      final urlMatch = RegExp(r'"secure_url":"([^"]+)"').firstMatch(response);
      if (urlMatch != null) {
        return urlMatch.group(1) ?? '';
      }
      return '';
    } catch (e) {
      print('Error parsing Cloudinary response: $e');
      return '';
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

  // ============ COMPLAINTS ============

  /// Submit a new complaint
  Future<void> submitComplaint(Complaint complaint) async {
    try {
      await _firestore.collection('complaints').add(complaint.toFirestore());
      print('Complaint submitted successfully');
    } catch (e) {
      print('Error submitting complaint: $e');
      rethrow;
    }
  }

  /// Get all complaints for a user
  Stream<List<Complaint>> getUserComplaintsStream(String userId) {
    return _firestore
        .collection('complaints')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Complaint.fromFirestore(doc.data(), doc.id))
          .toList();
    });
  }

  /// Get all complaints (Admin only)
  Stream<List<Complaint>> getAllComplaintsStream() {
    return _firestore
        .collection('complaints')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Complaint.fromFirestore(doc.data(), doc.id))
          .toList();
    });
  }

  /// Get pending complaints only (Admin only)
  Stream<List<Complaint>> getPendingComplaintsStream() {
    return _firestore
        .collection('complaints')
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Complaint.fromFirestore(doc.data(), doc.id))
          .toList();
    });
  }

  /// Update complaint status with admin response
  Future<void> updateComplaintStatus(
    String complaintId,
    String status,
    String? adminResponse,
  ) async {
    try {
      await _firestore.collection('complaints').doc(complaintId).update({
        'status': status,
        'adminResponse': adminResponse,
        'resolvedAt': status != 'pending' ? FieldValue.serverTimestamp() : null,
      });
      print('Complaint updated: $complaintId -> $status');
    } catch (e) {
      print('Error updating complaint: $e');
      rethrow;
    }
  }

  /// Delete complaint (Admin only)
  Future<void> deleteComplaint(String complaintId) async {
    try {
      await _firestore.collection('complaints').doc(complaintId).delete();
      print('Complaint deleted: $complaintId');
    } catch (e) {
      print('Error deleting complaint: $e');
      rethrow;
    }
  }
}
