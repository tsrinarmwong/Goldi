// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
// import 'package:goldi/processors/item.dart';
// import 'package:goldi/screens/text_display_screen.dart';
// import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:goldi/processors/receipt_processor.dart';
// import 'text_display_screen.dart'; // Import the new screen

class ReceiptCaptureScreen extends StatefulWidget {
  @override
  _ReceiptCaptureScreenState createState() => _ReceiptCaptureScreenState();
}

class _ReceiptCaptureScreenState extends State<ReceiptCaptureScreen> {
  File? _image;
  bool _isLoading = false;
  final ReceiptProcessor _receiptProcessor = ReceiptProcessor();

  // Future<void> _getImage(ImageSource source) async {
  //   try {
  //     setState(() {
  //       _isLoading = true;
  //     });

  //     final List<Item> items = await _receiptProcessor.captureAndProcessReceipt(source);

  //     setState(() {
  //       _isLoading = false;
  //       _image = items.isNotEmpty ? File('path_to_image') : null;  // Update this with the actual path if needed
  //     });

  //     if (items.isNotEmpty) {
  //       Navigator.pushReplacement(
  //         context,
  //         MaterialPageRoute(builder: (context) => TextDisplayScreen(items: items)),
  //       );
  //     }
  //   } catch (e) {
  //     setState(() {
  //       _isLoading = false;
  //     });
  //     print('Error during image capture and processing: $e');
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Capture Receipt'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_image != null) Image.file(_image!),
            if (_isLoading) CircularProgressIndicator(),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // ElevatedButton(
                //   onPressed: () => _getImage(ImageSource.camera),
                //   child: Text('Take Photo'),
                // ),
                // ElevatedButton(
                //   onPressed: () => _getImage(ImageSource.gallery),
                //   child: Text('Choose from Gallery'),
                // ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
