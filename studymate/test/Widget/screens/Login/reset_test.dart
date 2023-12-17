import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studymate/l10n/l10n.dart';
import 'package:studymate/screens/Login/reset.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

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

  group('Reset Widget Tests', () {
    testWidgets('Reset widget renders correctly', (WidgetTester tester) async {
      await pumpWidgetLoc(tester, Reset());

      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(TextFormField), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('Reset widget renders title and subtitle',
        (WidgetTester tester) async {
      await pumpWidgetLoc(tester, Reset());

      expect(find.text('Reset password'), findsNWidgets(2));
      expect(
          find.text('Receive an email to reset your password.'), findsOneWidget);
    });

    testWidgets('Reset widget renders email input field',
        (WidgetTester tester) async {
      await pumpWidgetLoc(tester, Reset());

      expect(find.byType(TextFormField), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
    });

    testWidgets('Reset widget renders reset button',
        (WidgetTester tester) async {
      await pumpWidgetLoc(tester, Reset());

      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(find.text('Reset password'), findsNWidgets(2));
    });


    testWidgets('Reset widget shows error message for invalid email',
        (WidgetTester tester) async {
      await pumpWidgetLoc(tester, Reset());

      await tester.enterText(find.byType(TextFormField), 'invalid_email');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(find.text('Enter a valid email'), findsOneWidget);
    });

  });
}
