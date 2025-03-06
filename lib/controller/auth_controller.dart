// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_feature/screen/auth/otp_screen.dart';
import 'package:firebase_feature/screen/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AuthService {
  bool isLoading = false;
  static final _auth = FirebaseAuth.instance;

  Future<User?> currentUser() async {
    User? user = _auth.currentUser;
    if (user != null) {
      debugPrint("---uid: ${user.uid}");
    }
    return user;
  }

  Future<void> signOut() async {
    return _auth.signOut();
  }

  String? emailOrPhoneValidator(String? val) {
    String emailPattern = r"^[a-zA-Z0-9._%+-]+@gmail\.com$";
    String phonePattern = r"^\d{9,10}$";
    RegExp emailRegex = RegExp(emailPattern);
    RegExp phoneRegex = RegExp(phonePattern);

    if (val == null || val.isEmpty) {
      return "Input is required";
    } else if (!(emailRegex.hasMatch(val) || phoneRegex.hasMatch(val))) {
      return "Gmail(name@gmail.com) or Phone(9 to 10 digits)";
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

  Future<UserCredential?> signInWithApple() async {
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );
      final outhCredential = OAuthProvider("apple.com").credential(
        idToken: credential.identityToken,
        accessToken: credential.authorizationCode,
      );

      return await _auth.signInWithCredential(outhCredential);
    } catch (e) {
      debugPrint('----Sign-in failed: ${e.toString()}');
    }
    return null;
  }

  Future<void> sendOtp({
    required BuildContext context,
    required String phoneNumber,
    int? forceResendingToken,
  }) async {
    final getPhoneNumber =
        '+855 ${phoneNumber.substring(0, 4)} ${phoneNumber.substring(4, 7)} ${phoneNumber.substring(7)}';
    try {
      context.loaderOverlay.show();
      await _auth.verifyPhoneNumber(
        phoneNumber: getPhoneNumber,
        forceResendingToken: forceResendingToken,
        codeSent: (verificationId, x) {
          context.loaderOverlay.hide();

          if (forceResendingToken == null) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => VerifyOtpPage(
                  forceResendingToken: forceResendingToken,
                  verificationId: verificationId,
                  // auth: widget.auth,
                  phone: phoneNumber,
                ),
              ),
            );
          }
        },
        verificationCompleted: (phoneAuthCredential) async {
          final smsCode = phoneAuthCredential.smsCode;
          debugPrint("Verification completed $smsCode");
        },
        verificationFailed: (error) {
          ScaffoldMessenger.of(context)
            ..hideCurrentMaterialBanner()
            ..showSnackBar(SnackBar(content: Text("${error.message}")));
        },
        codeAutoRetrievalTimeout: (verificationId) {},
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context)
        ..hideCurrentMaterialBanner()
        ..showSnackBar(SnackBar(content: Text("${e.message}")));
    } catch (e) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      context.loaderOverlay.hide();
    }
  }

  Future<void> verifyOtp({
    required BuildContext context,
    required String otp,
    required String verificationId,
  }) async {
    try {
      context.loaderOverlay.show();
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otp,
      );
      await _auth.signInWithCredential(credential);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const MyHomePage(),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              e.toString(),
            ),
          ),
        );
    } finally {
      context.loaderOverlay.hide();
    }
  }

  Future addUserDetail({
    required String name,
    required String email,
    required int password,
  }) async {
    await FirebaseFirestore.instance.collection('users').add({
      "username": name,
      "email": email,
      "password": password,
    });
  }

  List<String> docIDs = [];
  Future<void> getDocID() async {
    try {
      docIDs.clear();
      String collection = 'users';
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection(collection).get();
      for (var document in snapshot.docs) {
        docIDs.add(document.id);
      }
    } catch (e) {
      debugPrint("-----Error fetching document IDs: $e");
    }
  }

  Future<void> addProducts({
    required String category,
    required String name,
    required int price,
    String? imageUrl,
  }) async {
    await FirebaseFirestore.instance.collection('products').add({
      "category": category,
      "name": name,
      "price": price,
      "image_url": imageUrl,
    });
  }
}
