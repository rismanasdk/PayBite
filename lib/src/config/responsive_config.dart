import 'dart:io';

/// Responsive breakpoints configuration
class ResponsiveConfig {
  /// Width standar iPhone 12/13
  static const double iPhoneWidth = 390;

  /// Height standar iPhone 12/13 (without notch)
  static const double iPhoneHeight = 844;

  /// Aspect ratio iPhone
  static const double iPhoneAspectRatio = iPhoneWidth / iPhoneHeight;

  /// Detect apakah running di web
  static bool isWeb() {
    try {
      return !Platform.isAndroid && !Platform.isIOS;
    } catch (e) {
      return true; // Default to web on exception
    }
  }

  /// Get device frame enabled status
  static bool isDeviceFrameEnabled() {
    // Device frame hanya untuk web
    return isWeb();
  }

  /// Get app width (dengan atau tanpa frame)
  static double getAppWidth(double screenWidth) {
    if (isWeb()) {
      // Return iPhone width untuk web
      return iPhoneWidth;
    }
    return screenWidth;
  }

  /// Get app height (dengan atau tanpa frame)
  static double getAppHeight(double screenHeight) {
    if (isWeb()) {
      // Return iPhone height untuk web
      return iPhoneHeight;
    }
    return screenHeight;
  }
}
