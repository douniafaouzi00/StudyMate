import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:studymate/main.dart' as app;
import 'package:studymate/screens/Authenticated/Lesson/lesson_page.dart';
import 'package:studymate/screens/Authenticated/authenticated.dart';
import 'package:studymate/screens/Login/login.dart';
import 'package:studymate/screens/Authenticated/Search/search_page.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('Writing on searchbar - searchpage - smartphone', (tester) async {
    //setup
    app.main();
    //do
    //LOGIN
    await tester.pumpAndSettle(const Duration(seconds: 5));
    final button = find.byKey(Key('skipButtonVer'));
    expect(button, findsOneWidget);
    await tester.tap(button);
    await tester.pumpAndSettle(const Duration(seconds: 2));
    final buttonStart = find.byKey(Key('startOnBoardingVertical'));
    expect(buttonStart, findsOneWidget);
    await tester.tap(buttonStart);
    await tester.pumpAndSettle(const Duration(seconds: 5));
    expect(find.byType(Login), findsOneWidget);
    final textFormFieldFinder = find.byKey(Key('emailFieldLogin'));
    expect(textFormFieldFinder, findsOneWidget);
    final passwordFormFieldFinder = find.byKey(Key('passwordFieldLogin'));
    expect(passwordFormFieldFinder, findsOneWidget);
    final validEmailText = 'karaortega@gmail.com';
    await tester.enterText(textFormFieldFinder, validEmailText);
    await tester.enterText(passwordFormFieldFinder, 'karaortega');
    await tester.pumpAndSettle(const Duration(seconds: 2));
    final buttonLogin = find.byKey(Key('loginButton'));
    await tester.tap(buttonLogin);
    //------
    await tester.pumpAndSettle(const Duration(seconds: 5));
    expect(find.byType(Authenticated), findsOneWidget);

    await tester.tap(find.byIcon(Icons.search));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(find.byType(SearchPage), findsOneWidget);
    // Find the text field using the specified key
    final textFieldFinder = find.byType(TextField);
    expect(textFieldFinder, findsOneWidget);

    final testText = 'Hello, World!';
    await tester.enterText(textFieldFinder, testText);
    await tester.pumpAndSettle(const Duration(seconds: 2));
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();

    //test
    final enteredText =
        (tester.widget(textFieldFinder) as TextField).controller!.text;
    expect(enteredText, testText);
  });

  testWidgets(
      'Writing on searchbar and clicking search button - searchpage - smartphone',
      (tester) async {
    //setup
    app.main();
    //do
    await tester.pumpAndSettle(const Duration(seconds: 5));
    expect(find.byType(Authenticated), findsOneWidget);

    await tester.tap(find.byIcon(Icons.search));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(find.byType(SearchPage), findsOneWidget);
    // Find the text field using the specified key
    final textFieldFinder = find.byType(TextField);
    expect(textFieldFinder, findsOneWidget);

    final testText = 'randombowrdsforsearchpage';
    await tester.enterText(textFieldFinder, testText);
    await tester.pumpAndSettle(const Duration(seconds: 2));
    await tester.tap(find.byIcon(Icons.search).at(0));
    await tester.pumpAndSettle(const Duration(seconds: 2));

    //test
    expect(find.text(testText), findsNWidgets(2));
  });
  testWidgets(
      'Writing on searchbar and clicking search button - searchpage - smartphone',
      (tester) async {
    //setup
    app.main();
    //do
    await tester.pumpAndSettle(const Duration(seconds: 5));
    expect(find.byType(Authenticated), findsOneWidget);

    await tester.tap(find.byIcon(Icons.search));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(find.byType(SearchPage), findsOneWidget);
    // Find the text field using the specified key
    final textFieldFinder = find.byType(TextField);
    expect(textFieldFinder, findsOneWidget);

    final testText = 'randombowrdsforsearchpage';
    await tester.enterText(textFieldFinder, testText);
    await tester.pumpAndSettle(const Duration(seconds: 2));
    await tester.tap(find.byIcon(Icons.search).at(0));
    await tester.pumpAndSettle(const Duration(seconds: 2));

    //test
    expect(find.text('No lessons'), findsOneWidget);
  });
  testWidgets(
      'Writing on searchbar and manually deleting - searchpage - smartphone',
      (tester) async {
    //setup
    app.main();
    //do
    await tester.pumpAndSettle(const Duration(seconds: 5));
    expect(find.byType(Authenticated), findsOneWidget);

    await tester.tap(find.byIcon(Icons.search));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(find.byType(SearchPage), findsOneWidget);
    // Find the text field using the specified key
    final textFieldFinder = find.byType(TextField);
    expect(textFieldFinder, findsOneWidget);

    final testText = 'Hello, World!';
    await tester.enterText(textFieldFinder, testText);
    await tester.pumpAndSettle(const Duration(seconds: 2));
    await tester.pump();
    await tester.enterText(textFieldFinder, '');
    await tester.pumpAndSettle(const Duration(seconds: 2));
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();

    //test
    final enteredText =
        (tester.widget(textFieldFinder) as TextField).controller!.text;
    expect(enteredText, '');
  });
  testWidgets(
      'Writing on searchbar exist delete button - searchpage - smartphone',
      (tester) async {
    //setup
    app.main();
    //do
    await tester.pumpAndSettle(const Duration(seconds: 5));
    expect(find.byType(Authenticated), findsOneWidget);

    await tester.tap(find.byIcon(Icons.search));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(find.byType(SearchPage), findsOneWidget);
    // Find the text field using the specified key
    final textFieldFinder = find.byType(TextField);
    expect(textFieldFinder, findsOneWidget);

    final testText = 'Hello, World!';
    await tester.enterText(textFieldFinder, testText);
    await tester.pumpAndSettle(const Duration(seconds: 2));
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();

    //test
    expect(find.byIcon(Icons.delete), findsOneWidget);
  });
  testWidgets(
      'Writing on searchbar and clicking delete button - searchpage - smartphone',
      (tester) async {
    //setup
    app.main();
    //do
    await tester.pumpAndSettle(const Duration(seconds: 5));
    expect(find.byType(Authenticated), findsOneWidget);

    await tester.tap(find.byIcon(Icons.search));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(find.byType(SearchPage), findsOneWidget);
    // Find the text field using the specified key
    final textFieldFinder = find.byType(TextField);
    expect(textFieldFinder, findsOneWidget);

    final testText = 'Hello, World!';
    await tester.enterText(textFieldFinder, testText);
    await tester.pumpAndSettle(const Duration(seconds: 2));
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    await tester.tap(find.byIcon(Icons.delete));
    await tester.pumpAndSettle(const Duration(seconds: 2));

    //test
    final enteredText =
        (tester.widget(textFieldFinder) as TextField).controller!.text;
    expect(enteredText, '');
  });
  testWidgets(
      'Writing on searchbar and clicking delete button existing delete button - searchpage - smartphone',
      (tester) async {
    //setup
    app.main();
    //do
    await tester.pumpAndSettle(const Duration(seconds: 5));
    expect(find.byType(Authenticated), findsOneWidget);

    await tester.tap(find.byIcon(Icons.search));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(find.byType(SearchPage), findsOneWidget);
    // Find the text field using the specified key
    final textFieldFinder = find.byType(TextField);
    expect(textFieldFinder, findsOneWidget);

    final testText = 'Hello, World!';
    await tester.enterText(textFieldFinder, testText);
    await tester.pumpAndSettle(const Duration(seconds: 2));
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    await tester.tap(find.byIcon(Icons.delete));
    await tester.pumpAndSettle(const Duration(seconds: 2));

    //test
    expect(find.byIcon(Icons.delete), findsNothing);
  });
  testWidgets('Clicking recent lessons - searchpage - smartphone',
      (tester) async {
    //setup
    app.main();

    //do
    await tester.pumpAndSettle(const Duration(seconds: 5));
    expect(find.byType(Authenticated), findsOneWidget);

    await tester.tap(find.byIcon(Icons.search));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(find.byType(SearchPage), findsOneWidget);

    await tester.tap(find.byKey(Key('lessonCard')).at(0));
    await tester.pumpAndSettle(const Duration(seconds: 5));

    //test
    expect(find.byType(LessonPage), findsOneWidget);
  });
  testWidgets('Clicking recent lessons and return - searchpage - smartphone',
      (tester) async {
    //setup
    app.main();
    //do
    await tester.pumpAndSettle(const Duration(seconds: 5));
    expect(find.byType(Authenticated), findsOneWidget);

    await tester.tap(find.byIcon(Icons.search));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(find.byType(SearchPage), findsOneWidget);

    await tester.tap(find.byKey(Key('lessonCard')).at(0));
    await tester.pumpAndSettle(const Duration(seconds: 5));
    expect(find.byType(LessonPage), findsOneWidget);
    await tester.tap(find.byIcon(Icons.arrow_back_ios_new));
    await tester.pumpAndSettle(const Duration(seconds: 5));
    //test
    expect(find.byType(SearchPage), findsOneWidget);
  });

}
