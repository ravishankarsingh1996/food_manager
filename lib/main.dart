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
import 'myScrollBehavoiur.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Food Manager',
        debugShowCheckedModeBanner: false,
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

  Record userProfileData;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {});
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
      body: SafeArea(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: _isEmailVerified
                ? _isVendor ? _getVendorList() : _getVerifiedUserUI()
                : _getUnVerifiedUserUI(),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _isVendor
          ? FloatingActionButton.extended(
              elevation: 10,
              onPressed: scanBarcodeNormal,
              tooltip: 'Scan',
              icon: Icon(Icons.search),
              label: Text('Scan'),
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
    showProgressDialog(false);
    if (result != null) {
      setState(() {
        _isVendor = result.data[AppConstants.KEY_IS_VENDOR];
        if (_isVendor) {
          userList = querySnapshot.documents;
        } else {
          userProfileData = Record.fromSnapshot(result);
          if (userProfileData.uid.compareTo(widget.uid) == 0) {
            userProfileData.qrData =
                userProfileData.uid + getCurrentDateFromServer();
            userJson = userProfileData.toString();
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
        Firestore.instance
            .collection(AppConstants.DB_KEY_BOOKING_DATA)
            .document(formatted)
            .setData({
          AppConstants.KEY_BOOKING_LIST: bookingList,
        }).then((result) {});
        _scanBarcode = barcodeScanRes;
        AppUtils.showToast('Dear ${record.firstName}, Enjoy your lunch.😋',
            Colors.green, Colors.white);
      });
    }
  }

  _getVerifiedUserUI() {
    return [
      Container(
          margin: EdgeInsets.all(15),
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Align(
                alignment: Alignment.center,
                child: Text(
                  'Welcome Back',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
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
                ),
              )
            ],
          )),
      Container(
        child: Row(
          children: <Widget>[
            //TODO show User profile Data UI
          ],
        ),
      ),
      Expanded(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            userJson.contains('test')
                ? RaisedButton(
                    color: Colors.blue,
                    onPressed: () {
                      getUserData();
                    },
                    child: Text(
                      'Reload QR code',
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                : Card(
                    elevation: 30,
                    margin: EdgeInsets.all(10),
                    child: QrImage(
                      data: userJson,
                      // this the data part where we need to add employeeID with current date.
                      version: QrVersions.auto,
                      size: 200.0,
//                      gapless: false,
//                      backgroundColor: Colors.blueAccent,
//                      foregroundColor: Colors.white,
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
//                      embeddedImage: NetworkImage(
//                          'http://3.bp.blogspot.com/-EE2J_9N7FdI/Xc-5jf-ssgI/AAAAAAAAXmI/zWxKqrHeKGkOTBZd6aAFeZ5vXCDo6E2cgCK4BGAYYCw/s400/logo_1.png'),
//                      embeddedImageStyle: QrEmbeddedImageStyle(
//                        size: Size.square(40),
//                        color: Color.fromARGB(100, 10, 10, 10),
//                      ),
                    ),
                  ),
            SizedBox(
              height: 20,
            ),
            Text(
              'Show this QR Code to Food Vendor',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            )
          ],
        ),
      )
    ];
  }

  _getUnVerifiedUserUI() {
    return [
      SizedBox(
        height: 150,
      ),
      Expanded(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
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
          ],
        ),
      )
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

    return [
      Container(
          margin: EdgeInsets.all(15),
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Align(
                alignment: Alignment.center,
                child: Text(
                  'Today\'s Lunch Sheet',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
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
                ),
              )
            ],
          )),
      Expanded(
        child: foodBookingUsers.length > 0
            ? getVendorListBuilder(foodBookingUsers)
            : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Image.network(
                      'https://cdn.pixabay.com/photo/2017/02/21/08/49/food-2085075_960_720.png',
                      height: 100,
                      width: 100,
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Text('Today, No one took their lunch!'),
                  ],
                ),
              ),
      ),
      SizedBox(
        height: 50,
      )
    ];
  }

  getVendorListBuilder(List<Record> foodBookingUsers) {
    return ScrollConfiguration(
      behavior: MyBehavior(),
      child: ListView.builder(
        itemBuilder: (context, int position) {
          return Container(
            decoration: BoxDecoration(boxShadow: [
              BoxShadow(spreadRadius: 1, color: Colors.grey, blurRadius: 15)
            ]),
            margin: EdgeInsets.all(15.0),
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(15),
                topLeft: Radius.circular(15),
              ),
              child: Stack(
                children: <Widget>[
                  Container(
                    height: 100,
                    width: double.infinity,
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                            colors: [Colors.lightBlue, Colors.blueAccent])),
                  ),
                  Container(
                    height: 100,
                    width: double.infinity,
                    child: Column(
                      children: <Widget>[
                        Expanded(
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Container(
                                margin: EdgeInsets.symmetric(
                                    horizontal: 10.0, vertical: 2.0),
                                child: Column(
                                  children: <Widget>[
                                    Card(
                                      color: Colors.white,
                                      elevation: 10,
                                      shape: CircleBorder(),
                                      child: Container(
                                        height: 45,
                                        width: 45,
                                        padding: EdgeInsets.all(5),
                                        child: Center(
                                          child: Text(
                                            (position + 1).toString(),
                                            style: TextStyle(
                                                color: Colors.orange,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 3,
                                    ),
                                    Text(
                                      foodBookingUsers[position].employeeId,
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600),
                                    )
                                  ],
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                ),
                              ),
                              SizedBox(
                                width: 30,
                              ),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      foodBookingUsers[position].firstName +
                                          ' ' +
                                          foodBookingUsers[position].lastName,
                                      style: TextStyle(
                                          fontSize: 30, color: Colors.white),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      textAlign: TextAlign.start,
                                    ),
                                    Text(
                                      foodBookingUsers[position].email,
                                      style: TextStyle(
                                          fontSize: 12, color: Colors.white70),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.all(10),
                                child: Card(
                                    color: Colors.white,
                                    elevation: 10,
                                    shape: StadiumBorder(),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Icon(
                                        Icons.cloud_done,
                                        color: Colors.green,
                                      ),
                                    )),
                              )
                            ],
                          ),
                        ),
//                      Divider(
//                        color: Colors.grey,
//                      ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        itemCount: foodBookingUsers.length,
//      itemCount: bookingList.length,
      ),
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
