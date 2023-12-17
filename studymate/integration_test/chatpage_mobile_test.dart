import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:studymate/main.dart' as app;
import 'package:studymate/screens/Authenticated/Chat/chat_msg.dart';
import 'package:studymate/screens/Authenticated/Chat/chats_page.dart';
import 'package:studymate/screens/Authenticated/authenticated.dart';

import 'package:studymate/screens/Login/login.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('Clicking on message - messages - smartphone', (tester) async {
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
    await tester.tap(find.byIcon(Icons.message));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(find.byType(ChatsPage), findsOneWidget);
    await tester.pumpAndSettle(const Duration(seconds: 2));
    await tester.tap(find.byKey(Key("chatElement")));
    await tester.pumpAndSettle(const Duration(seconds: 2));

    //test
    expect(find.byType(ChatMsg), findsOneWidget);
  });
  testWidgets('Entering text on searcbar - messages - smartphone',
      (tester) async {
    //setup
    app.main();
    //do
    await tester.pumpAndSettle(const Duration(seconds: 5));
    expect(find.byType(Authenticated), findsOneWidget);
    await tester.tap(find.byIcon(Icons.message));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(find.byType(ChatsPage), findsOneWidget);
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Find the text field using the specified key
    final textFieldFinder = find.byType(TextField);
    expect(textFieldFinder, findsOneWidget);

    final testText = 'Hello, World!';
    await tester.enterText(textFieldFinder, testText);
    await tester.pumpAndSettle(const Duration(seconds: 2));

    //test
    final enteredText =
        (tester.widget(textFieldFinder) as TextField).controller!.text;
    expect(enteredText, testText);
  });
  testWidgets(
      'Entering text and deleting text on searcbar - messages - smartphone',
      (tester) async {
    //setup
    app.main();
    //do
    await tester.pumpAndSettle(const Duration(seconds: 5));
    expect(find.byType(Authenticated), findsOneWidget);
    await tester.tap(find.byIcon(Icons.message));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(find.byType(ChatsPage), findsOneWidget);
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Find the text field using the specified key
    final textFieldFinder = find.byType(TextField);
    expect(textFieldFinder, findsOneWidget);

    final testText = 'Hello, World!';
    await tester.enterText(textFieldFinder, testText);
    await tester.pumpAndSettle(const Duration(seconds: 2));
    await tester.tap(find.byIcon(Icons.delete));
    await tester.pumpAndSettle(const Duration(seconds: 2));

    //test
    final enteredText =
        (tester.widget(textFieldFinder) as TextField).controller!.text;
    expect(enteredText, "");
  });
  testWidgets('Entering text - chat - messages - smartphone', (tester) async {
    //setup
    app.main();
    //do
    await tester.pumpAndSettle(const Duration(seconds: 5));
    expect(find.byType(Authenticated), findsOneWidget);
    await tester.tap(find.byIcon(Icons.message));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(find.byType(ChatsPage), findsOneWidget);
    await tester.pumpAndSettle(const Duration(seconds: 2));
    await tester.tap(find.byKey(Key("chatElement")));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(find.byType(ChatMsg), findsOneWidget);

    final textFieldFinder = find.byType(TextField);
    expect(textFieldFinder, findsOneWidget);

    final testText = 'Hello, World!';
    await tester.enterText(textFieldFinder, testText);
    await tester.pumpAndSettle(const Duration(seconds: 2));

    //test
    final enteredText =
        (tester.widget(textFieldFinder) as TextField).controller!.text;
    expect(enteredText, testText);
  });
  testWidgets(
      'Entering text and deleting text on searcbar - messages - smartphone',
      (tester) async {
    //setup
    app.main();
    //do
    await tester.pumpAndSettle(const Duration(seconds: 5));
    expect(find.byType(Authenticated), findsOneWidget);
    await tester.tap(find.byIcon(Icons.message));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(find.byType(ChatsPage), findsOneWidget);
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Find the text field using the specified key
    final textFieldFinder = find.byType(TextField);
    expect(textFieldFinder, findsOneWidget);

    final testText = 'Hello, World!';
    await tester.enterText(textFieldFinder, testText);
    await tester.pumpAndSettle(const Duration(seconds: 2));
    await tester.tap(find.byIcon(Icons.delete));
    await tester.pumpAndSettle(const Duration(seconds: 2));

    //test
    final enteredText =
        (tester.widget(textFieldFinder) as TextField).controller!.text;
    expect(enteredText, "");
  });
  testWidgets('Sending message - chat - messages - smartphone', (tester) async {
    //setup
    app.main();
    //do
    await tester.pumpAndSettle(const Duration(seconds: 5));
    expect(find.byType(Authenticated), findsOneWidget);
    await tester.tap(find.byIcon(Icons.message));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(find.byType(ChatsPage), findsOneWidget);
    await tester.pumpAndSettle(const Duration(seconds: 2));
    await tester.tap(find.byKey(Key("chatElement")));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(find.byType(ChatMsg), findsOneWidget);

    final textFieldFinder = find.byType(TextField);
    expect(textFieldFinder, findsOneWidget);

    final testText = 'Hello, World! test';
    await tester.enterText(textFieldFinder, testText);
    await tester.pumpAndSettle(const Duration(seconds: 2));
    await tester.tap(find.byIcon(Icons.send));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    //test

    expect(find.text('Hello, World! test'), findsOneWidget);
  });
  testWidgets('Sending more messages - chat - messages - smartphone',
      (tester) async {
    //setup
    app.main();
    //do
    await tester.pumpAndSettle(const Duration(seconds: 5));
    expect(find.byType(Authenticated), findsOneWidget);
    await tester.tap(find.byIcon(Icons.message));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(find.byType(ChatsPage), findsOneWidget);
    await tester.pumpAndSettle(const Duration(seconds: 2));
    await tester.tap(find.byKey(Key("chatElement")));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(find.byType(ChatMsg), findsOneWidget);

    final textFieldFinder = find.byType(TextField);
    expect(textFieldFinder, findsOneWidget);

    final testText = 'Hello, World! Two time test';
    await tester.enterText(textFieldFinder, testText);
    await tester.pumpAndSettle(const Duration(seconds: 2));
    await tester.tap(find.byIcon(Icons.send));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    await tester.enterText(textFieldFinder, testText);
    await tester.pumpAndSettle(const Duration(seconds: 2));
    await tester.tap(find.byIcon(Icons.send));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    //test

    expect(find.text('Hello, World! Two time test'), findsNWidgets(2));
  });
  testWidgets('Clicking attach - chat - messages - smartphone', (tester) async {
    //setup
    app.main();
    //do
    await tester.pumpAndSettle(const Duration(seconds: 5));
    expect(find.byType(Authenticated), findsOneWidget);
    await tester.tap(find.byIcon(Icons.message));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(find.byType(ChatsPage), findsOneWidget);
    await tester.pumpAndSettle(const Duration(seconds: 2));
    await tester.tap(find.byKey(Key("chatElement")));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(find.byType(ChatMsg), findsOneWidget);
    await tester.pumpAndSettle(const Duration(seconds: 2));
    await tester.tap(find.byIcon(Icons.attach_file));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    //test
    expect(find.byKey(Key('attachGPS')), findsOneWidget);
  });
  testWidgets('Sending current position - chat - messages - smartphone',
      (tester) async {
    //setup
    app.main();
    //do
    
    await tester.pumpAndSettle(const Duration(seconds: 5));
    expect(find.byType(Authenticated), findsOneWidget);
    await tester.tap(find.byIcon(Icons.message));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(find.byType(ChatsPage), findsOneWidget);
    await tester.pumpAndSettle(const Duration(seconds: 2));
    await tester.tap(find.byKey(Key("chatElement")));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(find.byType(ChatMsg), findsOneWidget);
    await tester.pumpAndSettle(const Duration(seconds: 2));
    await tester.tap(find.byIcon(Icons.attach_file));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(find.byKey(Key('attachGPS')), findsOneWidget);

    await tester.tap(find.byIcon(Icons.my_location_outlined));
    await tester.pumpAndSettle(const Duration(seconds: 5));

    //test
    expect(find.byIcon(Icons.map_rounded), findsOneWidget);
  });
  testWidgets('Return messages - chat - messages - smartphone',
      (tester) async {
    //setup
    app.main();
    //do
    await tester.pumpAndSettle(const Duration(seconds: 5));
    expect(find.byType(Authenticated), findsOneWidget);
    await tester.tap(find.byIcon(Icons.message));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(find.byType(ChatsPage), findsOneWidget);
    await tester.pumpAndSettle(const Duration(seconds: 2));
    await tester.tap(find.byKey(Key("chatElement")));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(find.byType(ChatMsg), findsOneWidget);
    await tester.pumpAndSettle(const Duration(seconds: 2));
    await tester.tap(find.byIcon(Icons.arrow_back_ios));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    //test
    expect(find.byType(ChatsPage), findsOneWidget);
  });
}
