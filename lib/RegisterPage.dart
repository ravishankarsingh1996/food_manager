import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:food_manager/AppUtils.dart';
import 'package:food_manager/main.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:wave/config.dart';
import 'package:wave/wave.dart';

import 'AppConstants.dart';

class RegisterPage extends StatefulWidget {
  RegisterPage({Key key}) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final GlobalKey<FormState> _registerFormKey = GlobalKey<FormState>();
  TextEditingController firstNameInputController;
  TextEditingController lastNameInputController;
  TextEditingController emailInputController;
  TextEditingController employeeIdInputController;
  TextEditingController pwdInputController;
  TextEditingController confirmPwdInputController;
  ProgressDialog pr;

  @override
  initState() {
    super.initState();
    pr = new ProgressDialog(context,
        type: ProgressDialogType.Normal, isDismissible: false, showLogs: false);
    pr.style(
      message: 'Please wait...',
    );
    firstNameInputController = new TextEditingController();
    lastNameInputController = new TextEditingController();
    emailInputController = new TextEditingController();
    employeeIdInputController = new TextEditingController();
    pwdInputController = new TextEditingController();
    confirmPwdInputController = new TextEditingController();

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
      return 'Please enter a valid email.';
    } else {
      return null;
    }
  }

  String pwdValidator(String value) {
    if (value.length < 8) {
      return 'Password must be longer than 8 characters.';
    } else {
      return null;
    }
  }

  String employeeIdValidator(String value) {
    if (value.length != 6) {
      return 'This is not a valid employee ID';
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    return Scaffold(
//      resizeToAvoidBottomInset: false,
        body: SafeArea(
      child: Stack(
        children: <Widget>[
          Container(
            height: screenSize.height,
            width: screenSize.width,
            child: WaveWidget(
              config: CustomConfig(
                gradients: [
                  [Colors.white24, Colors.white38],
                  [Colors.white38, Colors.white30],
                  [Colors.white70, Colors.white60],
                  [Colors.white, Colors.white70],
                ],
                durations: [35000, 19440, 10800, 6000],
                heightPercentages: [0.10, 0.12, 0.15, 0.17],
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
          ),
          Container(
              height: screenSize.height,
              width: screenSize.width,
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Text(
                    "Register".toUpperCase(),
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 20),
                  ),
                  Expanded(
                    child: Container(
                      width: screenSize.width,
                      margin: EdgeInsets.only(top: 150),
                      child: SingleChildScrollView(
                        child: Form(
                          key: _registerFormKey,
                          child: Column(
                            children: <Widget>[
                              TextFormField(
                                decoration: InputDecoration(
                                    labelText: 'First Name*', hintText: "John"),
                                controller: firstNameInputController,
                                validator: (value) {
                                  if(value.length == 0 ){
                                    return "Please enter your first name.";
                                  }else if (value.length < 3) {
                                    return "Please enter a valid first name.";
                                  }
                                },
                              ),
                              TextFormField(
                                  decoration: InputDecoration(
                                      labelText: 'Last Name*', hintText: "Doe"),
                                  controller: lastNameInputController,
                                  validator: (value) {
                                    if(value.length == 0 ){
                                      return "Please enter your last name.";
                                    }else if (value.length < 3) {
                                      return "Please enter a valid last name.";
                                    }
                                  }),
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
                                    labelText: 'EmployeeId*', hintText: "MOB001"),
                                controller: employeeIdInputController,
                                keyboardType: TextInputType.text,
                                validator: employeeIdValidator,
                              ),
                              TextFormField(
                                decoration: InputDecoration(
                                    labelText: 'Password*', hintText: "********"),
                                controller: pwdInputController,
                                obscureText: true,
                                validator: pwdValidator,
                              ),
                              TextFormField(
                                decoration: InputDecoration(
                                    labelText: 'Confirm Password*',
                                    hintText: "********"),
                                controller: confirmPwdInputController,
                                obscureText: true,
                                validator: pwdValidator,
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              RaisedButton(
                                shape: StadiumBorder(),
                                child: Text("Register"),
                                color: Theme.of(context).primaryColor,
                                textColor: Colors.white,
                                onPressed: onRegisterClicked,
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Text("Already have an account?"),
                              SizedBox(
                                height: 2,
                              ),
                              FlatButton(
                                child: Text("Login here!"),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ))
        ],
      ),
    ));
  }

  void onRegisterClicked() async {
    {
      if (_registerFormKey.currentState.validate()) {
        if (pwdInputController.text == confirmPwdInputController.text) {
          showProgressDialog(true);
          FirebaseAuth.instance
              .createUserWithEmailAndPassword(
                  email: emailInputController.text,
                  password: pwdInputController.text)
              .then((currentUser) {
            showProgressDialog(true);
            try {
              currentUser.user.sendEmailVerification();
            } catch (e) {
              showProgressDialog(false);
              print("An error occured while trying to send email verification");
              AppUtils.showToast(
                  'An error occured while trying to send email verification',
                  Colors.red,
                  Colors.white);
              print(e.message);
            }
            Firestore.instance
                .collection(AppConstants.DB_KEY_USER)
                .document(currentUser.user.uid)
                .setData({
              AppConstants.KEY_USER_ID: currentUser.user.uid,
              AppConstants.KEY_FIRST_NAME: firstNameInputController.text,
              AppConstants.KEY_LAST_NAME: lastNameInputController.text,
              AppConstants.KEY_EMAIL: emailInputController.text,
              AppConstants.KEY_EMPLOYEE_ID: employeeIdInputController.text.toUpperCase(),
              AppConstants.KEY_IS_VENDOR: false,
            }).then((result) {
              showProgressDialog(false);
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (context) => MyHomePage(
                            title: ('Welcome back ' +
                                    firstNameInputController.text)
                                .toUpperCase(),
                            uid: currentUser.user.uid,
                          )),
                  (_) => false);
              firstNameInputController.clear();
              lastNameInputController.clear();
              emailInputController.clear();
              employeeIdInputController.clear();
              pwdInputController.clear();
              confirmPwdInputController.clear();
            }).catchError((err) {
              showProgressDialog(false);
              print(err);
              AppUtils.showToast(err.message, Colors.red, Colors.white);
            });
          }).catchError((err) {
            showProgressDialog(false);
            print(err);
            AppUtils.showToast(err.message, Colors.red, Colors.white);
          });
        } else {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text("Error"),
                  content: Text("The passwords do not match"),
                  actions: <Widget>[
                    FlatButton(
                      child: Text("Close"),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    )
                  ],
                );
              });
        }
      }
    }
  }
}
