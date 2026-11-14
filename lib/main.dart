import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'theme/dark_theme.dart';
import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';
import 'services/auth_service.dart';
import 'firebase_options.dart'; // генерируется командой flutterfire configure

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const BudgetApp());
}

class BudgetApp extends StatelessWidget {
  const BudgetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Бюджет',
      debugShowCheckedModeBanner: false,
      theme: buildDarkTheme(),
      home: StreamBuilder(
        stream: AuthService.instance.userChanges,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          return snapshot.data == null ? const AuthScreen() : const HomeScreen();
        },
      ),
    );
  }
}
