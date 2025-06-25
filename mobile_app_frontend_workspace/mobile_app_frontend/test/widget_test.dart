import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app_frontend/main.dart';

void main() {
  testWidgets('App builds without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const InspireDailyApp());
    expect(find.byType(InspireDailyApp), findsOneWidget);
  });
}
