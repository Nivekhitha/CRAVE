import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(
    home: Scaffold(
      body: Center(
        child: Text(
          'Environment Check: SUCCESS', 
          style: TextStyle(fontSize: 24, color: Colors.green),
        ),
      ),
    ),
  ));
}
