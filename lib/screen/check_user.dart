import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_feature/controller/auth_controller.dart';
import 'package:firebase_feature/screen/auth/sign_in_screen.dart';
import 'package:firebase_feature/screen/home_screen.dart';
import 'package:flutter/material.dart';
import 'auth/verify_email.dart';

class CheckUser extends StatefulWidget {
  const CheckUser({super.key});

  @override
  State<CheckUser> createState() => _CheckUserState();
}

class _CheckUserState extends State<CheckUser> {
  String userId = "";

  @override
  void initState() {
    super.initState();
    AuthService().currentUser().then((user) {
      setState(() {
        if (user != null) {
          userId = user.uid;
        }
      });
    });
  }

  bool isEmailLogin(User user) {
    return user.providerData
        .any((provider) => provider.providerId == 'password');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            User? user = snapshot.data;
            if (user != null && isEmailLogin(user)) {
              if (!user.emailVerified) {
                return const VerifyEmailScreen();
              } else {
                return const MyHomePage();
              }
            } else {
              return const MyHomePage();
            }
          } else {
            return const SigninScreen();
          }
        },
      ),
    );
  }
}
