// ignore_for_file: use_build_context_synchronously
import 'package:firebase_feature/controller/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ForgotPasswordScreen extends StatefulWidget {
  final BaseAuth auth;
  final VoidCallback onSignedIn;
  const ForgotPasswordScreen({
    super.key,
    required this.auth,
    required this.onSignedIn,
  });

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with TickerProviderStateMixin {
  late String emailpassword;
  late FocusNode focusNode;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final formKey1 = GlobalKey<FormState>();

  void passwordReset() async {
    final form = formKey1.currentState;
    if (form!.validate()) {
      form.save();
      try {
        String? result =
            await AuthService().forgotPassword(email: emailpassword);
        if (result == null) {
          const snackBar = SnackBar(
            content: Text(
                "If an account exists with this email, a password reset email has been sent."),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
          Navigator.of(context).pop();
        } else {
          Fluttertoast.showToast(
            msg: result,
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
          );
          Navigator.of(context).pop();
        }
      } catch (e) {
        Fluttertoast.showToast(
          msg: 'An error occurred: ${e.toString()}',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      key: scaffoldKey,
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: <Widget>[
            const Text(
              "Reset Password",
              style: TextStyle(
                fontSize: 20,
                color: Colors.black,
                fontFamily: "Karla",
                fontWeight: FontWeight.bold,
              ),
            ),
            Container(
              height: 8.0,
            ),
            const Text(
              "Don't worry sometimes people forget too.Please enter your email and we will send you a password reset link. ",
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontFamily: "Karla",
              ),
            ),
            Container(
              height: 50.0,
            ),
            Form(
              key: formKey1,
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
                      hintText: "Enter Email",
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
                    onSaved: (val) => emailpassword = val ?? "",
                  ),
                ],
              ),
            ),
            const Padding(padding: EdgeInsets.only(top: 20.0)),
            GestureDetector(
              onTap: () {
                passwordReset();
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.deepPurple[400]!.withOpacity(.6),
                  borderRadius: BorderRadius.circular(30.0),
                ),
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: const Text(
                  "Submit",
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
          ],
        ),
      ),
    );
  }
}
