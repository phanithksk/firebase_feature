import 'package:firebase_feature/screen/check_user.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import '../controller/auth_controller.dart';

class SplashScreen extends StatefulWidget {
  final BaseAuth auth;
  const SplashScreen({super.key, required this.auth});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late Animation logoanimation, textanimation;
  late AnimationController animationController;

  @override
  void initState() {
    super.initState();

    animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 2));
    logoanimation = Tween(begin: 25.0, end: 100.0).animate(
        CurvedAnimation(parent: animationController, curve: Curves.bounceOut));
    textanimation = Tween(begin: 0.0, end: 27.0).animate(CurvedAnimation(
        parent: animationController, curve: Curves.bounceInOut));
    logoanimation.addListener(() => setState(() {}));
    textanimation.addListener(() => setState(() {}));
    animationController.forward();
    Timer(
      const Duration(seconds: 4),
      () => Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (BuildContext context) => CheckUser(
            auth: widget.auth,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Container(
            decoration: const BoxDecoration(color: Colors.white),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    FlutterLogo(
                      size: logoanimation.value,
                      curve: Curves.bounceOut,
                    ),
                    const Padding(
                      padding: EdgeInsets.only(top: 20.0),
                    ),
                    Text(
                      "Firebase Feature",
                      style: TextStyle(
                        color: Colors.deepPurple,
                        fontFamily: "Pacifico",
                        fontSize: textanimation.value,
                      ),
                    )
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(bottom: 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Colors.deepPurple),
                    ),
                  ],
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
