// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_feature/controller/auth_controller.dart';
import 'package:firebase_feature/controller/product_controller.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loader_overlay/loader_overlay.dart';

class ViewProductScreen extends StatefulWidget {
  const ViewProductScreen({
    super.key,
  });

  @override
  State<ViewProductScreen> createState() => _ViewProductScreenState();
}

class _ViewProductScreenState extends State<ViewProductScreen> {
  bool isReadOnly = true;
  bool isAutoFocus = false;
  File? imagePicked;
  // TextEditingControllers for each field
  late TextEditingController categoryController;
  late TextEditingController productNameController;
  late TextEditingController priceController;

  String email = "";
  String name = "";
  String firstCharacter = "";
  String profileImage = "";
  bool isLoading = false;
  bool isEmailLogin = false;
  List<String> docIDs = [];
  bool isDeleted = false;
  String imageUrl = "";
  @override
  void initState() {
    super.initState();
    AuthService().getDocID();
    categoryController = TextEditingController();
    productNameController = TextEditingController();
    priceController = TextEditingController();
  }

  @override
  void dispose() {
    categoryController.dispose();
    productNameController.dispose();
    priceController.dispose();
    super.dispose();
  }

  File? _imageFile;
  final picker = ImagePicker();
  Future<void> pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
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
                  await ProductController().deleteDoc(
                    documentID: documentID,
                    collectionName: 'products',
                  );
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
    CollectionReference user =
        FirebaseFirestore.instance.collection('products');
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.deepPurple[400]!,
        title: const Text(
          'View Product',
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
      ),
      body: LoaderOverlay(
        child: FutureBuilder<QuerySnapshot>(
          future: FirebaseFirestore.instance.collection('products').get(),
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

            final docIDs = snapshot.data!.docs.map((doc) => doc.id).toList();

            return ListView.builder(
              itemCount: docIDs.length,
              itemBuilder: (context, index) {
                var documentId = docIDs[index];
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListTile(
                    title: FutureBuilder<DocumentSnapshot>(
                      future: user.doc(documentId).get(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          if (snapshot.connectionState ==
                              ConnectionState.done) {
                            if (!snapshot.hasData || !snapshot.data!.exists) {
                              return const Center(
                                child: Text("No data available."),
                              );
                            }
                          }

                          Map<String, dynamic> data =
                              snapshot.data!.data() as Map<String, dynamic>;

                          // Set initial values for controllers if they haven't been set
                          categoryController.text = data['category'].toString();
                          productNameController.text = data['name'].toString();
                          priceController.text = data['price'].toString();
                          imageUrl = data['image_url'].toString();

                          return Column(
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
                              const Text(
                                "Category",
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 14.0,
                                  fontFamily: "Karla",
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextField(
                                controller: categoryController,
                                readOnly: isReadOnly,
                                autofocus: isAutoFocus,
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                "Product Name",
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 14.0,
                                  fontFamily: "Karla",
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextFormField(
                                controller: productNameController,
                                readOnly: isReadOnly,
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                "Price",
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 14.0,
                                  fontFamily: "Karla",
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextFormField(
                                controller: priceController,
                                readOnly: isReadOnly,
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                "Image",
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 14.0,
                                  fontFamily: "Karla",
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10),
                              GestureDetector(
                                onTap: isReadOnly == false ? pickImage : null,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    _imageFile != null
                                        ? Image.file(
                                            _imageFile!,
                                            width: 100,
                                            height: 100,
                                            fit: BoxFit.cover,
                                          )
                                        : Image.network(
                                            imageUrl,
                                            width: 100,
                                            height: 100,
                                            fit: BoxFit.cover,
                                          ),
                                    if (!isReadOnly)
                                      Container(
                                        width: 100,
                                        height: 100,
                                        color: Colors.black.withOpacity(0.3),
                                        child: const Icon(
                                          Icons.edit,
                                          color: Colors.white,
                                          size: 24,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  GestureDetector(
                                    onTap: () async {
                                      // Prepare data to be updated
                                      Map<String, dynamic> updatedData = {
                                        'category': categoryController.text,
                                        'name': productNameController.text,
                                        'price': priceController.text,
                                        'image_url': imageUrl,
                                      };

                                      // Fetch current data from Firestore to compare
                                      DocumentSnapshot currentDoc =
                                          await FirebaseFirestore.instance
                                              .collection('products')
                                              .doc(documentId)
                                              .get();
                                      Map<String, dynamic> currentData =
                                          currentDoc.data()
                                              as Map<String, dynamic>;

                                      // Check if the data has changed
                                      bool hasDataChanged =
                                          updatedData['category'] !=
                                                  currentData['category'] ||
                                              updatedData['name'] !=
                                                  currentData['name'] ||
                                              updatedData['price'] !=
                                                  currentData['price'];
                                      updatedData['image_url'] !=
                                          currentData['image_url'];

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
                                        await ProductController().updateDoc(
                                          documentID: documentId,
                                          newData: updatedData,
                                          context: context,
                                          collectionName: 'products',
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
                                        color: Colors.deepPurple[100]!
                                            .withOpacity(0.4),
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
                                          color: Colors.deepPurple[400]!
                                              .withOpacity(0.8),
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
                                      confirmDelete(documentId);
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color:
                                            Colors.red[100]!.withOpacity(0.4),
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
                                          color:
                                              Colors.red[400]!.withOpacity(0.8),
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
                          );
                        }
                        return const Center(
                          child: Text("Loading..."),
                        );
                      },
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
