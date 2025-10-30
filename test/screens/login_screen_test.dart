import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:career_pilot/screens/login_screen.dart';

void main() {
  Widget createTestWidget() {
    return const MaterialApp(
      home: LoginScreen(),
    );
  }

  group('LoginScreen UI Elements', () {
    testWidgets('displays logo image', (tester) async {
      await tester.pumpWidget(createTestWidget());

      final imageFinder = find.byType(Image);
      expect(imageFinder, findsOneWidget);

      final image = tester.widget<Image>(imageFinder);
      final assetImage = image.image as AssetImage;
      expect(assetImage.assetName, 'assets/logo.png');
    });

    testWidgets('displays login title', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Login to CareerPilot'), findsOneWidget);
    });

    testWidgets('displays email field', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.widgetWithText(TextField, 'Email'), findsOneWidget);
    });

    testWidgets('displays password field', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.widgetWithText(TextField, 'Password'), findsOneWidget);
    });

    testWidgets('displays login button', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.widgetWithText(ElevatedButton, 'Login'), findsOneWidget);
    });

    testWidgets('password field obscures text', (tester) async {
      await tester.pumpWidget(createTestWidget());

      final passwordField = tester.widget<TextField>(
        find.widgetWithText(TextField, 'Password'),
      );
      expect(passwordField.obscureText, isTrue);
    });

    testWidgets('email field has email keyboard type', (tester) async {
      await tester.pumpWidget(createTestWidget());

      final emailField = tester.widget<TextField>(
        find.widgetWithText(TextField, 'Email'),
      );
      expect(emailField.keyboardType, TextInputType.emailAddress);
    });
  });

  group('LoginScreen User Interaction', () {
    testWidgets('can enter text in email field and it appears', (tester) async {
      await tester.pumpWidget(createTestWidget());

      const testEmail = 'user@example.com';
      await tester.enterText(
        find.widgetWithText(TextField, 'Email'),
        testEmail,
      );
      await tester.pump();

      expect(find.text(testEmail), findsOneWidget);
    });

    testWidgets('can enter text in password field', (tester) async {
      await tester.pumpWidget(createTestWidget());

      await tester.enterText(
        find.widgetWithText(TextField, 'Password'),
        'mypassword',
      );
      await tester.pump();

      final passwordField = tester.widget<TextField>(
        find.widgetWithText(TextField, 'Password'),
      );
      expect(passwordField.controller?.text, 'mypassword');
    });

    testWidgets('login button is disabled when fields are empty', (tester) async {
      await tester.pumpWidget(createTestWidget());

      final loginButton = find.widgetWithText(ElevatedButton, 'Login');
      final button = tester.widget<ElevatedButton>(loginButton);
      
      expect(button.onPressed, isNull);
    });

    testWidgets('login button is disabled with only email filled', (tester) async {
      await tester.pumpWidget(createTestWidget());

      await tester.enterText(
        find.widgetWithText(TextField, 'Email'),
        'test@example.com',
      );
      await tester.pump();

      final loginButton = find.widgetWithText(ElevatedButton, 'Login');
      final button = tester.widget<ElevatedButton>(loginButton);
      
      expect(button.onPressed, isNull);
    });

    testWidgets('login button is disabled with only password filled', (tester) async {
      await tester.pumpWidget(createTestWidget());

      await tester.enterText(
        find.widgetWithText(TextField, 'Password'),
        'password123',
      );
      await tester.pump();

      final loginButton = find.widgetWithText(ElevatedButton, 'Login');
      final button = tester.widget<ElevatedButton>(loginButton);
      
      expect(button.onPressed, isNull);
    });

    testWidgets('login button enables after filling both fields', (tester) async {
      await tester.pumpWidget(createTestWidget());

      await tester.enterText(
        find.widgetWithText(TextField, 'Email'),
        'test@example.com',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Password'),
        'password123',
      );
      await tester.pump();

      final loginButton = find.widgetWithText(ElevatedButton, 'Login');
      final button = tester.widget<ElevatedButton>(loginButton);
      
      expect(button.onPressed, isNotNull);
    });

    testWidgets('login button disables after clearing email', (tester) async {
      await tester.pumpWidget(createTestWidget());

      await tester.enterText(
        find.widgetWithText(TextField, 'Email'),
        'test@example.com',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Password'),
        'password123',
      );
      await tester.pump();

      await tester.enterText(
        find.widgetWithText(TextField, 'Email'),
        '',
      );
      await tester.pump();

      final loginButton = find.widgetWithText(ElevatedButton, 'Login');
      final button = tester.widget<ElevatedButton>(loginButton);
      
      expect(button.onPressed, isNull);
    });
  });

  group('LoginScreen Initial State', () {
    testWidgets('initially shows no error message', (tester) async {
      await tester.pumpWidget(createTestWidget());

      final errorTextFinder = find.byWidgetPredicate(
        (widget) =>
            widget is Text &&
            widget.style?.color != null &&
            widget.data != 'Login to CareerPilot' &&
            widget.data != 'Email' &&
            widget.data != 'Password' &&
            widget.data != 'Login',
      );

      expect(errorTextFinder, findsNothing);
    });
  });
}