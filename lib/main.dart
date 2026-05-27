import 'package:flutter/material.dart';
import 'package:memoryhierarchyvisualizer/src/app.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'API Demo',
    debugShowCheckedModeBanner: false,
      home: MemoryHierarchyApp(),
    );
  }
}