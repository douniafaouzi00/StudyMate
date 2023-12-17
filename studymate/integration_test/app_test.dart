import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:studymate/main.dart' as app;
import 'package:studymate/screens/Authenticated/authenticated.dart';
import 'package:studymate/screens/Authenticated/notification/notification_page.dart';
import 'package:studymate/screens/Login/login.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('On Boarding 2 time Next button test', (tester) async {
    //setup
    app.main();
    //do
    await tester.pumpAndSettle(const Duration(seconds: 5));
    final button = find.byKey(Key('nextOnBoardingVertical'));

    expect(button, findsOneWidget);
    await tester.tap(button);
    await tester.pumpAndSettle(const Duration(seconds: 2));
    await tester.tap(button);
    await tester.pumpAndSettle(const Duration(seconds: 2));

    final buttonStart = find.byKey(Key('startOnBoardingVertical'));
    expect(buttonStart, findsOneWidget);
    await tester.tap(buttonStart);
    await tester.pumpAndSettle(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    await tester.pumpAndSettle(const Duration(seconds: 2));

    //test
    expect(find.byType(Login), findsOneWidget);
  });
  testWidgets('Login with currect credential', (tester) async {
    //setup
    app.main();
    //do
    await tester.pumpAndSettle(const Duration(seconds: 5));

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

    //test
    expect(find.byType(Authenticated), findsOneWidget);
  });
  testWidgets('Opening notification page', (tester) async {
    //setup
    app.main();
    //do
    await tester.pumpAndSettle(const Duration(seconds: 2));

    final button = find.byKey(Key('notificationButton'));
    expect(button, findsOneWidget);
    await tester.tap(button);
    await tester.pumpAndSettle(const Duration(seconds: 2));

    //test
    expect(find.byType(NotificationPage), findsOneWidget);
  });
}
