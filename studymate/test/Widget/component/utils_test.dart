import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studymate/component/utils.dart';

void main() {

  testWidgets('showAlertDialog() should show an AlertDialog', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Builder(
        builder: (BuildContext context) {
          return ElevatedButton(
            onPressed: () {
              Utils().showAlertDialog(context, 'Test Title', 'Test Message');
            },
            child: const Text('Show AlertDialog'),
          );
        },
      ),
    ));

    await tester.tap(find.text('Show AlertDialog'));
    await tester.pumpAndSettle();

    expect(find.text('Test Title'), findsOneWidget);
    expect(find.text('Test Message'), findsOneWidget);
    expect(find.text('OK'), findsOneWidget);
  });
}