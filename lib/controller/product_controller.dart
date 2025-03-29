import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ProductController {
  // Function to update the document
  Future<void> updateDoc({
    required String documentID,
    required Map<String, dynamic> newData,
    required dynamic context,
    required String collectionName,
  }) async {
    try {
      // context.loaderOverlay.show();
      await FirebaseFirestore.instance
          .collection(collectionName)
          .doc(documentID)
          .update(newData);
      debugPrint("--Document with ID $documentID updated successfully.");
    } catch (e) {
      debugPrint("-----Error updating document: $e");
    } finally {
      Future.delayed(const Duration(seconds: 2));
      // context.loaderOverlay.hide();
    }
  }

  // Function to delete the document
  Future<void> deleteDoc({
    required String documentID,
    required String collectionName,
  }) async {
    try {
      await FirebaseFirestore.instance
          .collection('collectionName')
          .doc(documentID)
          .delete();
      debugPrint("Document with ID $documentID deleted successfully.");
    } catch (e) {
      debugPrint("-----Error deleting document: $e");
    }
  }
}
