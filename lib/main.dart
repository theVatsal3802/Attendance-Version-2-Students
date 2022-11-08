import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import './screens/home.dart';
import './DbHelper/db_connection.dart';
import './auth/auth_screen.dart';
import './auth/verify_email_screen.dart';
import './screens/splash_screen.dart';
import './screens/confirm_screen.dart';
import './screens/absent_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
    [
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
    ],
  );
  await MongoDB.connect();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Attendance IIIT Kota",
      theme: ThemeData(
        colorScheme: ColorScheme(
          brightness: Brightness.light,
          primary: const Color.fromRGBO(0, 51, 102, 1),
          onPrimary: Colors.white,
          secondary: const Color.fromRGBO(255, 102, 0, 1),
          onSecondary: Colors.white,
          error: Colors.red.shade800,
          onError: Colors.white,
          background: const Color.fromRGBO(0, 51, 102, 1),
          onBackground: Colors.white,
          surface: const Color.fromRGBO(255, 102, 0, 1),
          onSurface: Colors.grey.shade500,
        ),
      ),
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SplashScreen();
          } else if (snapshot.hasData) {
            return const VerifyEmailScreen();
          }
          return const AuthScreen();
        },
      ),
      routes: {
        Home.routeName: (context) => const Home(),
        AuthScreen.routeName: (context) => const AuthScreen(),
        VerifyEmailScreen.routeName: (context) => const VerifyEmailScreen(),
        ConfirmScreen.routeName: (context) => const ConfirmScreen(),
        AbsentScreen.routeName: (context) => const AbsentScreen(),
      },
    );
  }
}
