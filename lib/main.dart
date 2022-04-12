import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:google_fonts/google_fonts.dart';

// Import our screens here!
import 'screens/login.dart';
import 'screens/register.dart';
import 'package:final_project/screens/landing.dart';
import 'package:final_project/screens/street_view.dart';
import 'package:final_project/screens/how_to_play.dart';
import 'package:final_project/screens/match_results.dart';


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

    final textTheme = Theme.of(context).textTheme;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Final Project',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        textTheme: TextTheme(

          headline1: GoogleFonts.workSans(
            textStyle: textTheme.headline1,
            fontWeight: FontWeight.w900,
            fontSize: 36
          ),

          headline2: GoogleFonts.openSans(
            textStyle: textTheme.headline2,
            fontWeight: FontWeight.w900,
            fontSize: 20
          ),

          headline5: const TextStyle(
            fontWeight: FontWeight.w900,
            color: Colors.grey,
            fontSize: 24
          )
        ),
      ),

      initialRoute: FirebaseAuth.instance.currentUser == null ? '/login' : '/main',
      routes: {
        '/login': (context) => Login(),
        '/register': (context) => const Register(),
        '/main': (context) => const Landing(),
        '/how_to_play': (context) => const HowToPlay(),
        '/streetview': (context) => const StreetView(),
        '/match_results': (context) => const MatchResults(),
      },
    );
  }
}