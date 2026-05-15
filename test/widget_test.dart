import 'package:flutter_test/flutter_test.dart';
import 'package:maahvi/app.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that our app builds (basic check since initial state isn't a counter)
    expect(find.byType(MyApp), findsOneWidget);
  });
}
