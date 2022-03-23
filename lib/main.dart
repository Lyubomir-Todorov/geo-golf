import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// Import our screens here!
import 'screens/login.dart';
import 'screens/register.dart';
import 'package:final_project/screens/settings.dart';
import 'package:final_project/screens/landing.dart';
import 'package:final_project/screens/country_select.dart';
import 'package:final_project/screens/street_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Final Project',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),

      initialRoute: FirebaseAuth.instance.currentUser == null ? '/login' : '/main',
      routes: {
        '/login': (context) => Login(),
        '/register': (context) => const Register(),
        '/main': (context) => const Landing(),
        '/settings': (context) => const Settings(),
        '/country': (context) => const CountrySelection(),
        '/streetview': (context) => StreetView(),
      },
    );
  }
}