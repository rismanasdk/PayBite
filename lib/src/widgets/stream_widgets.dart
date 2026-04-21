import 'package:flutter/material.dart';

/// Widget untuk loading state di StreamBuilder
class StreamLoadingWidget extends StatelessWidget {
  const StreamLoadingWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

/// Widget untuk error state di StreamBuilder
class StreamErrorWidget extends StatelessWidget {
  final dynamic error;
  final Color? iconColor;
  final double iconSize;

  const StreamErrorWidget({
    Key? key,
    required this.error,
    this.iconColor,
    this.iconSize = 48,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error,
            size: iconSize,
            color: iconColor ?? Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text('Error: $error'),
        ],
      ),
    );
  }
}

/// Widget untuk empty state di StreamBuilder
class StreamEmptyWidget extends StatelessWidget {
  final String message;
  final IconData? icon;
  final double iconSize;

  const StreamEmptyWidget({
    Key? key,
    required this.message,
    this.icon,
    this.iconSize = 48,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon ?? Icons.info,
            size: iconSize,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
