import 'package:flutter/material.dart';
import '../services/session_manager.dart';

/// Widget that records user activity on tap
class ActivityTracker extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;

  const ActivityTracker({
    Key? key,
    required this.child,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        SessionManager().recordUserActivity();
        onTap?.call();
      },
      child: child,
    );
  }
}

/// Extension method to add activity tracking to any widget
extension ActivityTracking on Widget {
  Widget trackActivity({VoidCallback? onTap}) {
    return ActivityTracker(
      child: this,
      onTap: onTap,
    );
  }
}
