import 'package:firebase_feature/controller/auth_controller.dart';
import 'package:firebase_feature/screen/home_screen.dart';
import 'package:firebase_feature/screen/sign_in_screen.dart';
import 'package:flutter/material.dart';

class CheckUser extends StatefulWidget {
  const CheckUser({super.key, required this.auth});
  final BaseAuth auth;

  @override
  State<CheckUser> createState() => _CheckUserState();
}

class _CheckUserState extends State<CheckUser> {
  AuthStatus authStatus = AuthStatus.notSignedIn;
  String userId = "";
  @override
  void initState() {
    super.initState();
    widget.auth.currentUser().then((user) {
      setState(() {
        if (user != null) {
          userId = user.uid;
        }
        authStatus =
            user?.uid == null ? AuthStatus.notSignedIn : AuthStatus.signedIn;
      });
    });
  }

  void _signedIn() {
    setState(() {
      authStatus = AuthStatus.signedIn;
      widget.auth.currentUser().then((user) {
        userId = user!.uid.toString();
      });
    });
  }

  void _signedOut() {
    setState(() {
      authStatus = AuthStatus.notSignedIn;
      userId = "";
    });
  }

  @override
  Widget build(BuildContext context) {
    switch (authStatus) {
      case AuthStatus.notSignedIn:
        return SigninScreen(
          auth: widget.auth,
          onSignedIn: _signedIn,
        );

      case AuthStatus.signedIn:
        return MyHomePage(
          auth: widget.auth,
          onSignedOut: _signedOut,
          title: 'Home Screen',
        );
    }
  }
}

enum AuthStatus {
  signedIn,
  notSignedIn,
}
