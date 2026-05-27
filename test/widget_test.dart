// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.


import 'package:flutter_test/flutter_test.dart';
import 'package:memoryhierarchyvisualizer/src/app.dart';

void main() {
  testWidgets('App loads and shows simulation controls',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MemoryHierarchyApp());
    await tester.pumpAndSettle();

    expect(find.text('Memory Hierarchy Visualizer'), findsOneWidget);
    expect(find.text('SIMULATION CONTROLS'), findsOneWidget);
    expect(find.text('Data is in CACHE'), findsOneWidget);
    expect(find.text('Data is in RAM'), findsOneWidget);
    expect(find.text('Data is in SSD'), findsOneWidget);
  });
}
