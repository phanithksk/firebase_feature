// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:firebase_feature/controller/auth_controller.dart';
import 'package:firebase_feature/screen/check_user.dart';
import 'package:firebase_feature/screen/auth/forgot_password.dart';
import 'package:firebase_feature/screen/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'sign_up_screen.dart';

class SigninScreen extends StatefulWidget {
  const SigninScreen({
    super.key,
  });

  @override
  State<SigninScreen> createState() => _SigninScreenState();
}

class _SigninScreenState extends State<SigninScreen>
    with TickerProviderStateMixin {
  late AnimationController animationController;
  late Animation logoanimation;
  late String emailAndphone, password, emailpassword;
  late FocusNode focusNode;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final formKey = GlobalKey<FormState>();
  final formKey1 = GlobalKey<FormState>();
  final phoneController = TextEditingController();

  bool isLoading = false;
  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    logoanimation =
        CurvedAnimation(parent: animationController, curve: Curves.easeOut);
    logoanimation.addListener(() => setState(() {}));
    animationController.forward();
    focusNode = FocusNode();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  void signinEmailAndPhone() async {
    final form = formKey.currentState;
    if (form!.validate()) {
      form.save();

      if (isValidEmail(emailAndphone)) {
        // Email Login
        String? loginResult = await AuthService().login(
          email: emailAndphone,
          password: password,
        );
        if (loginResult == 'Success') {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (BuildContext context) => const MyHomePage(),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(loginResult!)),
          );
        }
      } else if (isValidPhoneNumber(emailAndphone)) {
        AuthService().sendOtp(
          context: context,
          phoneNumber: emailAndphone,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid email or phone number format.'),
          ),
        );
      }
    }
  }

  bool isValidEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);
  }

  bool isValidPhoneNumber(String phone) {
    return phone.length >= 9 && phone.length <= 10;
  }

  @override
  Widget build(BuildContext context) {
    return LoaderOverlay(
      child: Scaffold(
        backgroundColor: Colors.white,
        key: scaffoldKey,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: ListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: <Widget>[
                const FlutterLogo(
                  size: 120,
                  duration: Duration(seconds: 2),
                  curve: Curves.easeIn,
                ),
                Container(
                  height: 80.0,
                ),
                Form(
                  key: formKey,
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                        keyboardType: TextInputType.emailAddress,
                        cursorColor: Colors.grey,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: const BorderSide(
                              color: Colors.grey,
                              width: 0.5,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: const BorderSide(
                              color: Colors.black,
                              width: 0.5,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: const BorderSide(
                              color: Colors.grey,
                              width: 0.5,
                            ),
                          ),
                          hintText: "Email or Phone",
                          hintStyle: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            fontFamily: "Karla",
                          ),
                          prefixIcon: const Padding(
                            padding: EdgeInsets.only(left: 25, right: 10),
                            child: Icon(
                              Icons.mail,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                          fontFamily: "Karla",
                        ),
                        validator: (value) =>
                            AuthService().emailOrPhoneValidator(value),
                        onSaved: (val) => emailAndphone = val ?? "",
                        onFieldSubmitted: (val) =>
                            FocusScope.of(context).requestFocus(focusNode),
                      ),
                      const Padding(padding: EdgeInsets.only(top: 15.0)),
                      TextFormField(
                        cursorColor: Colors.grey,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: const BorderSide(
                              color: Colors.grey,
                              width: 0.5,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: const BorderSide(
                              color: Colors.black,
                              width: 0.5,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: const BorderSide(
                              color: Colors.grey,
                              width: 0.5,
                            ),
                          ),
                          hintText: "Password",
                          hintStyle: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            fontFamily: "Karla",
                          ),
                          prefixIcon: const Padding(
                            padding: EdgeInsets.only(left: 25, right: 10),
                            child: Icon(
                              Icons.lock,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                          fontFamily: "Karla",
                        ),
                        obscureText: true,
                        validator: (val) => val!.isEmpty
                            ? 'Invalid Password'
                            : val.length < 6
                                ? "Password too short"
                                : null,
                        onSaved: (val) => password = val ?? "",
                        focusNode: focusNode,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (BuildContext context) =>
                              const ForgotPasswordScreen(),
                        ),
                      );
                    },
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          "Forgot Password?",
                          style: TextStyle(
                            color: Colors.grey,
                            fontFamily: "Karla",
                            fontSize: 14.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Padding(padding: EdgeInsets.only(top: 80.0)),
                GestureDetector(
                  onTap: () async {
                    signinEmailAndPhone();
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.deepPurple[400]!.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: const Text(
                      "Sign In",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                        fontFamily: "Karla",
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const Padding(padding: EdgeInsets.only(top: 20.0)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Don't have account?",
                      style: TextStyle(
                        color: Colors.grey,
                        fontFamily: "Karla",
                        fontSize: 14.0,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (BuildContext context) =>
                                const SignUpScreen(),
                          ),
                        );
                      },
                      child: Text(
                        " Sign Up",
                        style: TextStyle(
                          color: Colors.deepPurple[400]!,
                          fontFamily: "Karla",
                          fontSize: 14.0,
                        ),
                      ),
                    ),
                  ],
                ),
                const Padding(padding: EdgeInsets.only(top: 30.0)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        setState(() {
                          AuthService().isLoading = true;
                        });

                        final userCredential =
                            await AuthService().signInWithGoogle();

                        setState(() {
                          AuthService().isLoading = false;
                        });

                        if (userCredential != null) {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  const CheckUser(),
                            ),
                          );
                        } else {
                          debugPrint(
                              '-----Sign-in failed. Unable to navigate.');
                        }
                      },
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        child: Image.asset('assets/logo-google.png'),
                      ),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    GestureDetector(
                      onTap: () async {
                        // Show a loading indicator while waiting for the sign-in to complete
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (BuildContext context) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          },
                        );

                        try {
                          final userCredential =
                              await AuthService().signInWithFacebook();

                          Navigator.of(context).pop();

                          if (userCredential != null) {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    const CheckUser(),
                              ),
                            );
                          } else {
                            debugPrint(
                                '-----Sign-in failed. Unable to navigate.');
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content:
                                    Text('Sign-in failed. Please try again.'),
                              ),
                            );
                          }
                        } catch (e) {
                          Navigator.of(context).pop();
                          debugPrint('-----Sign-in error: ${e.toString()}');
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content:
                                  Text('----An error occurred during sign-in.'),
                            ),
                          );
                        }
                      },
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        child: Image.asset('assets/facebook.png'),
                      ),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    GestureDetector(
                      onTap: () async {
                        await AuthService().signInWithApple();
                      },
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        child: Image.asset('assets/apple.png'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
