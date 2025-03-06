// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_feature/controller/auth_controller.dart';
import 'package:firebase_feature/screen/products/create_product.dart';
import 'package:firebase_feature/screen/products/realtime_database/product_screen.dart';
import 'package:firebase_feature/screen/products/view_product.dart';
import 'package:firebase_feature/screen/profile_screen.dart';
import 'package:firebase_feature/screen/text_recognition/image_cropper_page.dart';
import 'package:firebase_feature/screen/text_recognition/image_picker_class.dart';
import 'package:firebase_feature/screen/text_recognition/modal_dialog.dart';
import 'package:firebase_feature/screen/text_recognition/recognization_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class MyHomePage extends StatefulWidget {
  final String? phoneNumber;
  const MyHomePage({super.key, this.phoneNumber});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String email = "";
  String name = "";
  String firstCharacter = "";
  String profileImage = "";

  bool isEmailLogin = false;
  List<String> docIDs = [];

  @override
  void initState() {
    super.initState();
    getDocID();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.deepPurple[400]!,
        title: const Text(
          'HomeScreen',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.0,
            fontFamily: "Karla",
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (BuildContext context) => const ProfileScreen(),
              ));
            },
            child: Padding(
              padding: const EdgeInsets.only(right: 10),
              child: CircleAvatar(
                radius: 18,
                backgroundImage:
                    profileImage.isNotEmpty ? NetworkImage(profileImage) : null,
                child: profileImage.isEmpty ? Text(firstCharacter) : null,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Product with Firestore Database",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.deepPurple,
                fontSize: 18.0,
                fontFamily: "Karla",
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (BuildContext context) =>
                        const CreateProductScreen(),
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(20),
                ),
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                child: const Text(
                  "Create Product",
                  style: TextStyle(
                    color: Colors.deepPurple,
                    fontSize: 14.0,
                    fontFamily: "Karla",
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (BuildContext context) =>
                        const ViewProductScreen(),
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(20),
                ),
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                child: const Text(
                  "View Product",
                  style: TextStyle(
                    color: Colors.deepPurple,
                    fontSize: 14.0,
                    fontFamily: "Karla",
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            const Text(
              "Product with Realtim Database",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.deepPurple,
                fontSize: 18.0,
                fontFamily: "Karla",
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (BuildContext context) =>
                        const ProductWithRealtimeDatatbaseScreen(),
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(20),
                ),
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                child: const Text(
                  "Products Screen",
                  style: TextStyle(
                    color: Colors.deepPurple,
                    fontSize: 14.0,
                    fontFamily: "Karla",
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            // GestureDetector(
            //   onTap: () {
            //     Navigator.of(context).push(
            //       MaterialPageRoute(
            //         builder: (BuildContext context) =>
            //             const ProductWithRealtimeDatatbaseScreen(),
            //       ),
            //     );
            //   },
            //   child: Container(
            //     decoration: BoxDecoration(
            //       color: Colors.grey[100],
            //       borderRadius: BorderRadius.circular(20),
            //     ),
            //     padding:
            //         const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
            //     child: const Text(
            //       "Text Recognition",
            //       style: TextStyle(
            //         color: Colors.deepPurple,
            //         fontSize: 14.0,
            //         fontFamily: "Karla",
            //         fontWeight: FontWeight.w500,
            //       ),
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          imagePickerModal(context, onCameraTap: () {
            pickImage(source: ImageSource.camera).then((value) {
              if (value != '') {
                imageCropperView(value, context).then((value) {
                  if (value != '') {
                    Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (_) => RecognizePage(
                          path: value,
                        ),
                      ),
                    );
                  }
                });
              }
            });
          }, onGalleryTap: () {
            pickImage(source: ImageSource.gallery).then((value) {
              if (value != '') {
                imageCropperView(value, context).then((value) {
                  if (value != '') {
                    Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (_) => RecognizePage(
                          path: value,
                        ),
                      ),
                    );
                  }
                });
              }
            });
          });
        },
        label: const Text("Scan photo"),
      ),
    );
  }
}
