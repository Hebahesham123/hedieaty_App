import 'package:flutter/material.dart';
import 'package:hediaty_appp/Views/SignIn.dart';
import 'package:hediaty_appp/Views/SignUp.dart';
import 'package:hediaty_appp/Views/HomeScreen.dart';
import 'package:firebase_core/firebase_core.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();  // Initialize Firebase before the app starts
  runApp( MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Authentication App',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/signin',
      routes: {
        '/signin': (context) => SignInScreen(),
        '/signup': (context) => SignUpScreen(),
        '/main': (context) => MainScreen(),
      },
    );
  }
}
