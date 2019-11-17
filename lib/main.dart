import 'package:flutter/material.dart';
import 'package:food_manager/LoginPage.dart';
import 'package:food_manager/RegisterPage.dart';
import 'package:food_manager/SplashPage.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

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
  String _scanBarcode ="";

  Future<void> scanBarcodeNormal() async {
    String barcodeScanRes;
    // Platform messages may fail, so we use a try/catch PlatformException.

    barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
        "#42f5ef", "Cancel", true, ScanMode.QR);
    print(barcodeScanRes);

    setState(() {
      _scanBarcode = barcodeScanRes;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Text(_scanBarcode),
              QrImage(
                  data: "BM27 MobCoder LLC",// this the data part where we need to add employeeID with current date.
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
                  embeddedImage: NetworkImage('http://3.bp.blogspot.com/-EE2J_9N7FdI/Xc-5jf-ssgI/AAAAAAAAXmI/zWxKqrHeKGkOTBZd6aAFeZ5vXCDo6E2cgCK4BGAYYCw/s400/logo_1.png'),
                  embeddedImageStyle : QrEmbeddedImageStyle(
                      size: Size.square(70),
                      color: Color.fromARGB(100, 10, 10, 10)
                  )
              ),
            ],
          )
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: scanBarcodeNormal,
        tooltip: 'Scan',
        child: Icon(Icons.search),
      ),
    );
  }
}
