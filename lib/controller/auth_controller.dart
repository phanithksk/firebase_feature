import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

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

  Future<String?> signUp({
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

  Future<String?> forgotPassword({required String email}) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      return "Password reset email sent.";
    } on FirebaseAuthException catch (err) {
      if (err.code == 'user-not-found') {
        return 'No user found for that email.';
      } else if (err.code == 'invalid-email') {
        return "The email address is badly formatted.";
      } else {
        return err.message;
      }
    } on SocketException {
      return 'Network error. Please check your connection and try again.';
    } catch (err) {
      return 'An error occurred: ${err.toString()}';
    }
  }

  // signInWithGoogle() async {
  //   GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
  //   GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

  //   // Create a new credential
  //   AuthCredential credential = GoogleAuthProvider.credential(
  //     accessToken: googleAuth?.accessToken,
  //     idToken: googleAuth?.idToken,
  //   );
  //   UserCredential userCredential =
  //       await FirebaseAuth.instance.signInWithCredential(credential);
  //   debugPrint("---${userCredential.user?.displayName}");
  // }

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<User?> signInWithGoogle() async {
    try {
      // Start the Google Sign-In process
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // If the user cancels the sign-in process
        return null;
      }

      // Get the authentication object
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Check if the accessToken or idToken is null
      if (googleAuth.idToken == null && googleAuth.accessToken == null) {
        throw Exception('Access token and ID token are both null');
      }

      // Create a new credential using the tokens
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in with Firebase
      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      return userCredential.user;
    } catch (e) {
      print(e.toString());
      throw e;
    }
  }
}
