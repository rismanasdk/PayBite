import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'src/features/home/home_page.dart';
import 'src/features/complaint/complaint_page.dart';
import 'src/features/history/history_page.dart';
import 'src/features/checkout/notes_page.dart';
import 'src/features/auth/login_page.dart';
import 'src/features/admin/admin_page.dart';
import 'src/services/auth_service.dart';
import 'src/services/session_manager.dart';
import 'src/config/responsive_config.dart';
import 'src/widgets/iphone_device_frame.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const PaybiteApp());
}

class PaybiteApp extends StatelessWidget {
  const PaybiteApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ResponsiveConfig.isWeb()
          ? IPhoneDeviceFrame(
              child: _buildHomeContent(),
            )
          : _buildHomeContent(),
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/history':
            return MaterialPageRoute(
              builder: (context) => const HistoryPage(),
            );
          case '/checkout':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (context) => NotesPage(
                cartItems: args['cartItems'],
                totalPrice: args['totalPrice'],
              ),
            );
          default:
            return null;
        }
      },
    );
  }

  Widget _buildHomeContent() {
    return StreamBuilder(
      stream: AuthService().authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          // User is logged in
          final userId = snapshot.data!.uid;
          // Start session monitoring
          AuthService().startSessionMonitoring();

          return FutureBuilder<String>(
            future: AuthService().getUserRole(userId),
            builder: (context, roleSnapshot) {
              if (roleSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              if (roleSnapshot.data == 'admin') {
                return SessionActivityWrapper(child: AdminPage());
              } else {
                return SessionActivityWrapper(child: UserApp());
              }
            },
          );
        }

        // User is not logged in
        return const LoginPage();
      },
    );
  }
}

class UserApp extends StatefulWidget {
  const UserApp({Key? key}) : super(key: key);

  @override
  State<UserApp> createState() => _UserAppState();
}

class _UserAppState extends State<UserApp> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const HistoryPage(),
    const ComplaintPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(icon: Icon(Icons.report), label: 'Complaint'),
        ],
      ),
    );
  }
}

/// Wrapper widget to track user activity and handle session timeout
class SessionActivityWrapper extends StatefulWidget {
  final Widget child;

  const SessionActivityWrapper({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  State<SessionActivityWrapper> createState() => _SessionActivityWrapperState();
}

class _SessionActivityWrapperState extends State<SessionActivityWrapper>
    with WidgetsBindingObserver {
  final SessionManager _sessionManager = SessionManager();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // App is back to foreground - check if session still valid
      _checkSessionValidity();
    }
  }

  Future<void> _checkSessionValidity() async {
    final userId = AuthService().currentUser?.uid;
    if (userId == null) return;

    final isValid = await _sessionManager.validateSessionFromFirestore(userId);

    if (!isValid && mounted) {
      // Session expired - logout
      await AuthService().signOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _sessionManager.recordUserActivity();
      },
      child: widget.child,
    );
  }
}
