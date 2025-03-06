// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CreateFormScreen extends StatefulWidget {
  final String? productId;
  final String? existingProductName;
  final String? existingQuality;
  final String? existingPrice;
  final String? existingImage;

  const CreateFormScreen({
    super.key,
    this.productId,
    this.existingProductName,
    this.existingQuality,
    this.existingPrice,
    this.existingImage,
  });

  @override
  State<CreateFormScreen> createState() => _CreateFormScreenState();
}

class _CreateFormScreenState extends State<CreateFormScreen> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController qualityController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final databaseReference = FirebaseDatabase.instance.ref("StoreData");
  bool isLoading = false;
  File? _image;
  final ImagePicker _picker = ImagePicker();
  @override
  void initState() {
    super.initState();
    // If editing, populate fields with existing data
    if (widget.productId != null) {
      nameController.text = widget.existingProductName ?? '';
      qualityController.text = widget.existingQuality ?? '';
      priceController.text = widget.existingPrice ?? '';
    }
  }

  Future<void> pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<String?> uploadImageToFirebase() async {
    if (_image == null) return null;

    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference ref =
          FirebaseStorage.instance.ref().child('product_images/$fileName');
      UploadTask uploadTask = ref.putFile(_image!);
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

  Future<void> submitForm() async {
    final form = formKey.currentState;
    if (form!.validate()) {
      form.save();
      setState(() {
        isLoading = true;
      });

      try {
        String? imageUrl;

        if (_image == null) {
          await pickImage();
        }

        if (_image != null) {
          imageUrl = await uploadImageToFirebase();
        }
        if (widget.productId == null) {
          final id = DateTime.now().microsecondsSinceEpoch.toString();
          await databaseReference.child(id).set({
            'productName': nameController.text,
            'quality': qualityController.text,
            'price': priceController.text,
            'id': id,
            'image': imageUrl
          });
        } else {
          await databaseReference.child(widget.productId!).update({
            'productName': nameController.text,
            'quality': qualityController.text,
            'price': priceController.text,
            'image': imageUrl
          });
        }
        Navigator.pop(context);
      } catch (e) {
        debugPrint('Error: $e');
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
      appBar: AppBar(
        backgroundColor: Colors.deepPurple[400]!,
        centerTitle: true,
        title: Text(
          widget.productId == null ? 'Create Screen' : 'Update Screen',
          style: const TextStyle(
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
      body: ListView(
        children: [
          Padding(
            padding: EdgeInsets.only(
              top: 20,
              right: 20,
              left: 20,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Text(
                      widget.productId == null
                          ? "Create your items"
                          : "Update your items",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: "Karla",
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  TextFormField(
                    controller: nameController,
                    validator: (val) =>
                        val!.isEmpty ? "Invalid Product Name" : null,
                    onSaved: (val) => nameController.text = val ?? "",
                    cursorColor: Colors.grey,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontFamily: "Karla",
                    ),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.only(left: 20),
                      hintText: "eg.Coca",
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
                      labelText: "Product Name",
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  TextFormField(
                    controller: qualityController,
                    validator: (val) => val!.isEmpty ? "Invalid Quality" : null,
                    onSaved: (val) => qualityController.text = val ?? "",
                    keyboardType: TextInputType.number,
                    cursorColor: Colors.grey,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontFamily: "Karla",
                    ),
                    decoration: InputDecoration(
                      labelText: "Quality",
                      hintText: "eg.10",
                      contentPadding: const EdgeInsets.only(left: 20),
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
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  TextFormField(
                    controller: priceController,
                    validator: (val) {
                      if (val!.isEmpty) {
                        return "Invalid Price";
                      } else if (!RegExp(r'^[0-9]+$').hasMatch(val)) {
                        return "Only numbers are allowed";
                      }
                      return null;
                    },
                    onSaved: (val) => priceController.text = val ?? "",
                    cursorColor: Colors.grey,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontFamily: "Karla",
                    ),
                    decoration: InputDecoration(
                      labelText: "Price",
                      hintText: "eg.10",
                      contentPadding: const EdgeInsets.only(left: 20),
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
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  // Image Picker Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: pickImage,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.deepPurple[400]!.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.all(15),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: SizedBox(
                              width: 120,
                              height: 120,
                              child: widget.existingImage != null
                                  ? Image.network(widget.existingImage ?? "")
                                  : _image == null
                                      ? Icon(
                                          Icons.add_a_photo,
                                          color: Theme.of(context).primaryColor,
                                          size: 30,
                                        )
                                      : Image.file(
                                          _image!,
                                          fit: BoxFit.cover,
                                        ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.resolveWith<Color>(
                        (Set<WidgetState> states) {
                          if (states.contains(WidgetState.pressed)) {
                            return Colors.deepPurple[400]!.withOpacity(0.6);
                          }
                          return Colors.deepPurple[400]!;
                        },
                      ),
                    ),
                    onPressed: submitForm,
                    child: isLoading
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          )
                        : Text(
                            widget.productId == null
                                ? "Add Item"
                                : "Update Item",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontFamily: "Karla",
                            ),
                          ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
