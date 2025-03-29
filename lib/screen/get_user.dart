// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_feature/controller/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:loader_overlay/loader_overlay.dart';

class GetUserScreen extends StatefulWidget {
  final String documentId;
  const GetUserScreen({super.key, required this.documentId});

  @override
  State<GetUserScreen> createState() => _GetUserScreenState();
}

class _GetUserScreenState extends State<GetUserScreen> {
  bool isReadOnly = true;
  bool isAutoFocus = false;

  // TextEditingControllers for each field
  late TextEditingController usernameController;
  late TextEditingController emailController;
  late TextEditingController passwordController;

  String email = "";
  String name = "";
  String firstCharacter = "";
  String profileImage = "";
  bool isLoading = false;
  bool isEmailLogin = false;
  List<String> docIDs = [];
  bool isDeleted = false;

  @override
  void initState() {
    super.initState();
    AuthService().getDocID();
    checkLoginMethod();
    usernameController = TextEditingController();
    emailController = TextEditingController();
    passwordController = TextEditingController();
  }

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
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

  // Function to update the document
  Future<void> updateDoc({
    required String documentID,
    required Map<String, dynamic> newData,
  }) async {
    try {
      context.loaderOverlay.show();
      String collection = 'users';
      await FirebaseFirestore.instance
          .collection(collection)
          .doc(documentID)
          .update(newData);
      debugPrint("--Document with ID $documentID updated successfully.");
    } catch (e) {
      debugPrint("-----Error updating document: $e");
    } finally {
      Future.delayed(const Duration(seconds: 2));
      context.loaderOverlay.hide();
    }
  }

  // Function to delete the document
  Future<void> deleteDoc(String documentID) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(documentID)
          .delete();
      debugPrint("Document with ID $documentID deleted successfully.");
    } catch (e) {
      debugPrint("-----Error deleting document: $e");
    }
  }

  void confirmDelete(String documentID) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Delete"),
          content: const Text(
              "Are you sure you want to delete this record? This action cannot be undone."),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("Delete"),
              onPressed: () async {
                Navigator.of(context).pop();

                if (!mounted) return;
                context.loaderOverlay.show();

                try {
                  await deleteDoc(documentID);
                  if (mounted) {
                    setState(() {
                      isDeleted = true;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Document deleted successfully"),
                      ),
                    );
                  }
                } catch (e) {
                  debugPrint("Error during deletion: $e");
                } finally {
                  if (mounted) {
                    context.loaderOverlay.hide();
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    CollectionReference user = FirebaseFirestore.instance.collection('users');

    return FutureBuilder<DocumentSnapshot>(
      future: user.doc(widget.documentId).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Center(
                child: Text("No data available."),
              );
            }
          }
          Map<String, dynamic> data =
              snapshot.data!.data() as Map<String, dynamic>;

          // Set initial values for controllers if they haven't been set
          usernameController.text = data['username'].toString();
          emailController.text = data['email'].toString();
          passwordController.text = data['password'].toString();

          return LoaderOverlay(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          isReadOnly = false;
                          isAutoFocus = true;
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 5),
                        child: const Icon(
                          Icons.edit,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
                TextFormField(
                  controller: usernameController,
                  readOnly: isReadOnly,
                  autofocus: isAutoFocus,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: emailController,
                  readOnly: isReadOnly,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: passwordController,
                  readOnly: isReadOnly,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        // Prepare data to be updated
                        Map<String, dynamic> updatedData = {
                          'username': usernameController.text,
                          'email': emailController.text,
                          'password': passwordController.text,
                        };

                        // Fetch current data from Firestore to compare
                        DocumentSnapshot currentDoc = await FirebaseFirestore
                            .instance
                            .collection('users')
                            .doc(widget.documentId)
                            .get();
                        Map<String, dynamic> currentData =
                            currentDoc.data() as Map<String, dynamic>;

                        // Check if the data has changed
                        bool hasDataChanged = updatedData['username'] !=
                                currentData['username'] ||
                            updatedData['email'] != currentData['email'] ||
                            updatedData['password'] != currentData['password'];

                        if (!hasDataChanged) {
                          ScaffoldMessenger.of(context)
                            ..hideCurrentSnackBar()
                            ..showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "No changes detected. Please modify the data before updating.",
                                ),
                              ),
                            );
                        } else {
                          await updateDoc(
                            documentID: widget.documentId,
                            newData: updatedData,
                          );
                          ScaffoldMessenger.of(context)
                            ..hideCurrentSnackBar()
                            ..showSnackBar(
                              const SnackBar(
                                content: Text(
                                  " Your changes have been saved.",
                                ),
                              ),
                            );

                          setState(() {
                            isReadOnly = true;
                            isAutoFocus = false;
                          });
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.deepPurple[100]!.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        margin: const EdgeInsets.only(top: 20),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 6,
                        ),
                        child: Text(
                          "Update",
                          style: TextStyle(
                            color: Colors.deepPurple[400]!.withOpacity(0.8),
                            fontSize: 12.0,
                            fontFamily: "Karla",
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    GestureDetector(
                      onTap: () {
                        confirmDelete(widget.documentId);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.red[100]!.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        margin: const EdgeInsets.only(top: 20),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 6,
                        ),
                        child: Text(
                          "Delete",
                          style: TextStyle(
                            color: Colors.red[400]!.withOpacity(0.8),
                            fontSize: 12.0,
                            fontFamily: "Karla",
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }
        return const Center(
          child: Text("Loading..."),
        );
      },
    );
  }
}
