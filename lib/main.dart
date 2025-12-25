import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_app/models/light_mode.dart';
import 'firebase_options.dart';
import 'package:flutter_app/screens/auth/loginpage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login Page Example',
      debugShowCheckedModeBanner: false,
      //theme: ThemeData(
      //  primarySwatch: Colors.blue,
      // appBarTheme: const AppBarTheme(backgroundColor: Colors.blue),
      //),
      home: LoginPage(),
      theme: lightMode,
    );
  }
}
