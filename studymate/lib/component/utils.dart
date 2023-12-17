import 'package:flutter/material.dart';

final GlobalKey<ScaffoldMessengerState> messengerKey =
    GlobalKey<ScaffoldMessengerState>();

class Utils {
  static GlobalKey<ScaffoldMessengerState> messengerKey =
      GlobalKey<ScaffoldMessengerState>();

  static showSnackBar(String? text) {
    if (text == null) return;
    final snackBar = SnackBar(
        content: Text(text),
        backgroundColor: Color.fromRGBO(255, 51, 51, 10),
        duration: Duration(seconds: 5));
    FocusManager.instance.primaryFocus?.unfocus();
    messengerKey.currentState!
      ..removeCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  showAlertDialog(BuildContext context, String title, String msg) {
    Widget okButton = TextButton(
      child: const Text("OK"),
      onPressed: () {
        Navigator.pop(context);
      },
    );

    AlertDialog alert = AlertDialog(
      title: Text(title),
      content: Text(msg),
      actions: [
        okButton,
      ],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
