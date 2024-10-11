import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_feature/controller/auth_controller.dart';
import 'package:firebase_feature/firebase_options.dart';
import 'package:firebase_feature/screen/splash_screen.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  final BaseAuth auth = Auth();

  MyApp({super.key});
  @override
  MyAppState createState() {
    return MyAppState();
  }
}

class MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(
        auth: widget.auth,
      ),
    );
  }
}
