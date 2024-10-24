import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_feature/controller/auth_controller.dart';
import 'package:firebase_feature/screen/sign_in_screen.dart';
import 'package:flutter/material.dart';
import 'verify_email.dart';

class CheckUser extends StatefulWidget {
  const CheckUser({super.key, required this.auth});
  final BaseAuth auth;

  @override
  State<CheckUser> createState() => _CheckUserState();
}

class _CheckUserState extends State<CheckUser> {
  AuthStatus authStatus = AuthStatus.notSignedIn;
  String userId = "";
  bool isEmailVerify = false;
  Timer? timer;
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

  void signedIn() {
    setState(() {
      authStatus = AuthStatus.signedIn;
      widget.auth.currentUser().then((user) {
        userId = user!.uid.toString();
      });
    });
  }

  void signedOut() {
    setState(() {
      authStatus = AuthStatus.notSignedIn;
      userId = "";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return VerifyEmailScreen(
              auth: widget.auth,
              onSignedOut: signedOut,
            );
          } else {
            return SigninScreen(
              auth: widget.auth,
              onSignedIn: signedIn,
            );
          }
        },
      ),
    );
  }
}

enum AuthStatus {
  signedIn,
  notSignedIn,
}
 // switch (authStatus) {
    //   case AuthStatus.notSignedIn:
    //     return SigninScreen(
    //       auth: widget.auth,
    //       onSignedIn: _signedIn,
    //     );

    //   case AuthStatus.signedIn:
    //     return isEmailVerify
    //         ? MyHomePage(
    //             auth: widget.auth,
    //             onSignedOut: _signedOut,
    //             title: 'Home Screen',
    //           )
    //         : Scaffold(
    //             appBar: AppBar(
    //               backgroundColor: Colors.deepPurple[400]!,
    //               title: const Text(
    //                 "Verify Email",
    //                 style: TextStyle(color: Colors.white),
    //               ),
    //             ),
    //           );
    // }