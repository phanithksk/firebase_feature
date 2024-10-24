import 'package:firebase_feature/controller/auth_controller.dart';
import 'package:flutter/material.dart';

class MyHomePage extends StatefulWidget {
  final String title;
  final BaseAuth auth;
  final VoidCallback onSignedOut;
  const MyHomePage({
    super.key,
    required this.title,
    required this.auth,
    required this.onSignedOut,
  });

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String email = "";
  String name = "";
  String firstCharacter = "";
  String profileImage = " ";

  void onSignOut() async {
    try {
      await widget.auth.signOut();
      widget.onSignedOut();
    } catch (e) {
      debugPrint("----Error: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    widget.auth.currentUser().then((user) {
      setState(() {
        if (user != null) {
          email = user.email.toString();
          name = email.split('@')[0];
          firstCharacter = email[0];
          profileImage = user.photoURL ?? "";
        } else {
          email = "Loading...";
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.deepPurple[400]!,
        title: Text(
          widget.title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20.0,
            fontFamily: "Karla",
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () {
              onSignOut();
            },
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                "Sign Out",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.0,
                  fontFamily: "Karla",
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(
              color: Colors.white,
            ),
            accountName: Text(
              name,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 16.0,
                fontFamily: "Karla",
              ),
            ),
            accountEmail: Text(
              email,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 16.0,
                fontFamily: "Karla",
              ),
            ),
            currentAccountPicture: CircleAvatar(
              backgroundImage: NetworkImage(profileImage),
            ),
          )
        ],
      ),
    );
  }
}
