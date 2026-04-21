import 'package:flutter/material.dart';

/// Validation utilities untuk form validation dan error handling
class ValidationUtils {
  /// Validate required field
  static bool validateRequired(
    String value,
    String fieldName,
    BuildContext context,
  ) {
    if (value.isEmpty) {
      _showError(context, 'Please enter $fieldName');
      return false;
    }
    return true;
  }

  /// Validate email format
  static bool validateEmail(String email, BuildContext context) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(email)) {
      _showError(context, 'Please enter a valid email address');
      return false;
    }
    return true;
  }

  /// Validate password strength
  static bool validatePassword(String password, BuildContext context) {
    if (password.length < 6) {
      _showError(context, 'Password must be at least 6 characters long');
      return false;
    }
    return true;
  }

  /// Validate number field
  static bool validateNumber(
    String value,
    String fieldName,
    BuildContext context,
  ) {
    if (value.isEmpty) {
      _showError(context, 'Please enter $fieldName');
      return false;
    }

    if (int.tryParse(value) == null) {
      _showError(context, '$fieldName must be a valid number');
      return false;
    }
    return true;
  }

  /// Show validation error
  static void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Show success message
  static void showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Show info message
  static void showInfo(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.blue,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
