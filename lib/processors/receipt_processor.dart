import 'package:image_picker/image_picker.dart';
// import 'package:google_ml_kit/google_ml_kit.dart';
import 'dart:io';
import 'item.dart';

class ReceiptProcessor {
  final ImagePicker _picker = ImagePicker();

  // Future<List<Item>> captureAndProcessReceipt(ImageSource source) async {
  //   try {
  //     // Pick an image from the specified source (camera or gallery)
  //     final pickedFile = await _picker.pickImage(source: source);

  //     if (pickedFile != null) {
  //       print('Image picked: ${pickedFile.path}');
  //       // Convert the picked file into an InputImage for ML Kit processing
  //       final inputImage = InputImage.fromFilePath(pickedFile.path);

  //       // Initialize the text recognizer
  //       final textRecognizer = GoogleMlKit.vision.textRecognizer();

  //       // Process the image to extract recognized text
  //       final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);

  //       // Parse the recognized text into a list of Item objects
  //       return _parseExtractedText(recognizedText.text);
  //     } else {
  //       print('No image picked.');
  //       // Return an empty list if no image was picked
  //       return [];
  //     }
  //   } catch (e) {
  //     print('Error during image processing: $e');
  //     return [];
  //   }
  // }

  // // Helper method to parse extracted text into a list of Item objects
  // List<Item> _parseExtractedText(String text) {
  //   List<Item> items = [];
    
  //   // Split the text into lines
  //   List<String> lines = text.split('\n');
    
  //   for (String line in lines) {
  //     // Split each line into parts based on spaces
  //     List<String> parts = line.split(' ');
      
  //     if (parts.length >= 2) {
  //       // Join all parts except the last one to form the item name
  //       String name = parts.sublist(0, parts.length - 1).join(' ');
        
  //       // Try to parse the last part as the item price
  //       double? price = double.tryParse(parts.last);
        
  //       if (price != null) {
  //         // If the price is valid, create an Item object and add it to the list
  //         items.add(Item(name: name, totalPrice: price, eaters: []));
  //       }
  //     }
  //   }
  //   return items;
  // }
}
