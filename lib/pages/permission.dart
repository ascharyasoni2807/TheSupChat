

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:theproject/pages/contatcs1.dart';

class ContactPermission {


Future<void> permissioncheck2 (context) async {
final PermissionStatus permissionStatus = await _getPermission();
 if (permissionStatus == PermissionStatus.granted) {
          //We can now access our contacts here

        } else {
          var reults2 = await Permission.storage.request();
          var result = await Permission.contacts.request();
          var resulting = await Permission.microphone.request();
          //If permissions have been denied show standard cupertino alert dialog
          showDialog(
              context: context,
              builder: (BuildContext context) => CupertinoAlertDialog(
                    title: Text('Permissions error'),
                    content: Text('Please enable contacts access '
                        'permission in system settings'),
                    actions: <Widget>[
                      CupertinoDialogAction(
                        child: Text('OK'),
                        onPressed: () => Navigator.of(context).pop(),
                      )
                    ],
                  ));
        }
}

void permissioncheck (context) async {
final PermissionStatus permissionStatus = await _getPermission();
 if (permissionStatus == PermissionStatus.granted) {
          //We can now access our contacts here
          //
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => ContactsPage()));
        } else {

          var result = await Permission.contacts;
           var reults2 = await Permission.storage.request();
          var resulting = await Permission.microphone.request();
          //If permissions have been denied show standard cupertino alert dialog
          showDialog(
              context: context,
              builder: (BuildContext context) => CupertinoAlertDialog(
                    title: Text('Permissions error'),
                    content: Text('Please enable contacts access '
                        'permission in system settings'),
                    actions: <Widget>[
                      CupertinoDialogAction(
                        child: Text('OK'),
                        onPressed: () => Navigator.of(context).pop(),
                      )
                    ],
                  ));
        }
}


 Future<PermissionStatus> _getPermission() async {
    final PermissionStatus permission = await Permission.contacts.status;
    final PermissionStatus permissions = await Permission.contacts.request(); 
    //  var reults2 = await Permission.storage.request();
    //       var resulting = await Permission.microphone.request();
    return permissions;
  //   if (permission != PermissionStatus.granted &&
  //       permission != PermissionStatus.denied) {
  //     final Map<Permission, PermissionStatus> permissionStatus =
  //         await [Permission.contacts].request();
  //     return permissionStatus[Permission.contacts] ??
  //         PermissionStatus.limited;
  //   } else {
  //     return permission;
  //   }
  // }

 }
}