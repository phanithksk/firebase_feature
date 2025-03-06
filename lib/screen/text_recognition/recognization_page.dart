import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:flutter/services.dart';

class RecognizePage extends StatefulWidget {
  final String? path;
  const RecognizePage({super.key, this.path});

  @override
  State<RecognizePage> createState() => _RecognizePageState();
}

class _RecognizePageState extends State<RecognizePage> {
  bool _isBusy = false;
  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    final InputImage inputImage = InputImage.fromFilePath(widget.path!);
    processImage(inputImage);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple[400],
        title: const Text(
          'Recognized Page',
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
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
        ),
      ),
      body: _isBusy
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Recognized Text:",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade400),
                    ),
                    padding: const EdgeInsets.all(15),
                    child: TextField(
                      maxLines: null,
                      controller: controller,
                      readOnly: false,
                      style: const TextStyle(fontSize: 16),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: "No text recognized yet...",
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: copyRecognizedText,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple[400],
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: const Icon(Icons.copy_rounded, color: Colors.white),
                    label: const Text(
                      "Copy to Clipboard",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  /// Processes the image and extracts text using Google ML Kit.
  void processImage(InputImage image) async {
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

    setState(() {
      _isBusy = true;
    });

    log(image.filePath!);
    final RecognizedText recognizedText =
        await textRecognizer.processImage(image);

    controller.text = recognizedText.text;

    setState(() {
      _isBusy = false;
    });
  }

  /// Copies the recognized text to the clipboard.
  void copyRecognizedText() {
    if (controller.text.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: controller.text));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Text copied to clipboard!"),
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("No text to copy."),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}
