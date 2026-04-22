import 'package:flutter/material.dart';
import '../config/responsive_config.dart';

/// iPhone device frame wrapper untuk web display
class IPhoneDeviceFrame extends StatelessWidget {
  final Widget child;
  final Color frameColor;
  final Color bezelColor;
  final double notchHeight;

  const IPhoneDeviceFrame({
    Key? key,
    required this.child,
    this.frameColor = const Color(0xFF1D1D1D),
    this.bezelColor = const Color(0xFF000000),
    this.notchHeight = 44,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isWeb = ResponsiveConfig.isWeb();

    if (!isWeb) {
      // Return child as-is for mobile platforms
      return child;
    }

    // Calculate scale to fit iPhone frame in screen
    final maxWidth = screenSize.width * 0.95;
    final maxHeight = screenSize.height * 0.95;

    final widthRatio = maxWidth / (ResponsiveConfig.iPhoneWidth + 20);
    final heightRatio = maxHeight / (ResponsiveConfig.iPhoneHeight + 120);
    final scale =
        (widthRatio < heightRatio ? widthRatio : heightRatio).clamp(0.5, 1.0);

    final frameWidth = ResponsiveConfig.iPhoneWidth + 20;
    final frameHeight = ResponsiveConfig.iPhoneHeight + 120;
    final scaledWidth = frameWidth * scale;
    final scaledHeight = frameHeight * scale;

    return Center(
      child: Transform.scale(
        scale: scale,
        child: Container(
          width: frameWidth,
          height: frameHeight,
          decoration: BoxDecoration(
            color: frameColor,
            borderRadius: BorderRadius.circular(50),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 30,
                offset: const Offset(0, 20),
              ),
            ],
          ),
          child: Column(
            children: [
              // Top Bezel dengan Notch
              Container(
                width: double.infinity,
                height: 15,
                decoration: BoxDecoration(
                  color: bezelColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(50),
                    topRight: Radius.circular(50),
                  ),
                ),
              ),

              // Notch (Dynamic Island)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 80, vertical: 8),
                child: Container(
                  height: notchHeight,
                  decoration: BoxDecoration(
                    color: bezelColor,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 5,
                      ),
                    ],
                  ),
                ),
              ),

              // Screen Content
              Expanded(
                child: Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(40),
                    child: child,
                  ),
                ),
              ),

              // Bottom Bezel
              Container(
                width: double.infinity,
                height: 20,
                decoration: BoxDecoration(
                  color: bezelColor,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(50),
                    bottomRight: Radius.circular(50),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
