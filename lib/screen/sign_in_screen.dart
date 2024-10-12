// ignore_for_file: use_build_context_synchronously
import 'package:firebase_feature/controller/auth_controller.dart';
import 'package:firebase_feature/screen/forgot_password.dart';
import 'package:firebase_feature/screen/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'sign_up_screen.dart';

class SigninScreen extends StatefulWidget {
  final BaseAuth auth;
  final VoidCallback onSignedIn;
  const SigninScreen({
    super.key,
    required this.auth,
    required this.onSignedIn,
  });

  @override
  State<SigninScreen> createState() => _SigninScreenState();
}

class _SigninScreenState extends State<SigninScreen>
    with TickerProviderStateMixin {
  late AnimationController animationController;
  late Animation logoanimation;
  late String email, password, emailpassword;
  late FocusNode focusNode;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final formKey = GlobalKey<FormState>();
  final formKey1 = GlobalKey<FormState>();

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

  void submit() async {
    final form = formKey.currentState;
    if (form!.validate()) {
      form.save();
      debugPrint("--Email: $email Password: $password");
      String? loginResult =
          await AuthService().login(email: email, password: password);

      // await FirebaseAuth.instance
      //     .sendSignInLinkToEmail(email: email, actionCodeSettings: acs)
      //     .catchError((onError) =>
      //         debugPrint('Error sending email verification $onError'))
      //     .then((value) => debugPrint('Successfully sent email verification'));

      if (loginResult == 'Success') {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (BuildContext context) => MyHomePage(
              auth: widget.auth,
              title: 'Home Screen',
              onSignedOut: () {},
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loginResult!)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: ListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: <Widget>[
              // Container(
              //   height: 50.0,
              // ),
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
                      onSaved: (val) => email = val ?? "",
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
                        hintText: "Enter Password",
                        hintStyle: const TextStyle(
                          fontSize: 14,
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
                        fontSize: 14,
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
                        builder: (BuildContext context) => ForgotPasswordScreen(
                          auth: widget.auth,
                          onSignedIn: () {},
                        ),
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
                          builder: (BuildContext context) => SignUpScreen(
                            auth: widget.auth,
                          ),
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
                    onTap: () {
                      AuthService().signInWithGoogle();
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
                    onTap: () {},
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Image.asset('assets/facebook.png'),
                    ),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  GestureDetector(
                    onTap: () {},
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
    );
  }
}
