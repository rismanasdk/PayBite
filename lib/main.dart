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
      home: StreamBuilder(
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
            return FutureBuilder<String>(
              future: AuthService().getUserRole(userId),
              builder: (context, roleSnapshot) {
                if (roleSnapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }

                if (roleSnapshot.data == 'admin') {
                  return const AdminPage();
                } else {
                  return const UserApp();
                }
              },
            );
          }

          // User is not logged in
          return const LoginPage();
        },
      ),
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
