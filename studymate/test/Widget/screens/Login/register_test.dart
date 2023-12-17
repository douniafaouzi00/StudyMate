import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studymate/screens/Login/register.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:studymate/l10n/l10n.dart';

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
    await pumpWidgetLoc(tester, Register());

    // Find
    final findByKey = find.byKey(Key('titleRegister'));

    // Verify
    expect(findByKey, findsOneWidget);
  });
  testWidgets('Email field display test ', (WidgetTester tester) async {
    // Build
    await pumpWidgetLoc(tester, Register());

    // Find
    final findByKey = find.byKey(Key('emailFieldRegister'));

    // Verify
    expect(findByKey, findsOneWidget);
  });
  testWidgets('Password field display test ', (WidgetTester tester) async {
    // Build
    await pumpWidgetLoc(tester, Register());

    // Find
    final findByKey = find.byKey(Key('passwordFieldRegister'));

    // Verify
    expect(findByKey, findsOneWidget);
  });
  testWidgets('Button sign up display test ', (WidgetTester tester) async {
    // Build
    await pumpWidgetLoc(tester, Register());

    // Find
    final findByKey = find.byKey(Key('signUpButton'));

    // Verify
    expect(findByKey, findsOneWidget);
  });
  testWidgets('Already have an account question display test ',
      (WidgetTester tester) async {
    // Build
    await pumpWidgetLoc(tester, Register());

    // Find
    final findByKey = find.byKey(Key('alreadyAccountQuestionRegister'));

    // Verify
    expect(findByKey, findsOneWidget);
  });
  //EMAIL DIGIT TESTS
  testWidgets('Email Text Field Hello, World! Test',
      (WidgetTester tester) async {
    await pumpWidgetLoc(tester, Register());

    // Find the text field using the specified key
    final textFieldFinder = find.byKey(Key('emailFieldRegister'));
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
    await pumpWidgetLoc(tester, Register());

    // Find the text form field using the specified key
    final textFormFieldFinder = find.byKey(Key('emailFieldRegister'));
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
    await pumpWidgetLoc(tester, Register());

    // Find the text form field using the specified key
    final textFormFieldFinder = find.byKey(Key('emailFieldRegister'));
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
    await pumpWidgetLoc(tester, Register());

    // Find the text field using the specified key
    final textFieldFinder = find.byKey(Key('passwordFieldRegister'));
    expect(textFieldFinder, findsOneWidget);

    // Enter text into the text field
    final testText = 'Hello, World!';
    await tester.enterText(textFieldFinder, testText);

    // Verify the entered text
    final enteredText =
        (tester.widget(textFieldFinder) as TextFormField).controller!.text;
    expect(enteredText, testText);
  });
  testWidgets('Less 6 char Password Test', (WidgetTester tester) async {
    await pumpWidgetLoc(tester, Register());

    // Find the password form field using the specified key
    final passwordFormFieldFinder = find.byKey(Key('passwordFieldRegister'));
    expect(passwordFormFieldFinder, findsOneWidget);

    // Enter some text into the password form field
    await tester.enterText(passwordFormFieldFinder, '12345');

    // Trigger validation
    await tester.pump();

    // Verify "Enter min. 6 characters" error message is displayed
    expect(find.text('Enter min. 6 characters'), findsOneWidget);
  });
  testWidgets('More 6 char Password Test',
      (WidgetTester tester) async {
    await pumpWidgetLoc(tester, Register());

    // Find the password form field using the specified key
    final passwordFormFieldFinder = find.byKey(Key('passwordFieldRegister'));
    expect(passwordFormFieldFinder, findsOneWidget);

    // Enter some text into the password form field
    await tester.enterText(passwordFormFieldFinder, '123456');

    // Trigger validation
    await tester.pump();

    // Verify "Enter min. 6 characters" error message is not displayed
    expect(find.text('Enter min. 6 characters'), findsNothing);
  });
}
