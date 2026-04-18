import 'package:flutter/material.dart';

class ProfileLogo extends StatelessWidget {
  const ProfileLogo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 24,
      backgroundColor: Colors.grey[300],
      child: const Icon(Icons.person, color: Colors.white, size: 28),
    );
  }
}
