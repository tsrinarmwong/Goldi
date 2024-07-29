import 'package:flutter/material.dart';
// import 'package:goldi/screens/receipt_captureUI.dart';
import 'package:goldi/screens/selectionUI.dart';

final Color primaryColor = Color(0xFFF7B32B); // Gold
final Color secondaryColor = Color(0xFF465775); // Deep Navy Blue
final Color coralColor = Color(0xFFFF6F59);
final Color lightYellowColor = Color(0xFFFCF6B1);
final Color darkSlateBlueColor = Color(0xFF2D3A4D);

void main() {
  runApp(CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Goldi Bill Calculator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: primaryColor,
        hintColor: secondaryColor,
        scaffoldBackgroundColor: lightYellowColor,
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: Colors.black),
          bodyMedium: TextStyle(color: Colors.black),
          headlineLarge: TextStyle(fontFamily: 'PlayfairDisplay', color: primaryColor),
          labelLarge: TextStyle(color: Colors.white),
        ),
        buttonTheme: ButtonThemeData(
          buttonColor: primaryColor,
          textTheme: ButtonTextTheme.primary,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: primaryColor,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      home: SelectionScreen(),
    );
  }
}
