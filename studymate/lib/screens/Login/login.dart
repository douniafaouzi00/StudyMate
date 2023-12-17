import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:studymate/component/utils.dart';
import 'package:email_validator/email_validator.dart';
import 'package:studymate/screens/Login/register.dart';
import 'package:studymate/screens/Login/reset.dart';

import '../../provider/authentication.dart';
import '../Authenticated/authenticated.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool _isSigningIn = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    double h = size.height;
    double w = size.width;

    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: ListView(
          children: <Widget>[
            Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    height: h > w
                        ? w * 0.3
                        : (h > 720 && w > 490)
                            ? 0.1 * h
                            : 0,
                  ),
                  Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                    Text(
                      key: const Key('titleLogin'),
                      AppLocalizations.of(context)!.login,
                      style: TextStyle(
                        fontFamily: "Crimson Pro",
                        fontWeight: FontWeight.bold,
                        fontSize: (w > 490 && h > 720) ? 60 : 35,
                        color: Color.fromARGB(255, 233, 64, 87),
                      ),
                    ),
                    Container(
                      alignment: Alignment.center,
                      width: 0.8 * w,
                      child: TextFormField(
                        key: const Key('emailFieldLogin'),
                        controller: emailController,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)!.email,
                          labelStyle: TextStyle(
                              fontSize: (w > 490 && h > 720) ? 25 : 14),
                          hintStyle: TextStyle(
                              fontSize: (w > 490 && h > 720) ? 16 : 12),
                          errorStyle: TextStyle(
                              fontSize: (w > 490 && h > 720) ? 16 : 12),
                        ),
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (email) =>
                            email != null && !EmailValidator.validate(email)
                                ? AppLocalizations.of(context)!.validEmail
                                : null,
                        style:
                            TextStyle(fontSize: (w > 490 && h > 720) ? 25 : 14),
                      ),
                    ),
                    //SizedBox(height: size.height * 0.001),
                    Container(
                      alignment: Alignment.center,
                      width: 0.8 * w,
                      child: TextFormField(
                        key: const Key('passwordFieldLogin'),
                        controller: passwordController,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)!.password,
                          labelStyle: TextStyle(
                              fontSize: (w > 490 && h > 720) ? 25 : 14),
                          hintStyle: TextStyle(
                              fontSize: (w > 490 && h > 720) ? 16 : 12),
                          errorStyle: TextStyle(
                              fontSize: (w > 490 && h > 720) ? 16 : 12),
                        ),
                        obscureText: true,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (value) => value != null && value.isEmpty
                            ? AppLocalizations.of(context)!.enterPassword
                            : null,
                        style:
                            TextStyle(fontSize: (w > 490 && h > 720) ? 25 : 14),
                      ),
                    ),
                    Container(
                      alignment: Alignment.centerRight,
                      margin: EdgeInsets.only(
                          right: (w > 490 && h > 720) ? 80 : 50, top: 10),
                      child: GestureDetector(
                        key: const Key('forgotPwdGestureLogin'),
                        onTap: () => {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) => Reset())),
                        },
                        child: Text(
                          AppLocalizations.of(context)!.forgotPassword,
                          style: TextStyle(
                              fontSize: (w > 490 && h > 720) ? 20 : 12,
                              color: Color.fromARGB(156, 65, 62, 88)),
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(
                          top: 0.03 * h, left: 0.03 * h, right: 0.03 * h),
                      height: 0.08 * h,
                      width: 0.8 * w,
                      child: ElevatedButton(
                          key: const Key('loginButton'),
                          onPressed: signIn,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 233, 64, 87),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            AppLocalizations.of(context)!.loginCaps,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: (w > 490 && h > 720) ? 30 : 16,
                              color: Color.fromARGB(255, 255, 255, 255),
                            ),
                          )),
                    ),
                    Container(
                      alignment: Alignment.centerRight,
                      margin: EdgeInsets.only(
                          right: (w > 490 && h > 720) ? 80 : 50, top: 10),
                      child: RichText(
                          key: const Key('noAccountQuestionLogin'),
                          text: TextSpan(
                              style: TextStyle(
                                  fontSize: (w > 490 && h > 720) ? 20 : 12,
                                  color: Color.fromARGB(156, 65, 62, 88)),
                              text: AppLocalizations.of(context)!
                                  .noAccountQustion,
                              children: [
                                TextSpan(
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => Register())),
                                  text: ' ' +
                                      AppLocalizations.of(context)!.signUp,
                                  style: TextStyle(
                                      fontSize: (w > 490 && h > 720) ? 20 : 12,
                                      color: Color.fromARGB(255, 233, 64, 87)),
                                )
                              ])),
                    ),
                    SizedBox(
                      height: 0.03 * h,
                    )
                  ]),
                  Column(
                    children: [
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              height: 1,
                              width: 0.2 * w,
                              margin: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: Color.fromARGB(156, 105, 102, 121),
                              ),
                            ),
                            Text(
                              AppLocalizations.of(context)!.orSignGoogle,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: (w > 490 && h > 720) ? 19 : 13,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(156, 105, 102, 121),
                              ),
                            ),
                            Container(
                              height: 1,
                              width: 0.2 * w,
                              margin: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: Color.fromARGB(156, 105, 102, 121),
                              ),
                            ),
                          ]),
                      SizedBox(
                        height: 10,
                      ),
                      _isSigningIn
                          ? const CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  Color.fromARGB(255, 233, 64, 87)),
                            )
                          : GestureDetector(
                              key: const Key('buttonSignUpGoogle'),
                              onTap: () {
                                setState(() {
                                  _isSigningIn = true;
                                });
                                Authentication.signInWithGoogle(
                                    context: context);
                                setState(() {
                                  _isSigningIn = false;
                                });
                              },
                              child: Container(
                                  margin: EdgeInsets.all(0.03 * h),
                                  height: 0.08 * h,
                                  width: 0.8 * w,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    color: Colors.white,
                                    boxShadow: const [
                                      BoxShadow(
                                          color: Color.fromARGB(
                                              156, 105, 102, 121),
                                          spreadRadius: 2),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        "assets/login/google.png",
                                        height: 0.04 * h,
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Text(
                                        AppLocalizations.of(context)!
                                            .buttonSignUpGoogle,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize:
                                                (w > 490 && h > 720) ? 25 : 15,
                                            color: Color.fromARGB(
                                                156, 105, 102, 121)),
                                      )
                                    ],
                                  )),
                            )
                    ],
                  ),
                ]),
          ],
        ));
  }

  Future signIn() async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()));
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim());
      //navigatorKey.currentState!.popUntil((route) => route.isFirst);
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => Authenticated()));
    } on FirebaseAuthException catch (e) {
      Utils.showSnackBar(e.message);
      Navigator.of(context).pop();
    }
  }
}
