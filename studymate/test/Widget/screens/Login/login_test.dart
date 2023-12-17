import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studymate/screens/Login/login.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:studymate/l10n/l10n.dart';
import 'package:studymate/screens/Login/reset.dart';

void main() {
  Future<void> pumpWidgetLoc(WidgetTester tester, Widget toTest) async {
    await tester.pumpWidget(
      MaterialApp(
        supportedLocales: L10n.all,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        home: toTest,
      ),
    );
  }

  //DISPLAY TESTS
  testWidgets('Title display test ', (WidgetTester tester) async {
    // Build
    await pumpWidgetLoc(tester, Login());

    // Find
    final findByKey = find.byKey(Key('titleLogin'));

    // Verify
    expect(findByKey, findsOneWidget);
  });
  testWidgets('Email field display test ', (WidgetTester tester) async {
    // Build
    await pumpWidgetLoc(tester, Login());

    // Find
    final findByKey = find.byKey(Key('emailFieldLogin'));

    // Verify
    expect(findByKey, findsOneWidget);
  });
  testWidgets('Password field display test ', (WidgetTester tester) async {
    // Build
    await pumpWidgetLoc(tester, Login());

    // Find
    final findByKey = find.byKey(Key('passwordFieldLogin'));

    // Verify
    expect(findByKey, findsOneWidget);
  });
  testWidgets('Forgot password display test ', (WidgetTester tester) async {
    // Build
    await pumpWidgetLoc(tester, Login());

    // Find
    final findByKey = find.byKey(Key('forgotPwdGestureLogin'));

    // Verify
    expect(findByKey, findsOneWidget);
  });
  testWidgets('Button login display test ', (WidgetTester tester) async {
    // Build
    await pumpWidgetLoc(tester, Login());

    // Find
    final findByKey = find.byKey(Key('loginButton'));

    // Verify
    expect(findByKey, findsOneWidget);
  });
  testWidgets('No account question display test ', (WidgetTester tester) async {
    // Build
    await pumpWidgetLoc(tester, Login());

    // Find
    final findByKey = find.byKey(Key('noAccountQuestionLogin'));

    // Verify
    expect(findByKey, findsOneWidget);
  });
  testWidgets('Google login display test ', (WidgetTester tester) async {
    // Build
    await pumpWidgetLoc(tester, Login());

    // Find
    final findByKey = find.byKey(Key('buttonSignUpGoogle'));

    // Verify
    expect(findByKey, findsOneWidget);
  });
  //EMAIL DIGIT TESTS
  testWidgets('Email Text Field Hello, World! Test',
      (WidgetTester tester) async {
    await pumpWidgetLoc(tester, Login());

    // Find the text field using the specified key
    final textFieldFinder = find.byKey(Key('emailFieldLogin'));
    expect(textFieldFinder, findsOneWidget);

    // Enter text into the text field
    final testText = 'Hello, World!';
    await tester.enterText(textFieldFinder, testText);

    // Verify the entered text
    final enteredText =
        (tester.widget(textFieldFinder) as TextFormField).controller!.text;
    expect(enteredText, testText);
  });
  testWidgets('Email Validation No Valid Test', (WidgetTester tester) async {
    await pumpWidgetLoc(tester, Login());

    // Find the text form field using the specified key
    final textFormFieldFinder = find.byKey(Key('emailFieldLogin'));
    expect(textFormFieldFinder, findsOneWidget);

    // Enter invalid email text
    final invalidEmailText = 'notanemail';
    await tester.enterText(textFormFieldFinder, invalidEmailText);

    // Trigger validation
    await tester.pump();

    // Verify error message is displayed
    expect(find.text('Enter a valid email'), findsOneWidget);
  });
  testWidgets('Valid Email Test', (WidgetTester tester) async {
    await pumpWidgetLoc(tester, Login());

    // Find the text form field using the specified key
    final textFormFieldFinder = find.byKey(Key('emailFieldLogin'));
    expect(textFormFieldFinder, findsOneWidget);

    // Enter valid email text
    final validEmailText = 'example@email.com';
    await tester.enterText(textFormFieldFinder, validEmailText);

    // Trigger validation
    await tester.pump();

    // Verify error message is not displayed
    expect(find.text('Enter a valid email'), findsNothing);
  });
  // PASSWORD DIGIT TESTS
  testWidgets('Password Text Field Hello, World! Test',
      (WidgetTester tester) async {
    await pumpWidgetLoc(tester, Login());

    // Find the text field using the specified key
    final textFieldFinder = find.byKey(Key('passwordFieldLogin'));
    expect(textFieldFinder, findsOneWidget);

    // Enter text into the text field
    final testText = 'Hello, World!';
    await tester.enterText(textFieldFinder, testText);

    // Verify the entered text
    final enteredText =
        (tester.widget(textFieldFinder) as TextFormField).controller!.text;
    expect(enteredText, testText);
  });
  testWidgets('Empty Password Test', (WidgetTester tester) async {
    await pumpWidgetLoc(tester, Login());

    // Find the password form field using the specified key
    final passwordFormFieldFinder = find.byKey(Key('passwordFieldLogin'));
    expect(passwordFormFieldFinder, findsOneWidget);

    // Enter some text into the password form field
    await tester.enterText(passwordFormFieldFinder, 'somepassword');

    // Clear the text from the password form field
    await tester.enterText(passwordFormFieldFinder, '');

    // Trigger validation
    await tester.pump();

    // Verify "Enter password" error message is displayed
    expect(find.text('Enter password'), findsOneWidget);
  });
  testWidgets('Empty Password and after correct Password Test',
      (WidgetTester tester) async {
    await pumpWidgetLoc(tester, Login());

    // Find the password form field using the specified key
    final passwordFormFieldFinder = find.byKey(Key('passwordFieldLogin'));
    expect(passwordFormFieldFinder, findsOneWidget);

    // Enter some text into the password form field
    await tester.enterText(passwordFormFieldFinder, 'somepassword');

    // Clear the text from the password form field
    await tester.enterText(passwordFormFieldFinder, '');

    // Trigger validation
    await tester.pump();

    // Verify "Enter password" error message is displayed
    expect(find.text('Enter password'), findsOneWidget);

    // Enter text into the password form field again
    await tester.enterText(passwordFormFieldFinder, 'newpassword');

    // Trigger validation
    await tester.pump();

    // Verify "Enter password" error message is no longer displayed
    expect(find.text('Enter password'), findsNothing);
  });
  //NAVIGATIONS TESTS
  testWidgets('Forgot Password Navigation Test', (WidgetTester tester) async {
    await pumpWidgetLoc(tester, Login());

    // Find the GestureDetector using the specified key
    final gestureDetectorFinder = find.byKey(Key('forgotPwdGestureLogin'));
    expect(gestureDetectorFinder, findsOneWidget);

    // Tap the GestureDetector
    await tester.tap(gestureDetectorFinder);
    await tester.pumpAndSettle();

    // Verify if the Reset widget is pushed onto the navigator
    expect(find.byType(Reset), findsOneWidget);
  });
}
