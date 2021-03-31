import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:thegorgeousotp/theme.dart';


class GradientSnackBar{

  static void showMessage(BuildContext context, String message){
    Flushbar(
      message: message,
      
      duration: Duration(milliseconds: 1500),
      backgroundGradient:LinearGradient(
          begin: Alignment.center,
          end: Alignment.bottomRight,
          colors: [
            MyColors.primaryColorLight
            ,
            MyColors.primaryColor
          ])
      ,backgroundColor: Colors.red,
      boxShadows: [BoxShadow(color: Colors.blue[800], offset: Offset(0.0, 2.0), blurRadius: 3.0,)],
    )..show(context);
  }
  static void showError(BuildContext context, String error){
    Flushbar(
      message: error,
      duration: Duration(milliseconds: 1500),
      backgroundGradient:LinearGradient(
          begin: Alignment.center,
          end: Alignment.bottomRight,
          colors: [
           Colors.red,
           Colors.orange
          ])
      ,backgroundColor: Colors.red,
      boxShadows: [BoxShadow(color: Colors.blue[800], offset: Offset(0.0, 2.0), blurRadius: 3.0,)],
    )..show(context);
  }

}