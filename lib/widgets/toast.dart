import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:theproject/theme.dart';

class Toaster {
  toaster(msg) {
    return Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_SHORT,
        backgroundColor: MyColors.maincolor,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 2);
  }
}
