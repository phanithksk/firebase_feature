// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';

void imagePickerModal(BuildContext context,
    {VoidCallback? onCameraTap, VoidCallback? onGalleryTap}) {
  showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          height: 220,
          child: Column(
            children: [
              GestureDetector(
                onTap: onCameraTap,
                child: Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(0),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xff929292).withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      )
                    ],
                  ),
                  child: const Text(
                    "Camera",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.deepPurple,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: onGalleryTap,
                child: Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(0),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xff929292).withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      )
                    ],
                  ),
                  child: const Text(
                    "Gallery",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.deepPurple,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      });
}
