import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:studymate/component/utils.dart';
import 'package:studymate/main.dart';
import 'package:email_validator/email_validator.dart';
import 'package:studymate/screens/Login/login.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class Reset extends StatefulWidget {
  const Reset({super.key});

  @override
  _ResetState createState() => _ResetState();
}

class _ResetState extends State<Reset> {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    double h = size.height;
    double w = size.width;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Form(
          key: formKey,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      AppLocalizations.of(context)!.resetPswTitle,
                      style: TextStyle(
                        fontFamily: "Crimson Pro",
                        fontWeight: FontWeight.bold,
                        fontSize: (w > 490 && h > 720) ? 60 : 35,
                        color: Color.fromARGB(255, 233, 64, 87),
                      ),
                    ),
                    SizedBox(height: 10),
                    Padding(
                      padding: EdgeInsets.only(top: 10),
                      child: Text(
                        AppLocalizations.of(context)!.resetPswSubTitle,
                        style: TextStyle(
                          fontFamily: "Crimson Pro",
                          fontSize: (w > 490 && h > 720) ? 25 : 16,
                          color: Color.fromARGB(255, 0, 0, 0),
                        ),
                      ),
                    ),
                    SizedBox(height: size.height * 0.03),
                    Container(
                      width: w * 0.8,
                      alignment: Alignment.center,
                      child: TextFormField(
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
                    Container(
                      margin: EdgeInsets.only(
                          top: 0.03 * h, left: 0.02 * w, right: 0.02 * w),
                      height: 0.08 * h,
                      width: 0.8 * w,
                      child: ElevatedButton(
                          onPressed: resetPsw,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 233, 64, 87),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            AppLocalizations.of(context)!.resetPswTitle,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: (w > 490 && h > 720) ? 30 : 16,
                              color: Color.fromARGB(255, 255, 255, 255),
                            ),
                          )),
                    ),
                    Padding(
                      padding: EdgeInsets.all(15.0),
                      child: RichText(
                          text: TextSpan(
                              style: TextStyle(
                                  fontSize: (w > 490 && h > 720) ? 20 : 12,
                                  color: Color.fromARGB(156, 65, 62, 88)),
                              text: AppLocalizations.of(context)!.pswReceived,
                              children: [
                            TextSpan(
                              recognizer: TapGestureRecognizer()
                                ..onTap = () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => Login())),
                              text: ' '+AppLocalizations.of(context)!.login,
                              style: TextStyle(
                                  fontSize: (w > 490 && h > 720) ? 20 : 12,
                                  color: Color.fromARGB(255, 233, 64, 87)),
                            )
                          ])),
                    ),
                  ]),
            ],
          ),
        ),
      ),
    );
  }

  Future resetPsw() async {
    final isValid = formKey.currentState!.validate();
    if (!isValid) return;
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()));
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: emailController.text.trim());
      navigatorKey.currentState!.popUntil((route) => route.isFirst);
    } on FirebaseAuthException catch (e) {
      Utils.showSnackBar(e.message);
      Navigator.of(context).pop();
    }
  }
}
