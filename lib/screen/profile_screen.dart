import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_feature/controller/auth_controller.dart';
import 'package:firebase_feature/screen/auth/sign_in_screen.dart';
import 'package:firebase_feature/screen/get_user.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String email = "";
  String name = "";
  String firstCharacter = "";
  String profileImage = "";
  bool isEmailLogin = false;

  @override
  void initState() {
    super.initState();
    AuthService().getDocID();
    checkLoginMethod();
  }

  Future<void> checkLoginMethod() async {
    AuthService().currentUser().then((user) {
      if (user != null) {
        setState(() {
          isEmailLogin = user.providerData
              .any((provider) => provider.providerId == 'password');
          email = user.email ?? user.phoneNumber ?? "";
          name = isEmailLogin ? email.split('@')[0] : "Phone User";
          firstCharacter = email.isNotEmpty ? name[0] : '';
          profileImage = user.photoURL ?? "";
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.deepPurple[400]!,
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.0,
            fontFamily: "Karla",
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () {
              AuthService().signOut();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const SigninScreen()),
                (route) => false,
              );
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
        children: [
          Expanded(
            child: FutureBuilder<QuerySnapshot>(
              future: FirebaseFirestore.instance.collection('users').get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text("No data available."),
                  );
                }

                final docIDs =
                    snapshot.data!.docs.map((doc) => doc.id).toList();

                return ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: docIDs.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListTile(
                        title: GetUserScreen(
                          documentId: docIDs[index],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
