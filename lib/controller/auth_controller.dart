import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

abstract class BaseAuth {
  Future<User?> currentUser();
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

  bool isLoading = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        debugPrint('-----Google Sign-In was aborted');
        return null;
      }
      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await _auth.signInWithCredential(credential);
    } catch (e) {
      debugPrint('----Sign-in failed: ${e.toString()}');
    }
    return null;
  }

  Future<User?> signInWithFacebook() async {
    try {
      final LoginResult loginResult = await FacebookAuth.instance.login();

      if (loginResult.status == LoginStatus.success) {
        debugPrint('-----Facebook Sign-In success');
        final OAuthCredential facebookAuthCredential =
            FacebookAuthProvider.credential(
                loginResult.accessToken!.tokenString);

        return (await FirebaseAuth.instance
                .signInWithCredential(facebookAuthCredential))
            .user;
      } else if (loginResult.status == LoginStatus.cancelled) {
        debugPrint('-----Facebook Sign-In was cancelled by the user');
      } else {
        debugPrint('-----Facebook Sign-In failed: ${loginResult.message}');
      }
    } catch (e) {
      debugPrint('----Sign-in failed: ${e.toString()}');
    }

    return null;
  }
}
