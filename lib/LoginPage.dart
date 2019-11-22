import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:food_manager/AppUtils.dart';
import 'package:food_manager/main.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:wave/config.dart';
import 'package:wave/wave.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _loginFormKey = GlobalKey<FormState>();
  TextEditingController emailInputController;
  TextEditingController pwdInputController;
  ProgressDialog pr;

  @override
  initState() {
    pr = new ProgressDialog(context,
        type: ProgressDialogType.Normal, isDismissible: false, showLogs: false);
    pr.style(
      message: 'Please wait...',
    );
    emailInputController = new TextEditingController();
    pwdInputController = new TextEditingController();
    super.initState();
  }

  showProgressDialog(bool isShow) {
    if (isShow) {
      pr.show();
    } else {
      pr.hide();
    }
  }

  String emailValidator(String value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(value)) {
      return 'Email format is invalid';
    } else {
      return null;
    }
  }

  String pwdValidator(String value) {
    if (value.length < 8) {
      return 'Password must be longer than 8 characters';
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: Stack(
            children: <Widget>[
              WaveWidget(
                config: CustomConfig(
                  gradients: [
                    [Colors.white24, Colors.white38],
                    [Colors.white38, Colors.white30],
                    [Colors.white70, Colors.white60],
                    [Colors.white, Colors.white70],
                  ],
                  durations: [35000, 19440, 10800, 6000],
                  heightPercentages: [0.13, 0.15, 0.18, 0.20],
                  blur: MaskFilter.blur(BlurStyle.solid, 10),
                  gradientBegin: Alignment.bottomLeft,
                  gradientEnd: Alignment.topRight,
                ),
                duration: 5000,
                heightPercentange: 0.25,
                wavePhase: 10,
                waveAmplitude: 0,
                backgroundColor: Colors.blue,
                size: Size(double.infinity, double.infinity),
              ),
              SingleChildScrollView(
                child: Container(
                    padding: const EdgeInsets.all(20.0),
                    child: Form(
                      key: _loginFormKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          Text(
                            "Login".toUpperCase(),
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 20),
                          ),
                          Container(
                            height: screenSize.height * 0.8,
                            width: screenSize.width,
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                TextFormField(
                                  decoration: InputDecoration(
                                      labelText: 'Email*',
                                      hintText: "john.doe@gmail.com"),
                                  controller: emailInputController,
                                  keyboardType: TextInputType.emailAddress,
                                  validator: emailValidator,
                                ),
                                TextFormField(
                                  decoration: InputDecoration(
                                      labelText: 'Password*',
                                      hintText: "********"),
                                  controller: pwdInputController,
                                  obscureText: true,
                                  validator: pwdValidator,
                                ),
                                SizedBox(
                                  height: 30,
                                ),
                                RaisedButton(
                                  elevation: 10,
                                  shape: StadiumBorder(),
                                  child: Text("Login"),
                                  color: Theme.of(context).primaryColor,
                                  textColor: Colors.white,
                                  onPressed: () {
                                    if (_loginFormKey.currentState.validate()) {
                                      showProgressDialog(true);
                                      FirebaseAuth.instance
                                          .signInWithEmailAndPassword(
                                              email: emailInputController.text,
                                              password: pwdInputController.text)
                                          .then((currentUser) {
                                        showProgressDialog(true);
                                        Firestore.instance
                                            .collection("users")
                                            .document(currentUser.user.uid)
                                            .get()
                                            .then((DocumentSnapshot result) {
                                          showProgressDialog(false);
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => MyHomePage(
                                                title: ('Welcome Back ' +
                                                        result.data["fname"])
                                                    .toUpperCase(),
                                                uid: currentUser.user.uid,
                                              ),
                                            ),
                                          );
                                        }).catchError((err) {
                                          showProgressDialog(false);
                                          print(err);
                                          AppUtils.showToast(err.message,
                                              Colors.red, Colors.white);
                                        });
                                      }).catchError((err) {
                                        showProgressDialog(false);
                                        print(err);
                                        AppUtils.showToast(err.message,
                                            Colors.red, Colors.white);
                                      });
                                    }
                                  },
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Text("Don't have an account yet?"),
                                SizedBox(
                                  height: 2,
                                ),
                                FlatButton(
                                  child: Text("Register here!"),
                                  onPressed: () {
                                    Navigator.pushNamed(context, "/register");
                                  },
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    )),
              )
            ],
          ),
        ));
  }
}
