
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safeher/main.dart';

void main() {
  testWidgets('SafeHer app loads', (WidgetTester tester) async {
    await tester.pumpWidget(const SafeHerApp());

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
