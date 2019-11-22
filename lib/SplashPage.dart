import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wave/config.dart';
import 'main.dart';
import 'package:wave/wave.dart';

class SplashPage extends StatefulWidget {
  SplashPage({Key key}) : super(key: key);

  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  initState() {
    FirebaseAuth.instance
        .currentUser()
        .then((currentUser) => {
              if (currentUser == null)
                {Navigator.pushReplacementNamed(context, "/login")}
              else
                {
                  Firestore.instance
                      .collection("users")
                      .document(currentUser.uid)
                      .get()
                      .then((DocumentSnapshot result) {
                    if (result != null) {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => MyHomePage(
                                    title: ('Welcome back '+result.data["fname"]).toUpperCase(),
                                    uid: currentUser.uid,
                                  )));
                    }
                  }).catchError((err) => print(err))
                }
            })
        .catchError((err) => print(err));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
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
              heightPercentages: [0.78, 0.80, 0.83, 0.85],
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
          Center(
            child: Container(
              child: Transform.rotate(
                angle: -90,
                child: Image.network(
                  'https://storage.needpix.com/rsynced_images/black-2420162_1280.png',
                  height: 200,
                  width: 200,
                  color: Colors.white70,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
