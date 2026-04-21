import 'package:cloud_firestore/cloud_firestore.dart';

class Complaint {
  final String id;
  final String userId;
  final String userName;
  final String userEmail;
  final String description;
  final String photoUrl;
  final String status; // pending, resolved, rejected
  final DateTime createdAt;
  final DateTime? resolvedAt;
  final String? adminResponse;

  Complaint({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.description,
    required this.photoUrl,
    this.status = 'pending',
    required this.createdAt,
    this.resolvedAt,
    this.adminResponse,
  });

  factory Complaint.fromFirestore(Map<String, dynamic> data, String id) {
    return Complaint(
      id: id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      userEmail: data['userEmail'] ?? '',
      description: data['description'] ?? '',
      photoUrl: data['photoUrl'] ?? '',
      status: data['status'] ?? 'pending',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      resolvedAt: (data['resolvedAt'] as Timestamp?)?.toDate(),
      adminResponse: data['adminResponse'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'description': description,
      'photoUrl': photoUrl,
      'status': status,
      'createdAt': FieldValue.serverTimestamp(),
      'resolvedAt': resolvedAt,
      'adminResponse': adminResponse,
    };
  }
}
