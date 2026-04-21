import 'package:flutter/material.dart';
import '../../../utils/colors.dart';
import '../../../services/auth_service.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({Key? key}) : super(key: key);

  void _showLogoutMenu(BuildContext context, GlobalKey key) {
    final authService = AuthService();
    final RenderBox renderBox =
        key.currentContext!.findRenderObject() as RenderBox;
    final Offset position = renderBox.localToGlobal(Offset.zero);

    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy + renderBox.size.height, // tepat di bawah avatar
        position.dx,
        0,
      ),
      items: [
        PopupMenuItem(
          padding: EdgeInsets.zero,
          height: 40,
          child: const Center(
            child: Icon(
              Icons.logout,
              color: Colors.red,
              size: 20,
            ),
          ),
          onTap: () async {
            await authService.signOut();
            if (context.mounted) {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              );
            }
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = AuthService().currentUser;
    final avatarKey = GlobalKey();

    return Container(
      height: 90, // 🔥 lebih kecil biar center bener
      decoration: const BoxDecoration(
        color: AppColors.orangeYellow,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      alignment: Alignment.center,
      
      child: Row(
  crossAxisAlignment: CrossAxisAlignment.center,
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    /// LOGO + TEXT (digabung)
    Row(
      children: [
        Image.asset(
          'lib/src/assets/Logo.png',
          width: 40,
          height: 40,
        ),
        const SizedBox(width: 8), // 🔥 jarak dikit biar nempel
        const Text(
          'PayBite',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    ),

    /// AVATAR
    GestureDetector(
      key: avatarKey,
      onTap: () => _showLogoutMenu(context, avatarKey),
      child: SizedBox(
        width: 40,
        height: 40,
        child: currentUser?.photoURL != null
            ? CircleAvatar(
                radius: 20,
                backgroundImage:
                    NetworkImage(currentUser!.photoURL!),
              )
            : CircleAvatar(
                radius: 20,
                backgroundColor: Colors.white.withOpacity(0.3),
                child: const Center(
                  child: Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
      ),
    ),
  ],
),
    );
  }
}