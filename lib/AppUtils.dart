  import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AppUtils{
   static void showToast(String message, Color alertColor, Color textColor){
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIos: 1,
        backgroundColor: alertColor,
        textColor: textColor,
        fontSize: 16.0);
  }

}