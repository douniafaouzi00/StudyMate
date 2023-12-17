import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studymate/component/utils.dart';
import 'package:studymate/provider/AuthService.dart';
import 'package:studymate/screens/Login/login.dart';
import 'package:studymate/screens/OnBoard/onBoard.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


import 'l10n/l10n.dart';

int? isviewed;
void main() async {
  //WidgetsFlutterBinding.ensureInitialized();
  //SystemChrome.setPreferredOrientations(
  //    [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  isviewed = prefs.getInt('onBoard');
  runApp(MyApp());
}

final navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: Utils.messengerKey,
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'StudyMate',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 255, 81, 69)),
      ),
      supportedLocales: L10n.all,
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate

      ],
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Scomething went wrong!'));
          } else if (snapshot.hasData) {
            return AuthService();
          } else if (isviewed != 0) {
            return OnBoard();
          } else {
            return Login();
          }
        },
      ),
    );
  }
}
