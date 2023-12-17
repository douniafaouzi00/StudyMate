import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:studymate/main.dart' as app;
import 'package:studymate/screens/Authenticated/authenticated.dart';
import 'package:studymate/screens/Authenticated/createLesson/new_lesson_page.dart';
import 'package:studymate/screens/Login/login.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('Submit void - 1st version - new lesson - smartphone',
      (tester) async {
    //setup
    app.main();
    //do
    await tester.pumpAndSettle(const Duration(seconds: 5));
    final button = find.byKey(Key('skipButtonVer'));

    expect(button, findsOneWidget);
    await tester.tap(button);
    await tester.pumpAndSettle(const Duration(seconds: 2));

    final buttonStart = find.byKey(Key('startOnBoardingVertical'));
    expect(buttonStart, findsOneWidget);
    await tester.tap(buttonStart);
    await tester.pumpAndSettle(const Duration(seconds: 5));
    //test
    expect(find.byType(Login), findsOneWidget);

    final textFormFieldFinder = find.byKey(Key('emailFieldLogin'));
    expect(textFormFieldFinder, findsOneWidget);
    final passwordFormFieldFinder = find.byKey(Key('passwordFieldLogin'));
    expect(passwordFormFieldFinder, findsOneWidget);
    // Enter valid email text
    final validEmailText = 'karaortega@gmail.com';
    await tester.enterText(textFormFieldFinder, validEmailText);
    await tester.enterText(passwordFormFieldFinder, 'karaortega');
    await tester.pumpAndSettle(const Duration(seconds: 2));
    final buttonLogin = find.byKey(Key('loginButton'));
    await tester.tap(buttonLogin);
    await tester.pumpAndSettle(const Duration(seconds: 5));

    expect(find.byType(Authenticated), findsOneWidget);

    await tester.tap(find.byIcon(Icons.add_circle_outline));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(find.byType(NewLessonPage), findsOneWidget);
    await tester.tap(find.byKey(Key('submitNewLessonForm')));
    await tester.pumpAndSettle(const Duration(seconds: 2));

    //Test
    expect(find.text('Please enter some text'), findsNWidgets(2));
  });
  testWidgets('Submit void - 2nd version - new lesson - smartphone',
      (tester) async {
    //setup
    app.main();
    //do
    await tester.pumpAndSettle(const Duration(seconds: 5));

    expect(find.byType(Authenticated), findsOneWidget);

    await tester.tap(find.byIcon(Icons.add_circle_outline));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(find.byType(NewLessonPage), findsOneWidget);
    await tester.tap(find.byKey(Key('submitNewLessonForm')));
    await tester.pumpAndSettle(const Duration(seconds: 2));

    //Test
    expect(find.text('Please select a category'), findsOneWidget);
  });
  testWidgets('Writing text title - new lesson - smartphone', (tester) async {
    //setup
    app.main();
    //do
    await tester.pumpAndSettle(const Duration(seconds: 5));

    expect(find.byType(Authenticated), findsOneWidget);

    await tester.tap(find.byIcon(Icons.add_circle_outline));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(find.byType(NewLessonPage), findsOneWidget);

    final textFieldFinder = find.byKey(Key('titleNewLessonForm'));
    expect(textFieldFinder, findsOneWidget);

    final testText = 'Hello, World!';
    await tester.enterText(textFieldFinder, testText);
    await tester.pumpAndSettle(const Duration(seconds: 2));

    //test
    final enteredText =
        (tester.widget(textFieldFinder) as TextFormField).controller!.text;
    expect(enteredText, testText);
  });
  testWidgets('Writing and deleting text title - new lesson - smartphone',
      (tester) async {
    //setup
    app.main();
    //do
    await tester.pumpAndSettle(const Duration(seconds: 5));

    expect(find.byType(Authenticated), findsOneWidget);

    await tester.tap(find.byIcon(Icons.add_circle_outline));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(find.byType(NewLessonPage), findsOneWidget);

    final textFieldFinder = find.byKey(Key('titleNewLessonForm'));
    expect(textFieldFinder, findsOneWidget);

    final testText = 'Hello, World!';
    await tester.enterText(textFieldFinder, testText);
    await tester.pumpAndSettle(const Duration(seconds: 2));
    await tester.enterText(textFieldFinder, '');
    await tester.pumpAndSettle(const Duration(seconds: 2));

    //test

    expect(find.text('Please enter some text'), findsOneWidget);
  });
  testWidgets(
      'Writing and deleting and rewriting text title - new lesson - smartphone',
      (tester) async {
    //setup
    app.main();
    //do
    await tester.pumpAndSettle(const Duration(seconds: 5));

    expect(find.byType(Authenticated), findsOneWidget);

    await tester.tap(find.byIcon(Icons.add_circle_outline));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(find.byType(NewLessonPage), findsOneWidget);

    final textFieldFinder = find.byKey(Key('titleNewLessonForm'));
    expect(textFieldFinder, findsOneWidget);

    final testText = 'Hello, World!';
    await tester.enterText(textFieldFinder, testText);
    await tester.pumpAndSettle(const Duration(seconds: 2));
    await tester.enterText(textFieldFinder, '');
    await tester.pumpAndSettle(const Duration(seconds: 2));

    //test
    expect(find.text('Please enter some text'), findsOneWidget);

    await tester.enterText(textFieldFinder, testText);
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(find.text('Please enter some text'), findsNothing);
  });

  testWidgets('Writing text description - new lesson - smartphone',
      (tester) async {
    //setup
    app.main();
    //do
    await tester.pumpAndSettle(const Duration(seconds: 5));

    expect(find.byType(Authenticated), findsOneWidget);

    await tester.tap(find.byIcon(Icons.add_circle_outline));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(find.byType(NewLessonPage), findsOneWidget);

    final textFieldFinder = find.byKey(Key('descriptionNewLessonForm'));
    expect(textFieldFinder, findsOneWidget);

    final testText = 'Hello, World!';
    await tester.enterText(textFieldFinder, testText);
    await tester.pumpAndSettle(const Duration(seconds: 2));

    //test
    final enteredText =
        (tester.widget(textFieldFinder) as TextFormField).controller!.text;
    expect(enteredText, testText);
  });

  testWidgets('Writing and deleting text description - new lesson - smartphone',
      (tester) async {
    //setup
    app.main();
    //do
    await tester.pumpAndSettle(const Duration(seconds: 5));

    expect(find.byType(Authenticated), findsOneWidget);

    await tester.tap(find.byIcon(Icons.add_circle_outline));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(find.byType(NewLessonPage), findsOneWidget);

    final textFieldFinder = find.byKey(Key('descriptionNewLessonForm'));
    expect(textFieldFinder, findsOneWidget);

    final testText = 'Hello, World!';
    await tester.enterText(textFieldFinder, testText);
    await tester.pumpAndSettle(const Duration(seconds: 2));
    await tester.enterText(textFieldFinder, '');
    await tester.pumpAndSettle(const Duration(seconds: 2));

    //test

    expect(find.text('Please enter some text'), findsOneWidget);
  });
  testWidgets(
      'Writing and deleting and rewriting text description - new lesson - smartphone',
      (tester) async {
    //setup
    app.main();
    //do
    await tester.pumpAndSettle(const Duration(seconds: 5));

    expect(find.byType(Authenticated), findsOneWidget);

    await tester.tap(find.byIcon(Icons.add_circle_outline));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(find.byType(NewLessonPage), findsOneWidget);

    final textFieldFinder = find.byKey(Key('descriptionNewLessonForm'));
    expect(textFieldFinder, findsOneWidget);

    final testText = 'Hello, World!';
    await tester.enterText(textFieldFinder, testText);
    await tester.pumpAndSettle(const Duration(seconds: 2));
    await tester.enterText(textFieldFinder, '');
    await tester.pumpAndSettle(const Duration(seconds: 2));

    //test
    expect(find.text('Please enter some text'), findsOneWidget);

    await tester.enterText(textFieldFinder, testText);
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(find.text('Please enter some text'), findsNothing);
  });
  testWidgets('Tapping dropdown category - new lesson - smartphone',
      (tester) async {
    //setup
    app.main();
    //do
    expect(find.byType(Authenticated), findsOneWidget);

    await tester.tap(find.byIcon(Icons.add_circle_outline));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(find.byType(NewLessonPage), findsOneWidget);
    await tester.pumpAndSettle(const Duration(seconds: 2));
    await tester.tap(find.byKey(Key('dropdownCategory')));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    //Test
    expect(find.text('Biomedical'), findsOneWidget);
  });
  testWidgets('Selecting dropdown category - new lesson - smartphone',
      (tester) async {
    //setup
    app.main();
    //do
    await tester.pumpAndSettle(const Duration(seconds: 5));
    final button = find.byKey(Key('skipButtonVer'));

    expect(button, findsOneWidget);
    await tester.tap(button);
    await tester.pumpAndSettle(const Duration(seconds: 2));

    final buttonStart = find.byKey(Key('startOnBoardingVertical'));
    expect(buttonStart, findsOneWidget);
    await tester.tap(buttonStart);
    await tester.pumpAndSettle(const Duration(seconds: 5));
    //test
    expect(find.byType(Login), findsOneWidget);

    final textFormFieldFinder = find.byKey(Key('emailFieldLogin'));
    expect(textFormFieldFinder, findsOneWidget);
    final passwordFormFieldFinder = find.byKey(Key('passwordFieldLogin'));
    expect(passwordFormFieldFinder, findsOneWidget);
    // Enter valid email text
    final validEmailText = 'karaortega@gmail.com';
    await tester.enterText(textFormFieldFinder, validEmailText);
    await tester.enterText(passwordFormFieldFinder, 'karaortega');
    await tester.pumpAndSettle(const Duration(seconds: 2));
    final buttonLogin = find.byKey(Key('loginButton'));
    await tester.tap(buttonLogin);
    await tester.pumpAndSettle(const Duration(seconds: 5));

    expect(find.byType(Authenticated), findsOneWidget);

    await tester.tap(find.byIcon(Icons.add_circle_outline));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(find.byType(NewLessonPage), findsOneWidget);
    await tester.pumpAndSettle(const Duration(seconds: 2));
    await tester.tap(find.byKey(Key('dropdownCategory')));
    await tester.pumpAndSettle(const Duration(seconds: 2));

    expect(find.text('Biomedical'), findsOneWidget);
    await tester.tap(find.text('Biomedical'));
    await tester.pumpAndSettle(const Duration(seconds: 2));

    //Test
    expect(find.text('Biomedical'), findsOneWidget);
  });

  testWidgets('Submitting a lesson - new lesson - smartphone', (tester) async {
    //setup
    app.main();
    //do
    await tester.pumpAndSettle(const Duration(seconds: 5));

    expect(find.byType(Authenticated), findsOneWidget);

    await tester.tap(find.byIcon(Icons.add_circle_outline));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(find.byType(NewLessonPage), findsOneWidget);
    await tester.pumpAndSettle(const Duration(seconds: 2));

    //TITLE
    final textFieldFinderTitle = find.byKey(Key('titleNewLessonForm'));
    expect(textFieldFinderTitle, findsOneWidget);
    final testText = 'Hello, World!';
    await tester.enterText(textFieldFinderTitle, testText);
    await tester.pumpAndSettle(const Duration(seconds: 2));
    //DESCRIPTION
    final textFieldFinderDesc = find.byKey(Key('descriptionNewLessonForm'));
    expect(textFieldFinderDesc, findsOneWidget);
    final testTextDesc = 'Hello, World!';
    await tester.enterText(textFieldFinderDesc, testTextDesc);
    await tester.pumpAndSettle(const Duration(seconds: 2));
    //CATEGORY
    await tester.tap(find.byKey(Key('dropdownCategory')));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(find.text('Biomedical'), findsOneWidget);
    await tester.tap(find.text('Biomedical'));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(find.text('Biomedical'), findsOneWidget);

    await tester.tap(find.byKey(Key('submitNewLessonForm')));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(find.text('Lesson added!'), findsOneWidget);
  });
  testWidgets('Submitting a lesson - error no title - new lesson - smartphone',
      (tester) async {
    //setup
    app.main();
    //do
    await tester.pumpAndSettle(const Duration(seconds: 5));

    expect(find.byType(Authenticated), findsOneWidget);

    await tester.tap(find.byIcon(Icons.add_circle_outline));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(find.byType(NewLessonPage), findsOneWidget);
    await tester.pumpAndSettle(const Duration(seconds: 2));

    //DESCRIPTION
    final textFieldFinderDesc = find.byKey(Key('descriptionNewLessonForm'));
    expect(textFieldFinderDesc, findsOneWidget);
    final testTextDesc = 'Hello, World!';
    await tester.enterText(textFieldFinderDesc, testTextDesc);
    await tester.pumpAndSettle(const Duration(seconds: 2));
    //CATEGORY
    await tester.tap(find.byKey(Key('dropdownCategory')));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(find.text('Biomedical'), findsOneWidget);
    await tester.tap(find.text('Biomedical'));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(find.text('Biomedical'), findsOneWidget);

    await tester.tap(find.byKey(Key('submitNewLessonForm')));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    //Test
    expect(find.text('Please enter some text'), findsOneWidget);
  });

  testWidgets(
      'Submitting a lesson - error no description - new lesson - smartphone',
      (tester) async {
    //setup
    app.main();
    //do
    await tester.pumpAndSettle(const Duration(seconds: 5));

    expect(find.byType(Authenticated), findsOneWidget);

    await tester.tap(find.byIcon(Icons.add_circle_outline));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(find.byType(NewLessonPage), findsOneWidget);
    await tester.pumpAndSettle(const Duration(seconds: 2));

    //TITLE
    final textFieldFinderTitle = find.byKey(Key('titleNewLessonForm'));
    expect(textFieldFinderTitle, findsOneWidget);
    final testText = 'Hello, World!';
    await tester.enterText(textFieldFinderTitle, testText);
    await tester.pumpAndSettle(const Duration(seconds: 2));
    //CATEGORY
    await tester.tap(find.byKey(Key('dropdownCategory')));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(find.text('Biomedical'), findsOneWidget);
    await tester.tap(find.text('Biomedical'));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(find.text('Biomedical'), findsOneWidget);

    await tester.tap(find.byKey(Key('submitNewLessonForm')));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    //Test
    expect(find.text('Please enter some text'), findsOneWidget);
  });
  testWidgets(
      'Submitting a lesson - error no category - new lesson - smartphone',
      (tester) async {
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
    //--------

    await tester.pumpAndSettle(const Duration(seconds: 5));
    expect(find.byType(Authenticated), findsOneWidget);

    await tester.tap(find.byIcon(Icons.add_circle_outline));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(find.byType(NewLessonPage), findsOneWidget);
    await tester.pumpAndSettle(const Duration(seconds: 2));

    //TITLE
    final textFieldFinderTitle = find.byKey(Key('titleNewLessonForm'));
    expect(textFieldFinderTitle, findsOneWidget);
    final testText = 'Hello, World!';
    await tester.enterText(textFieldFinderTitle, testText);
    await tester.pumpAndSettle(const Duration(seconds: 2));
    //DESCRIPTION
    final textFieldFinderDesc = find.byKey(Key('descriptionNewLessonForm'));
    expect(textFieldFinderDesc, findsOneWidget);
    final testTextDesc = 'Hello, World!';
    await tester.enterText(textFieldFinderDesc, testTextDesc);
    await tester.pumpAndSettle(const Duration(seconds: 2));

    await tester.tap(find.byKey(Key('submitNewLessonForm')));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    //Test
    expect(find.text('Please select a category'), findsOneWidget);
  });
}
