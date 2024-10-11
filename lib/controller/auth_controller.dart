import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

abstract class BaseAuth {
  Future<User?> currentUser();
  // Future<String?> signIn(String email, String password);
  // Future<String> createUser(String email, String password);
  Future<void> signOut();
  Future<String?> getEmail();
  Future<bool> isEmailVerified();
  Future<void> resetPassword(String email);
  Future<void> sendEmailVerification();
}

class Auth implements BaseAuth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  @override
  Future<User?> currentUser() async {
    User? user = _firebaseAuth.currentUser;
    if (user != null) {
      debugPrint("uid: ${user.uid}");
    }
    return user;
  }

  @override
  Future<String?> getEmail() async {
    User? user = _firebaseAuth.currentUser;
    return user?.email;
  }

  @override
  Future<void> signOut() async {
    return _firebaseAuth.signOut();
  }

  @override
  Future<bool> isEmailVerified() async {
    User? user = _firebaseAuth.currentUser;
    if (user != null) {
      await user.reload();
      user = _firebaseAuth.currentUser;
      return user?.emailVerified ?? false;
    }
    return false;
  }

  @override
  Future<void> resetPassword(String email) async {
    return _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  @override
  Future<void> sendEmailVerification() async {
    User? user = _firebaseAuth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }
}

class AuthService {
  String? emailValidator(String? val) {
    String pattern = r"^[a-zA-Z0-9._%+-]+@gmail\.com$";
    RegExp regex = RegExp(pattern);
    if (val == null || val.isEmpty) {
      return "Email is required";
    } else if (!regex.hasMatch(val)) {
      return "Email must be in the format name@gmail.com";
    } else {
      return null;
    }
  }

  Future<String?> registration({
    required String email,
    required String password,
  }) async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return 'Success';
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        return 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        return 'The account already exists for that email.';
      } else {
        return e.message;
      }
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> login({
    required String email,
    required String password,
  }) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return 'Success';
    } on FirebaseAuthException catch (e) {
      debugPrint("---e.code:${e.code}");
      if (e.code == 'user-not-found') {
        return 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        return 'Wrong password provided for that user.';
      } else {
        return e.message;
      }
    } on SocketException {
      return 'Network error. Please check your connection and try again.';
    } catch (e) {
      return 'An error occurred: ${e.toString()}';
    }
  }

  // void _passwordReset() async{
  // final form = formKey1.currentState;
  // if(form.validate()){
  //   form.save();
  //   try {
  //     await widget.auth.resetPassword(_emailpassword);
  //     Navigator.of(context).pop();
  //     final snackBar = SnackBar(content: Text("Password Reset Email Sent"));
  //     scaffoldKey.currentState.showSnackBar(snackBar);
  //   }
  //   catch(e){
  //     Fluttertoast.showToast(
  //         msg: "Invalid Input!",
  //         toastLength: Toast.LENGTH_SHORT,
  //         gravity: ToastGravity.BOTTOM,
  //     );
  //   }
  // }
}
