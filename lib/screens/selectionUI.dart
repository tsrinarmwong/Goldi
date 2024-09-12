import 'package:flutter/material.dart';
import 'calculatorUI.dart';
// import 'receipt_captureUI.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class SelectionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Option', style: TextStyle(fontSize: 20)),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              AnimatedTextKit(
                animatedTexts: [
                  TyperAnimatedText(
                    'GOLDI, Bill splitter💰',
                    textStyle: TextStyle(
                      fontSize: 45.0,
                      fontWeight: FontWeight.bold,
                    ),
                    speed: Duration(milliseconds: 30),
                  ),
                ],
                totalRepeatCount: 1,
                pause: Duration(milliseconds: 1000),
                displayFullTextOnTap: true,
                stopPauseOnTap: true,
              ),
              SizedBox(height: 50),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CalculatorScreen()),
                  );
                },
                child: Text('Start Receipt Filling', style: TextStyle(fontSize: 20)),
              ),
              // SizedBox(height: 16.0),
              // ElevatedButton(
              //   onPressed: () {
              //     Navigator.push(
              //       context,
              //       MaterialPageRoute(
              //           builder: (context) => ReceiptCaptureScreen()),
              //     );
              //   },
              //   child: Text('Capture Receipt by Camera', style: TextStyle(fontSize: 20)),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
