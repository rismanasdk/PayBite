import 'package:flutter/material.dart';

class HistoryButton extends StatelessWidget {
  final VoidCallback onPressed;
  const HistoryButton({Key? key, required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: CircleAvatar(
        radius: 24,
        backgroundColor: Colors.grey[300],
        child: const Icon(Icons.history, color: Colors.white, size: 28),
      ),
    );
  }
}
