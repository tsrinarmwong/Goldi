import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ReceiptCaptureScreen extends StatefulWidget {
  @override
  _ReceiptCaptureScreenState createState() => _ReceiptCaptureScreenState();
}

class _ReceiptCaptureScreenState extends State<ReceiptCaptureScreen> {
  File? _image;
  bool _isLoading = false;

  Future<void> _getImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.getImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _isLoading = true;
      });

      // Simulate a delay for OCR processing (remove this when adding actual OCR)
      await Future.delayed(Duration(seconds: 3));
      setState(() {
        _isLoading = false;
      });

      // Navigate to calculator screen with mock data (replace with actual OCR result)
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Placeholder()), // Replace with CalculatorScreen
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Capture Receipt'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (_image != null) Image.file(_image!),
            if (_isLoading) CircularProgressIndicator(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => _getImage(ImageSource.camera),
                  child: Text('Take Photo'),
                ),
                ElevatedButton(
                  onPressed: () => _getImage(ImageSource.gallery),
                  child: Text('Choose from Gallery'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
