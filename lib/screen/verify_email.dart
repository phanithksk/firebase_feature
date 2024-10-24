// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_feature/screen/home_screen.dart';
import 'package:flutter/material.dart';
import '../controller/auth_controller.dart';

class VerifyEmailScreen extends StatefulWidget {
  final BaseAuth auth;
  final VoidCallback onSignedOut;
  const VerifyEmailScreen({
    super.key,
    required this.auth,
    required this.onSignedOut,
  });

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  bool isEmailVerify = false;
  bool canResendEmail = false;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    // VerifyEmail
    isEmailVerify = FirebaseAuth.instance.currentUser!.emailVerified;
    if (!isEmailVerify) {
      sendEmailVerification();
      timer = Timer.periodic(
        const Duration(seconds: 3),
        (_) => checkEmailVerification(),
      );
    }
  }

  Future sendEmailVerification() async {
    try {
      final user = FirebaseAuth.instance.currentUser!;
      await user.sendEmailVerification();
      setState(() => canResendEmail = false);
      await Future.delayed(const Duration(seconds: 5));
      setState(() => canResendEmail = true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  Future checkEmailVerification() async {
    final user = FirebaseAuth.instance.currentUser!;
    user.reload();
    setState(() {
      isEmailVerify = user.emailVerified;
    });
    if (isEmailVerify) timer!.cancel();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return isEmailVerify
        ? MyHomePage(
            auth: widget.auth,
            onSignedOut: widget.onSignedOut,
            title: 'Home Screen',
          )
        : Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.deepPurple[400]!,
              title: const Text(
                "Verify Email",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.0,
                  fontFamily: "Karla",
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            body: Padding(
              padding: const EdgeInsets.all(30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 50,
                  ),
                  Image.asset(
                    'assets/verify-email.png',
                    height: 200,
                  ),
                  const SizedBox(
                    height: 50,
                  ),
                  const Text(
                    "A verification email have been send to your email.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 14.0,
                      fontFamily: "Karla",
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      elevation: 0.5,
                      minimumSize: const Size.fromHeight(50),
                      backgroundColor: Colors.deepPurple[400]!.withOpacity(.6),
                    ),
                    label: const Text(
                      "Resend Email",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.0,
                        fontFamily: "Karla",
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    icon: const Icon(
                      Icons.email,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      canResendEmail ? sendEmailVerification() : null;
                    },
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      elevation: 0.5,
                      minimumSize: const Size.fromHeight(50),
                    ),
                    label: Text(
                      "Cancel",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.deepPurple[400]!.withOpacity(.6),
                        fontSize: 14.0,
                        fontFamily: "Karla",
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () {
                      FirebaseAuth.instance.signOut();
                    },
                  ),
                ],
              ),
            ),
          );
  }
}
