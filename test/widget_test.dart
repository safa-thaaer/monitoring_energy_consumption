import 'package:flutter_test/flutter_test.dart';
import 'package:monitoring_energy_consumption/main.dart';

void main() {
  testWidgets('App should load', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that app loads
    expect(find.byType(MyApp), findsOneWidget);
  });
}
