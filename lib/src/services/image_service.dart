import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'firebase_service.dart';

/// Service untuk image picking dan uploading
class ImageService {
  final ImagePicker _imagePicker = ImagePicker();
  final FirebaseService _firebaseService = FirebaseService();

  /// Pick image dari gallery
  Future<XFile?> pickImageFromGallery({
    required BuildContext context,
    String? errorMessage,
  }) async {
    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      return image;
    } catch (e) {
      _showError(context, errorMessage ?? 'Error picking image: $e');
      return null;
    }
  }

  /// Pick image dari camera
  Future<XFile?> pickImageFromCamera({
    required BuildContext context,
    String? errorMessage,
  }) async {
    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );
      return image;
    } catch (e) {
      _showError(context, errorMessage ?? 'Error taking photo: $e');
      return null;
    }
  }

  /// Upload image ke Firebase Storage
  Future<String?> uploadImage(XFile imageFile) async {
    try {
      return await _firebaseService.uploadProductImage(imageFile);
    } catch (e) {
      print('Error uploading image: $e');
      rethrow;
    }
  }

  /// Pick dan upload image langsung
  Future<String?> pickAndUploadImage({
    required BuildContext context,
    bool fromCamera = false,
  }) async {
    final image = fromCamera
        ? await pickImageFromCamera(context: context)
        : await pickImageFromGallery(context: context);

    if (image == null) return null;

    try {
      return await uploadImage(image);
    } catch (e) {
      _showError(context, 'Error uploading image: $e');
      return null;
    }
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}
