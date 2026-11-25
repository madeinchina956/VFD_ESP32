import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/main.dart';

void main() {
  testWidgets('VFD application launches', (tester) async {
    await tester.pumpWidget(const VfdApp());
    await tester.pump();

    expect(find.text('VFD Controller'), findsOneWidget);
    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.text('Control'), findsOneWidget);
    expect(find.text('Faults'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);

    // Dispose the application and its polling timer.
    await tester.pumpWidget(const SizedBox.shrink());
  });
}