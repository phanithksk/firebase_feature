// ignore_for_file: use_build_context_synchronously, deprecated_member_use
import 'dart:io';

import 'package:firebase_feature/controller/auth_controller.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CreateProductScreen extends StatefulWidget {
  const CreateProductScreen({
    super.key,
  });

  @override
  State<CreateProductScreen> createState() => _CreateProductScreenState();
}

class _CreateProductScreenState extends State<CreateProductScreen> {
  final formKey = GlobalKey<FormState>();
  final scaffoldKey = GlobalKey<ScaffoldState>();
  late String name, category, price;
  late FocusNode f1, f2;

  @override
  void initState() {
    super.initState();
    f1 = FocusNode();
    f2 = FocusNode();
  }

  bool isLoading = false;
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

  Future<String?> uploadImage() async {
    if (_imageFile == null) return null;

    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference ref = FirebaseStorage.instance.ref().child('images/$fileName');
      UploadTask uploadTask = ref.putFile(_imageFile!);
      await uploadTask;

      String downloadURL = await ref.getDownloadURL();
      return downloadURL;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("--Failed to upload image: $e")),
      );
      return null;
    }
  }

  void createProduct() async {
    final form = formKey.currentState;
    if (form!.validate()) {
      form.save();
      setState(() {
        isLoading = true;
      });

      String? imageUrl;

      if (_imageFile == null) {
        await pickImage();
      }

      if (_imageFile != null) {
        imageUrl = await uploadImage();
      }

      try {
        await AuthService().addProducts(
          category: category,
          name: name,
          price: int.parse(price),
          imageUrl: imageUrl,
        );
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Product created successfully!"),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to upload image: $e")),
        );
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      key: scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.deepPurple[400]!,
        title: const Text(
          'Create Product',
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
      body: Padding(
        padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 20),
        child: ListView(
          physics: const NeverScrollableScrollPhysics(),
          children: <Widget>[
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
                      hintText: "Category",
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
                    validator: (val) =>
                        val!.isEmpty ? "Invalid Category" : null,
                    onSaved: (val) => category = val ?? "",
                    onFieldSubmitted: (val) =>
                        FocusScope.of(context).requestFocus(f1),
                  ),
                  const Padding(padding: EdgeInsets.only(top: 15.0)),
                  TextFormField(
                    cursorColor: Colors.grey,
                    keyboardType: TextInputType.emailAddress,
                    focusNode: f1,
                    decoration: InputDecoration(
                      hintText: "Product Name",
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
                    validator: (val) =>
                        val!.isEmpty ? "Invalid ProducName" : null,
                    onSaved: (val) => name = val ?? "",
                    onFieldSubmitted: (val) =>
                        FocusScope.of(context).requestFocus(f2),
                  ),
                  const Padding(padding: EdgeInsets.only(top: 15.0)),
                  TextFormField(
                    cursorColor: Colors.grey,
                    keyboardType: TextInputType.emailAddress,
                    focusNode: f2,
                    decoration: InputDecoration(
                      hintText: "Price",
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
                    validator: (val) {
                      if (val!.isEmpty) {
                        return "Invalid Price";
                      } else if (!RegExp(r'^[0-9]+$').hasMatch(val)) {
                        return "Only numbers are allowed";
                      }
                      return null;
                    },
                    onSaved: (val) => price = val ?? "",
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          ElevatedButton(
                            onPressed: pickImage,
                            child: const Text("Pick Image"),
                          ),
                          const SizedBox(height: 10),
                          if (_imageFile != null)
                            Image.file(
                              _imageFile!,
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Padding(padding: EdgeInsets.only(top: 30.0)),
            GestureDetector(
              onTap: () {
                createProduct();
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.deepPurple[400]!.withOpacity(.6),
                  borderRadius: BorderRadius.circular(30.0),
                ),
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        "Create",
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
      ),
    );
  }
}
