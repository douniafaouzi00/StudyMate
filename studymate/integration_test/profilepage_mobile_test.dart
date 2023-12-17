import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:studymate/main.dart' as app;
import 'package:studymate/screens/Authenticated/authenticated.dart';

import 'package:studymate/screens/Authenticated/profilePage/components/edit_timeslots_page.dart';
import 'package:studymate/screens/Authenticated/profilePage/components/own_lessons_profile_page.dart';
import 'package:studymate/screens/Authenticated/profilePage/components/saved_lessons_profile_page.dart';
import 'package:studymate/screens/Authenticated/profilePage/own_profile_page.dart';
import 'package:studymate/screens/Login/login.dart';
import 'package:studymate/screens/Authenticated/profilePage/components/updateInterest.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('Clicking on own lessons - profile page - smartphone',
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

    await tester.tap(find.byIcon(Icons.account_circle));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(find.byType(OwnProfilePage), findsOneWidget);
    await tester.tap(find.text('Own lessons'));
    await tester.pumpAndSettle(const Duration(seconds: 2));

    //test
    expect(find.byType(OwnLessonsProfilePage), findsOneWidget);
  });
  testWidgets('Clicking on saved lessons - profile page - smartphone',
      (tester) async {
    //setup
    app.main();
    //do
    await tester.pumpAndSettle(const Duration(seconds: 5));
    expect(find.byType(Authenticated), findsOneWidget);

    await tester.tap(find.byIcon(Icons.account_circle));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(find.byType(OwnProfilePage), findsOneWidget);
    await tester.tap(find.byIcon(Icons.favorite));
    await tester.pumpAndSettle(const Duration(seconds: 2));

    //test
    expect(find.byType(SavedLessonsProfilePage), findsOneWidget);
  });
  testWidgets('Clicking on credits hours lessons - profile page - smartphone',
      (tester) async {
    //setup
    app.main();
    //do
    await tester.pumpAndSettle(const Duration(seconds: 5));
    expect(find.byType(Authenticated), findsOneWidget);

    await tester.tap(find.byIcon(Icons.account_circle));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(find.byType(OwnProfilePage), findsOneWidget);
    await tester.tap(find.byIcon(Icons.av_timer));
    await tester.pumpAndSettle(const Duration(seconds: 2));

    //test
    expect(find.byType(AlertDialog), findsOneWidget);
  });
  testWidgets('Clicking on edit profile image - profile page - smartphone',
      (tester) async {
    //setup
    app.main();
    //do
    await tester.pumpAndSettle(const Duration(seconds: 5));
    expect(find.byType(Authenticated), findsOneWidget);

    await tester.tap(find.byIcon(Icons.account_circle));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(find.byType(OwnProfilePage), findsOneWidget);
    await tester.tap(find.byIcon(Icons.mode_edit_outline));
    await tester.pumpAndSettle(const Duration(seconds: 2));

    //test
    expect(find.byKey(Key('modalEdicPic')), findsOneWidget);
  });
  testWidgets('Clicking on menu - profile page - smartphone', (tester) async {
    //setup
    app.main();
    //do
    await tester.pumpAndSettle(const Duration(seconds: 5));
    expect(find.byType(Authenticated), findsOneWidget);

    await tester.tap(find.byIcon(Icons.account_circle));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(find.byType(OwnProfilePage), findsOneWidget);
    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle(const Duration(seconds: 2));

    //test
    expect(find.byKey(Key("menuModal")), findsOneWidget);
  });
  testWidgets('Clicking on edit preferences - menu - profile page - smartphone',
      (tester) async {
    //setup
    app.main();
    //do
    await tester.pumpAndSettle(const Duration(seconds: 5));
    expect(find.byType(Authenticated), findsOneWidget);

    await tester.tap(find.byIcon(Icons.account_circle));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(find.byType(OwnProfilePage), findsOneWidget);
    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(find.byKey(Key("menuModal")), findsOneWidget);
    await tester.pumpAndSettle(const Duration(seconds: 2));
    await tester.tap(find.text("Edit preferences"));
    await tester.pumpAndSettle(const Duration(seconds: 2));

    //test
    expect(find.byType(updateInterest), findsOneWidget);
  });
  testWidgets('Clicking on edit timeslots - menu - profile page - smartphone',
      (tester) async {
    //setup
    app.main();
    //do
    await tester.pumpAndSettle(const Duration(seconds: 5));
    expect(find.byType(Authenticated), findsOneWidget);

    await tester.tap(find.byIcon(Icons.account_circle));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(find.byType(OwnProfilePage), findsOneWidget);
    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(find.byKey(Key("menuModal")), findsOneWidget);
    await tester.pumpAndSettle(const Duration(seconds: 2));
    await tester.tap(find.text("Edit timeslots"));
    await tester.pumpAndSettle(const Duration(seconds: 2));

    //test
    expect(find.byType(EditTimeslotsPage), findsOneWidget);
  });
  testWidgets('Clicking on logout - menu - profile page - smartphone',
      (tester) async {
    //setup
    app.main();
    //do
    await tester.pumpAndSettle(const Duration(seconds: 5));
    expect(find.byType(Authenticated), findsOneWidget);

    await tester.tap(find.byIcon(Icons.account_circle));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(find.byType(OwnProfilePage), findsOneWidget);
    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(find.byKey(Key("menuModal")), findsOneWidget);
    await tester.pumpAndSettle(const Duration(seconds: 2));
    await tester.tap(find.text("Logout"));
    await tester.pumpAndSettle(const Duration(seconds: 5));

    //test
    expect(find.byType(Login), findsOneWidget);
  });
}
