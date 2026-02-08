import 'package:flutter_test/flutter_test.dart';
import 'package:password_manager/main.dart';

void main() {
  testWidgets('Password Manager app loads', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const PasswordManagerApp());

    // Verify that the app title is displayed
    expect(find.text('Password Manager'), findsOneWidget);
  });
}
