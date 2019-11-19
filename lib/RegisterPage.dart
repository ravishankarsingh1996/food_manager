import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:food_manager/AppUtils.dart';
import 'package:food_manager/main.dart';

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

  @override
  initState() {
    firstNameInputController = new TextEditingController();
    lastNameInputController = new TextEditingController();
    emailInputController = new TextEditingController();
    employeeIdInputController = new TextEditingController();
    pwdInputController = new TextEditingController();
    confirmPwdInputController = new TextEditingController();
    super.initState();
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

  String employeeIdValidator(String value) {
    if (value.length != 6) {
      return 'This is not a valid employee ID';
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Register"),
        ),
        body: Container(
            padding: const EdgeInsets.all(20.0),
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
                      if (value.length < 3) {
                        return "Please enter a valid first name.";
                      }
                    },
                  ),
                  TextFormField(
                      decoration: InputDecoration(
                          labelText: 'Last Name*', hintText: "Doe"),
                      controller: lastNameInputController,
                      validator: (value) {
                        if (value.length < 3) {
                          return "Please enter a valid last name.";
                        }
                      }),
                  TextFormField(
                    decoration: InputDecoration(
                        labelText: 'Email*', hintText: "john.doe@gmail.com"),
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
                        labelText: 'Confirm Password*', hintText: "********"),
                    controller: confirmPwdInputController,
                    obscureText: true,
                    validator: pwdValidator,
                  ),
                  RaisedButton(
                    child: Text("Register"),
                    color: Theme.of(context).primaryColor,
                    textColor: Colors.white,
                    onPressed: onRegisterClicked,
                  ),
                  Text("Already have an account?"),
                  FlatButton(
                    child: Text("Login here!"),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  )
                ],
              ),
            ))));
  }

  void onRegisterClicked() async {
    {
      if (_registerFormKey.currentState.validate()) {
        if (pwdInputController.text == confirmPwdInputController.text) {
          FirebaseAuth.instance
              .createUserWithEmailAndPassword(
                  email: emailInputController.text,
                  password: pwdInputController.text)
              .then((currentUser) {
            try {
              currentUser.user.sendEmailVerification();
            } catch (e) {
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
              AppConstants.KEY_EMPLOYEE_ID: employeeIdInputController.text,
              AppConstants.KEY_IS_VENDOR: false,
            }).then((result) {
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (context) => MyHomePage(
                            title:
                                'Welcome back ' + firstNameInputController.text,
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
              print(err);
              AppUtils.showToast(err.message, Colors.red, Colors.white);
            });
          }).catchError((err) {
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
