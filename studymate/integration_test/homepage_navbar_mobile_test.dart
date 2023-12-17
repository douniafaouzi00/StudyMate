import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:studymate/main.dart' as app;
import 'package:studymate/screens/Authenticated/Chat/chats_page.dart';
import 'package:studymate/screens/Authenticated/Search/search_page.dart';
import 'package:studymate/screens/Authenticated/authenticated.dart';
import 'package:studymate/screens/Authenticated/createLesson/new_lesson_page.dart';
import 'package:studymate/screens/Authenticated/homepage.dart';
import 'package:studymate/screens/Authenticated/profilePage/own_profile_page.dart';
import 'package:studymate/screens/Login/login.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('Clicking on home from home - navbar - smartphone',
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
    //------
    await tester.pumpAndSettle(const Duration(seconds: 5));
    expect(find.byType(Authenticated), findsOneWidget);

    await tester.tap(find.byIcon(Icons.home));
    await tester.pumpAndSettle(const Duration(seconds: 2));

    //test

    expect(find.byType(HomePage), findsOneWidget);
  });
  testWidgets('Clicking on search from home - navbar - smartphone',
      (tester) async {
    //setup
    app.main();
    //do
    await tester.pumpAndSettle(const Duration(seconds: 5));
    expect(find.byType(Authenticated), findsOneWidget);

    await tester.tap(find.byIcon(Icons.search));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    //test

    expect(find.byType(SearchPage), findsOneWidget);
  });
  testWidgets('Clicking on add from home - navbar - smartphone',
      (tester) async {
    //setup
    app.main();
    //do
    await tester.pumpAndSettle(const Duration(seconds: 5));

    expect(find.byType(Authenticated), findsOneWidget);

    await tester.tap(find.byIcon(Icons.add_circle_outline));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    //test

    expect(find.byType(NewLessonPage), findsOneWidget);
  });
  testWidgets('Clicking on message from home - navbar - smartphone',
      (tester) async {
    //setup
    app.main();
    //do
    await tester.pumpAndSettle(const Duration(seconds: 5));

    expect(find.byType(Authenticated), findsOneWidget);

    await tester.tap(find.byIcon(Icons.message));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    //test

    expect(find.byType(ChatsPage), findsOneWidget);
  });
  testWidgets('Clicking on profile from home - navbar - smartphone',
      (tester) async {
    //setup
    app.main();
    //do
    await tester.pumpAndSettle(const Duration(seconds: 5));

    expect(find.byType(Authenticated), findsOneWidget);

    await tester.tap(find.byIcon(Icons.account_circle));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    //test

    expect(find.byType(OwnProfilePage), findsOneWidget);
  });
  testWidgets('Clicking on home from search - navbar - smartphone',
      (tester) async {
    //setup
    app.main();
    //do
    await tester.pumpAndSettle(const Duration(seconds: 5));
    expect(find.byType(Authenticated), findsOneWidget);

    await tester.tap(find.byIcon(Icons.search));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(find.byType(SearchPage), findsOneWidget);
    await tester.tap(find.byIcon(Icons.home));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    //test
    expect(find.byType(HomePage), findsOneWidget);
  });
  testWidgets('Clicking on search from search - navbar - smartphone',
      (tester) async {
    //setup
    app.main();
    //do
    await tester.pumpAndSettle(const Duration(seconds: 5));
    expect(find.byType(Authenticated), findsOneWidget);

    await tester.tap(find.byIcon(Icons.search));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(find.byType(SearchPage), findsOneWidget);
    await tester.tap(find.byIcon(Icons.search).at(1));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    //test
    expect(find.byType(SearchPage), findsOneWidget);
  });
  testWidgets('Clicking on add from search - navbar - smartphone',
      (tester) async {
    //setup
    app.main();
    //do
    await tester.pumpAndSettle(const Duration(seconds: 5));
    expect(find.byType(Authenticated), findsOneWidget);

    await tester.tap(find.byIcon(Icons.search));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(find.byType(SearchPage), findsOneWidget);
    await tester.tap(find.byIcon(Icons.add_circle_outline));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    //test
    expect(find.byType(NewLessonPage), findsOneWidget);
  });
  testWidgets('Clicking on message from search - navbar - smartphone',
      (tester) async {
    //setup
    app.main();
    //do
    await tester.pumpAndSettle(const Duration(seconds: 5));
    expect(find.byType(Authenticated), findsOneWidget);

    await tester.tap(find.byIcon(Icons.search));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(find.byType(SearchPage), findsOneWidget);
    await tester.tap(find.byIcon(Icons.message));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    //test
    expect(find.byType(ChatsPage), findsOneWidget);
  });
  testWidgets('Clicking on profile from search - navbar - smartphone',
      (tester) async {
    //setup
    app.main();
    //do
    await tester.pumpAndSettle(const Duration(seconds: 5));
    expect(find.byType(Authenticated), findsOneWidget);

    await tester.tap(find.byIcon(Icons.search));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(find.byType(SearchPage), findsOneWidget);
    await tester.tap(find.byIcon(Icons.account_circle));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    //test
    expect(find.byType(OwnProfilePage), findsOneWidget);
  });

  testWidgets('Clicking on home from add - navbar - smartphone',
      (tester) async {
    //setup
    app.main();
    //do
    await tester.pumpAndSettle(const Duration(seconds: 5));
    expect(find.byType(Authenticated), findsOneWidget);

    await tester.tap(find.byIcon(Icons.add_circle_outline));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(find.byType(NewLessonPage), findsOneWidget);
    await tester.tap(find.byIcon(Icons.home));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    //test
    expect(find.byType(HomePage), findsOneWidget);
  });
  testWidgets('Clicking on search from add - navbar - smartphone',
      (tester) async {
    //setup
    app.main();
    //do
    await tester.pumpAndSettle(const Duration(seconds: 5));
    expect(find.byType(Authenticated), findsOneWidget);

    await tester.tap(find.byIcon(Icons.add_circle_outline));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(find.byType(NewLessonPage), findsOneWidget);
    await tester.tap(find.byIcon(Icons.search));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    //test
    expect(find.byType(SearchPage), findsOneWidget);
  });
  testWidgets('Clicking on add from add - navbar - smartphone', (tester) async {
    //setup
    app.main();
    //do
    await tester.pumpAndSettle(const Duration(seconds: 5));
    expect(find.byType(Authenticated), findsOneWidget);

    await tester.tap(find.byIcon(Icons.add_circle_outline));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(find.byType(NewLessonPage), findsOneWidget);
    await tester.tap(find.byIcon(Icons.add_circle_outline));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    //test
    expect(find.byType(NewLessonPage), findsOneWidget);
  });
  testWidgets('Clicking on message from add - navbar - smartphone',
      (tester) async {
    //setup
    app.main();
    //do
    await tester.pumpAndSettle(const Duration(seconds: 5));
    expect(find.byType(Authenticated), findsOneWidget);

    await tester.tap(find.byIcon(Icons.add_circle_outline));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(find.byType(NewLessonPage), findsOneWidget);
    await tester.tap(find.byIcon(Icons.message));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    //test
    expect(find.byType(ChatsPage), findsOneWidget);
  });
  testWidgets('Clicking on profile from add - navbar - smartphone',
      (tester) async {
    //setup
    app.main();
    //do
    await tester.pumpAndSettle(const Duration(seconds: 5));
    expect(find.byType(Authenticated), findsOneWidget);

    await tester.tap(find.byIcon(Icons.add_circle_outline));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(find.byType(NewLessonPage), findsOneWidget);
    await tester.tap(find.byIcon(Icons.account_circle));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    //test
    expect(find.byType(OwnProfilePage), findsOneWidget);
  });

  testWidgets('Clicking on home from message - navbar - smartphone',
      (tester) async {
    //setup
    app.main();
    //do
    await tester.pumpAndSettle(const Duration(seconds: 5));
    expect(find.byType(Authenticated), findsOneWidget);

    await tester.tap(find.byIcon(Icons.message));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(find.byType(ChatsPage), findsOneWidget);
    await tester.tap(find.byIcon(Icons.home));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    //test
    expect(find.byType(HomePage), findsOneWidget);
  });
  testWidgets('Clicking on search from message - navbar - smartphone',
      (tester) async {
    //setup
    app.main();
    //do
    await tester.pumpAndSettle(const Duration(seconds: 5));
    expect(find.byType(Authenticated), findsOneWidget);

    await tester.tap(find.byIcon(Icons.message));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(find.byType(ChatsPage), findsOneWidget);
    await tester.tap(find.byIcon(Icons.search));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    //test
    expect(find.byType(SearchPage), findsOneWidget);
  });
  testWidgets('Clicking on add from message - navbar - smartphone',
      (tester) async {
    //setup
    app.main();
    //do
    await tester.pumpAndSettle(const Duration(seconds: 5));
    expect(find.byType(Authenticated), findsOneWidget);

    await tester.tap(find.byIcon(Icons.message));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(find.byType(ChatsPage), findsOneWidget);
    await tester.tap(find.byIcon(Icons.add_circle_outline));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    //test
    expect(find.byType(NewLessonPage), findsOneWidget);
  });
  testWidgets('Clicking on message from message - navbar - smartphone',
      (tester) async {
    //setup
    app.main();
    //do
    await tester.pumpAndSettle(const Duration(seconds: 5));
    expect(find.byType(Authenticated), findsOneWidget);

    await tester.tap(find.byIcon(Icons.message));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(find.byType(ChatsPage), findsOneWidget);
    await tester.tap(find.byIcon(Icons.message));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    //test
    expect(find.byType(ChatsPage), findsOneWidget);
  });
  testWidgets('Clicking on profile from message - navbar - smartphone',
      (tester) async {
    //setup
    app.main();
    //do
    await tester.pumpAndSettle(const Duration(seconds: 5));
    expect(find.byType(Authenticated), findsOneWidget);

    await tester.tap(find.byIcon(Icons.message));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(find.byType(ChatsPage), findsOneWidget);
    await tester.tap(find.byIcon(Icons.account_circle));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    //test
    expect(find.byType(OwnProfilePage), findsOneWidget);
  });

  testWidgets('Clicking on home from profile - navbar - smartphone',
      (tester) async {
    //setup
    app.main();
    //do
    await tester.pumpAndSettle(const Duration(seconds: 5));
    expect(find.byType(Authenticated), findsOneWidget);

    await tester.tap(find.byIcon(Icons.account_circle));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(find.byType(OwnProfilePage), findsOneWidget);
    await tester.tap(find.byIcon(Icons.home));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    //test
    expect(find.byType(HomePage), findsOneWidget);
  });
  testWidgets('Clicking on search from profile - navbar - smartphone',
      (tester) async {
    //setup
    app.main();
    //do
    await tester.pumpAndSettle(const Duration(seconds: 5));
    expect(find.byType(Authenticated), findsOneWidget);

    await tester.tap(find.byIcon(Icons.account_circle));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(find.byType(OwnProfilePage), findsOneWidget);
    await tester.tap(find.byIcon(Icons.search));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    //test
    expect(find.byType(SearchPage), findsOneWidget);
  });
  testWidgets('Clicking on add from profile - navbar - smartphone',
      (tester) async {
    //setup
    app.main();
    //do
    await tester.pumpAndSettle(const Duration(seconds: 5));
    expect(find.byType(Authenticated), findsOneWidget);

    await tester.tap(find.byIcon(Icons.account_circle));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(find.byType(OwnProfilePage), findsOneWidget);
    await tester.tap(find.byIcon(Icons.add_circle_outline));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    //test
    expect(find.byType(NewLessonPage), findsOneWidget);
  });
  testWidgets('Clicking on message from profile - navbar - smartphone',
      (tester) async {
    //setup
    app.main();
    //do
    await tester.pumpAndSettle(const Duration(seconds: 5));
    expect(find.byType(Authenticated), findsOneWidget);

    await tester.tap(find.byIcon(Icons.account_circle));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(find.byType(OwnProfilePage), findsOneWidget);
    await tester.tap(find.byIcon(Icons.message));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    //test
    expect(find.byType(ChatsPage), findsOneWidget);
  });
  testWidgets('Clicking on profile from profile - navbar - smartphone',
      (tester) async {
    //setup
    app.main();
    //do
    await tester.pumpAndSettle(const Duration(seconds: 5));
    expect(find.byType(Authenticated), findsOneWidget);

    await tester.tap(find.byIcon(Icons.account_circle));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(find.byType(OwnProfilePage), findsOneWidget);
    await tester.tap(find.byIcon(Icons.account_circle));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    //test
    expect(find.byType(OwnProfilePage), findsOneWidget);
  });
}
