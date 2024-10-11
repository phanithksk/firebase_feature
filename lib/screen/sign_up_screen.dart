// ignore_for_file: use_build_context_synchronously

import 'package:firebase_feature/controller/auth_controller.dart';
import 'package:firebase_feature/screen/check_user.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SignUpScreen extends StatefulWidget {
  final BaseAuth auth;
  const SignUpScreen({super.key, required this.auth});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final formKey = GlobalKey<FormState>();
  final scaffoldKey = GlobalKey<ScaffoldState>();
  late String name, email, password;
  late FocusNode f1, f2;

  @override
  void initState() {
    super.initState();
    f1 = FocusNode();
    f2 = FocusNode();
  }

  void submit() async {
    final form = formKey.currentState;
    if (form!.validate()) {
      form.save();
      debugPrint("--Email: $email Password: $password");
      String? signUpResult =
          await AuthService().registration(email: email, password: password);

      if (signUpResult == 'Success') {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (BuildContext context) => CheckUser(auth: widget.auth),
            ),
            (Route<dynamic> route) => false);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(signUpResult!)),
        );
      }
    }
  }

  // void register() async {
  //   try {
  //     String uid = await widget.auth.createUser(_email, _password);
  //     print("uid: $uid");
  //     await widget.auth.sendEmailVerification().then((user) async {
  //       widget.auth.signOut();
  //       Fluttertoast.showToast(
  //           msg: "Verification Email Sent!Verify to Login",
  //           gravity: ToastGravity.BOTTOM,
  //           toastLength: Toast.LENGTH_LONG);
  //       Navigator.of(context).pushAndRemoveUntil(
  //           MaterialPageRoute(
  //               builder: (BuildContext context) => RootPage(auth: widget.auth)),
  //           (Route<dynamic> route) => false);
  //     });
  //   } catch (e) {
  //     print("Error: $e");
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 20.0, right: 20.0),
        child: ListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: <Widget>[
            Container(
              height: 50.0,
            ),
            const FlutterLogo(
              size: 120,
              duration: Duration(seconds: 2),
              curve: Curves.easeIn,
            ),
            const Padding(padding: EdgeInsets.only(top: 80.0)),
            Form(
              key: formKey,
              child: Column(
                children: <Widget>[
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
                          color: Colors.grey,
                          width: 0.5,
                        ),
                      ),
                      hintText: "Enter Your Name",
                      hintStyle: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        fontFamily: "Karla",
                      ),
                      prefixIcon: const Padding(
                        padding: EdgeInsets.only(left: 25, right: 10),
                        child: Icon(
                          Icons.person,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontFamily: "Karla",
                    ),
                    validator: (val) => val!.isEmpty ? "Invalid Name" : null,
                    onSaved: (val) => name = val ?? "",
                    onFieldSubmitted: (val) =>
                        FocusScope.of(context).requestFocus(f1),
                  ),
                  const Padding(padding: EdgeInsets.only(top: 15.0)),
                  TextFormField(
                    cursorColor: Colors.grey,
                    keyboardType: TextInputType.emailAddress,
                    focusNode: f1,
                    decoration: InputDecoration(
                      hintText: "Enter Your Email",
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
                          color: Colors.grey,
                          width: 0.5,
                        ),
                      ),
                      hintStyle: const TextStyle(
                        fontSize: 14,
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
                      fontSize: 14,
                      fontFamily: "Karla",
                    ),
                    validator: AuthService().emailValidator,
                    onSaved: (val) => email = val ?? "",
                    onFieldSubmitted: (val) =>
                        FocusScope.of(context).requestFocus(f2),
                  ),
                  const Padding(padding: EdgeInsets.only(top: 15.0)),
                  TextFormField(
                    cursorColor: Colors.grey,
                    keyboardType: TextInputType.emailAddress,
                    focusNode: f2,
                    decoration: InputDecoration(
                      hintText: "Enter Password",
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
                          color: Colors.grey,
                          width: 0.5,
                        ),
                      ),
                      hintStyle: const TextStyle(
                        fontSize: 14,
                        fontFamily: "Karla",
                        color: Colors.grey,
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
                      fontSize: 14,
                      fontFamily: "Karla",
                    ),
                    validator: (val) => val!.isEmpty
                        ? "Invalid Password"
                        : val.length < 6
                            ? "Pasword too short"
                            : null,
                    onSaved: (val) => password = val ?? "",
                    obscureText: true,
                  ),
                ],
              ),
            ),
            const Padding(padding: EdgeInsets.only(top: 70.0)),
            GestureDetector(
              onTap: () {
                submit();
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.deepPurple[400]!.withOpacity(.6),
                  borderRadius: BorderRadius.circular(30.0),
                ),
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: const Text(
                  "REGISTER",
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
                  "Already Registered.",
                  style: TextStyle(
                    color: Colors.grey,
                    fontFamily: "Karla",
                    fontSize: 14.0,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (BuildContext context) => CheckUser(
                            auth: widget.auth,
                          ),
                        ),
                        (Route<dynamic> route) => false);
                  },
                  child: Text(
                    " Sign In",
                    style: TextStyle(
                      color: Colors.deepPurple[400]!,
                      fontFamily: "Karla",
                      fontSize: 14.0,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
