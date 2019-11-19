import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:food_manager/LoginPage.dart';
import 'package:food_manager/Record.dart';
import 'package:food_manager/RegisterPage.dart';
import 'package:food_manager/SplashPage.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'AppConstants.dart';
import 'AppUtils.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Food Manager',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: SplashPage(),
        routes: <String, WidgetBuilder>{
          '/home': (BuildContext context) => MyHomePage(title: 'Home'),
          '/login': (BuildContext context) => LoginPage(),
          '/register': (BuildContext context) => RegisterPage(),
        });
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title, this.uid}) : super(key: key);

  final String title;
  final String uid;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _scanBarcode = "";
  bool _isEmailVerified = false;
  bool _isVendor = false;
  List userList = new List();

  Future<void> scanBarcodeNormal() async {
    String barcodeScanRes;
    // Platform messages may fail, so we use a try/catch PlatformException.

    barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
        "#42f5ef", "Cancel", true, ScanMode.QR);
    print(barcodeScanRes);

    setState(() {
      Timestamp timestamp = Timestamp.now();
      var date = new DateTime.fromMillisecondsSinceEpoch(
          timestamp.millisecondsSinceEpoch);
      var formatter = new DateFormat('yyyy-MM-dd');
      String formatted = formatter.format(date);
      print(formatted);
      AppUtils.showToast(formatted, Colors.blue, Colors.white);
      Firestore.instance
          .collection(AppConstants.DB_KEY_BOOKING_DATA)
          .document(formatted)
          .setData({
        AppConstants.KEY_USER_ID: formatted,
//        AppConstants.KEY_FIRST_NAME: firstNameInputController.text,
//        AppConstants.KEY_LAST_NAME: lastNameInputController.text,
//        AppConstants.KEY_EMAIL: emailInputController.text,
//        AppConstants.KEY_EMPLOYEE_ID: employeeIdInputController.text,
//        AppConstants.KEY_IS_VENDOR: false,
      }).then((result) {

      });
      _scanBarcode = barcodeScanRes;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrentUserData();
    getTodaysBookingList();
    getUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          IconButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => LoginPage(),
                ),
              );
            },
            icon: Icon(Icons.exit_to_app),
          )
        ],
      ),
      body: Center(
        child: _isVendor
            ? _getVendorList()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: _isEmailVerified
                    ? _getVerifiedUserUI()
                    : _getUnVerifiedUserUI(),
              ),
      ),
      floatingActionButton: _isVendor
          ? FloatingActionButton(
              onPressed: scanBarcodeNormal,
              tooltip: 'Scan',
              child: Icon(Icons.search),
            )
          : Container(),
    );
  }

  void getUserData() async {
    QuerySnapshot querySnapshot = await Firestore.instance
        .collection(AppConstants.DB_KEY_USER)
        .getDocuments();

    DocumentSnapshot result = await Firestore.instance
        .collection(AppConstants.DB_KEY_USER)
        .document(widget.uid)
        .get();
    if (result != null) {
      setState(() {
        _isVendor = result.data[AppConstants.KEY_IS_VENDOR];
        if (_isVendor) {
          userList = querySnapshot.documents;
          Record record = Record.fromSnapshot(userList[0]);
          AppUtils.showToast(record.email, Colors.blue, Colors.white);
//          userList = usersRef.
        }
      });
    }
  }

  _getVerifiedUserUI() {
    return [
//      Text(_scanBarcode),
      QrImage(
          data: widget.uid,
          // this the data part where we need to add employeeID with current date.
          version: QrVersions.auto,
          size: 400.0,
          gapless: false,
//                  backgroundColor:  Color.fromARGB(255, 200, 100, 100),
//                  foregroundColor: Color.fromARGB(255, 200, 25, 25),
          errorStateBuilder: (cxt, err) {
            return Container(
              child: Center(
                child: Text(
                  "Uh oh! Something went wrong...",
                  textAlign: TextAlign.center,
                ),
              ),
            );
          },
          embeddedImage: NetworkImage(
              'http://3.bp.blogspot.com/-EE2J_9N7FdI/Xc-5jf-ssgI/AAAAAAAAXmI/zWxKqrHeKGkOTBZd6aAFeZ5vXCDo6E2cgCK4BGAYYCw/s400/logo_1.png'),
          embeddedImageStyle: QrEmbeddedImageStyle(
              size: Size.square(70), color: Color.fromARGB(100, 10, 10, 10))),
    ];
  }

  _getUnVerifiedUserUI() {
    return [
      Text('Please verify your eamil in order to use this app.'),
      RaisedButton(
          child: Text("Send email again"),
          color: Theme.of(context).primaryColor,
          textColor: Colors.white,
          onPressed: _sendEmailVerificationMailAgain),
      RaisedButton(
          child: Text("Already Verified"),
          color: Theme.of(context).primaryColor,
          textColor: Colors.white,
          onPressed: _checkVerificationStatus)
    ];
  }

  void _checkVerificationStatus() async {
    try {
      FirebaseUser user = await FirebaseAuth.instance.currentUser();
      UserUpdateInfo userUpdateInfo = new UserUpdateInfo();
      userUpdateInfo.displayName = user.displayName;
      user.updateProfile(userUpdateInfo).then((onValue) {
        _isEmailVerified = user.isEmailVerified;
      });
      if (user.isEmailVerified) {
        setState(() {
          _isEmailVerified = true;
        });
      } else {
        AppUtils.showToast(
            'You haven\'t verified your email yet!', Colors.red, Colors.white);
      }
    } catch (e) {
      print('An error occured while trying to check email is verified or not!');
      AppUtils.showToast(
          'An error occured while trying to check email is verified or not!',
          Colors.red,
          Colors.white);
      print(e.message);
    }
  }

  void _sendEmailVerificationMailAgain() async {
    try {
      FirebaseUser user = await FirebaseAuth.instance.currentUser();
      user.sendEmailVerification().then((_) {
        AppUtils.showToast('Email verification link send successfuly.',
            Colors.green, Colors.white);
      }).catchError((error) {
        print(error.message);
      });
    } catch (e) {
      print("An error occured while trying to send email verification");
      AppUtils.showToast(
          'An error occured while trying to send email verification',
          Colors.red,
          Colors.white);
      print(e.message);
    }
  }

  void getCurrentUserData() async {
    try {
      FirebaseUser user = await FirebaseAuth.instance.currentUser();
      setState(() {
        _isEmailVerified = user.isEmailVerified;
      });
    } catch (e) {
      print("An error occured while trying to get current user.");
    }
  }

  _getVendorList() {
    return ListView.builder(
      itemBuilder: (context, int position) {
        Record record = Record.fromSnapshot(userList[position]);
        return Padding(
          padding: const EdgeInsets.all(4.0),
          child: Column(
            children: <Widget>[
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Container(
                    decoration: BoxDecoration(
                        shape: BoxShape.circle, color: Colors.red),
                    child: Text(
                      (position + 1).toString(),
                      style: TextStyle(color: Colors.white),
                    ),
                    padding: EdgeInsets.all(15.0),
                  ),
                  SizedBox(
                    width: 30,
                  ),
                  Expanded(
                    child: Text(
                      record.firstName,
                      style: TextStyle(fontSize: 20),
                    ),
                  )
                ],
              ),
              Divider(
                color: Colors.grey,
              ),
            ],
          ),
        );
      },
      itemCount: userList.length,
    );
  }

  void getTodaysBookingList() async{
    QuerySnapshot querySnapshot = await Firestore.instance
        .collection(AppConstants.DB_KEY_BOOKING_DATA)
        .getDocuments();
  }
}
