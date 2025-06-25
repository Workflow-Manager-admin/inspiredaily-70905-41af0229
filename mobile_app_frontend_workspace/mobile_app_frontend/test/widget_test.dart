import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mobile_app_frontend/main.dart';

void main() {
  testWidgets('App renders InspireDaily', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Check for title on the main screen
    expect(find.text('InspireDaily'), findsOneWidget);

    // Optionally, check for the presence of a quote or author (mock data)
    expect(find.byIcon(Icons.format_quote), findsOneWidget);
    expect(find.byIcon(Icons.favorite_border), findsOneWidget);
  });
}
