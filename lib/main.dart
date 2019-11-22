import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:food_manager/LoginPage.dart';
import 'package:food_manager/Record.dart';
import 'package:food_manager/RegisterPage.dart';
import 'package:food_manager/SplashPage.dart';
import 'package:food_manager/booking_id_list_model.dart';
import 'package:intl/intl.dart';
import 'package:progress_dialog/progress_dialog.dart';
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
  List userList = List();
  List<dynamic> bookingList = List();
  ProgressDialog pr;
  String userJson =
      '{"email": "", "uid": "test", "firstName": "", "lastName": "", "qrData": "", "reference": ""}';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    pr = new ProgressDialog(context,
        type: ProgressDialogType.Normal, isDismissible: false, showLogs: false);
    pr.style(
      message: 'Please wait...',
    );
    getCurrentUserData();
    getTodayBookingList();
    getUserData();
  }

  showProgressDialog(bool isShow) {
    if (isShow) {
      pr.show();
    } else {
      pr.hide();
    }
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
      showProgressDialog(false);
      setState(() {
        _isVendor = result.data[AppConstants.KEY_IS_VENDOR];
        if (_isVendor) {
          userList = querySnapshot.documents;
        } else {
          Record data = Record.fromSnapshot(result);
          if (data.uid.compareTo(widget.uid) == 0) {
            data.qrData = data.uid + getCurrentDateFromServer();
            userJson = data.toString();
          }
        }
      });
    }
  }

  Future<void> scanBarcodeNormal() async {
    String barcodeScanRes;
    // Platform messages may fail, so we use a try/catch PlatformException.
    barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
        "#42f5ef", "Cancel", true, ScanMode.QR);
    print(barcodeScanRes);

    Timestamp timestamp = Timestamp.now();
    var date = new DateTime.fromMillisecondsSinceEpoch(
        timestamp.millisecondsSinceEpoch);
    var formatter = new DateFormat('yyyy-MM-dd');
    String formatted = formatter.format(date);
    print(formatted);

    Map map = jsonDecode(barcodeScanRes);
    Record record = Record.fromJson(map);
    if (record.qrData.compareTo(record.uid + formatted) != 0) {
      AppUtils.showToast('Invalid QR code', Colors.red, Colors.white);
      return;
    }

    if (bookingList.contains(record.uid)) {
      AppUtils.showToast(
          'Dear ${record.firstName}, You have already recieved your lunch.',
          Colors.red,
          Colors.white);
    } else {
      bookingList.add(record.uid);
      setState(() {
//      AppUtils.showToast(formatted, Colors.blue, Colors.white);
        Firestore.instance
            .collection(AppConstants.DB_KEY_BOOKING_DATA)
            .document(formatted)
            .setData({
          AppConstants.KEY_BOOKING_LIST: bookingList,
        }).then((result) {});
        _scanBarcode = barcodeScanRes;
      });
    }
  }

  _getVerifiedUserUI() {
    return [
//      Text(_scanBarcode),
      QrImage(
          data: userJson,
          // this the data part where we need to add employeeID with current date.
          version: QrVersions.auto,
          size: 400.0,
          gapless: false,
//                  backgroundColor:  Color.fromARGB(255, 200, 100, 100),
//                  foregroundColor: Color.fromARGB(255, 200, 25, 25),
          errorStateBuilder: (cxt, err) {
            return Container(
              child: Center(
                child: Column(
                  children: <Widget>[
                    Text(
                      "Uh oh! Something went wrong...",
                      textAlign: TextAlign.center,
                    ),
                    RaisedButton(
                      onPressed: () {
                        getUserData();
                      },
                      child: Text('Reload QR code'),
                    )
                  ],
                ),
              ),
            );
          },
          embeddedImage: NetworkImage(
              'http://3.bp.blogspot.com/-EE2J_9N7FdI/Xc-5jf-ssgI/AAAAAAAAXmI/zWxKqrHeKGkOTBZd6aAFeZ5vXCDo6E2cgCK4BGAYYCw/s400/logo_1.png'),
          embeddedImageStyle: QrEmbeddedImageStyle(
              size: Size.square(30), color: Color.fromARGB(100, 10, 10, 10))),

      userJson.contains('test')
          ? RaisedButton(
              onPressed: () {
                getUserData();
              },
              child: Text('Reload QR code'),
            )
          : Container(),
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
    showProgressDialog(true);
    try {
      FirebaseUser user = await FirebaseAuth.instance.currentUser();
      UserUpdateInfo userUpdateInfo = new UserUpdateInfo();
      userUpdateInfo.displayName = user.displayName;
      user.updateProfile(userUpdateInfo).then((onValue) {
        FirebaseAuth.instance.currentUser().then((user) {
          showProgressDialog(false);
          _isEmailVerified = user.isEmailVerified;
          if (user.isEmailVerified) {
            setState(() {
              _isEmailVerified = true;
            });
          } else {
            AppUtils.showToast('You haven\'t verified your email yet!',
                Colors.red, Colors.white);
          }
        });
      });
    } catch (e) {
      showProgressDialog(false);
      print('An error occured while trying to check email is verified or not!');
      AppUtils.showToast(
          'An error occured while trying to check email is verified or not!',
          Colors.red,
          Colors.white);
      print(e.message);
    }
  }

  void _sendEmailVerificationMailAgain() async {
    showProgressDialog(true);
    try {
      FirebaseUser user = await FirebaseAuth.instance.currentUser();
      user.sendEmailVerification().then((_) {
        showProgressDialog(false);
        AppUtils.showToast('Email verification link send successfuly.',
            Colors.green, Colors.white);
      }).catchError((error) {
        showProgressDialog(false);
        print(error.message);
      });
    } catch (e) {
      showProgressDialog(false);
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
        showProgressDialog(false);
        _isEmailVerified = user.isEmailVerified;
      });
    } catch (e) {
      showProgressDialog(false);
      print("An error occured while trying to get current user.");
    }
  }

  _getVendorList() {
    List<Record> foodBookingUsers = List();
    for (int i = 0; i < userList.length; i++) {
      Record record = Record.fromSnapshot(userList[i]);
      if (bookingList.contains(record.uid)) {
        foodBookingUsers.add(record);
      }
    }
    return ListView.builder(
      itemBuilder: (context, int position) {
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
                      foodBookingUsers[position].firstName,
//                      bookingList[position],
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
      itemCount: foodBookingUsers.length,
//      itemCount: bookingList.length,
    );
  }

  void getTodayBookingList() async {
    QuerySnapshot querySnapshot = await Firestore.instance
        .collection(AppConstants.DB_KEY_BOOKING_DATA)
        .getDocuments();

    Timestamp timestamp = Timestamp.now();
    var date = new DateTime.fromMillisecondsSinceEpoch(
        timestamp.millisecondsSinceEpoch);
    var formatter = new DateFormat('yyyy-MM-dd');
    String formatted = formatter.format(date);

    var bookings = querySnapshot.documents;
    for (int i = 0; i < bookings.length; i++) {
      if (bookings[i].documentID.compareTo(formatted) == 0) {
        BookingId bookingId = BookingId.fromSnapshot(bookings[i]);
        bookingList.addAll(bookingId.id);
      }
    }
    if (!mounted)
      setState(() {
        showProgressDialog(false);
      });
  }

  String getCurrentDateFromServer() {
    Timestamp timestamp = Timestamp.now();
    var date = new DateTime.fromMillisecondsSinceEpoch(
        timestamp.millisecondsSinceEpoch);
    var formatter = new DateFormat('yyyy-MM-dd');
    return formatter.format(date);
  }
}
