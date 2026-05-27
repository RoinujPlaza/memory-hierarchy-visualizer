import 'package:flutter/material.dart';
import 'memory_hierarchy_screen.dart';

class MemoryHierarchyApp extends StatelessWidget {
  const MemoryHierarchyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Memory Hierarchy Visualizer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, fontFamily: 'Arial'),
      home: const MemoryHierarchyScreen(),
    );
  }
}
