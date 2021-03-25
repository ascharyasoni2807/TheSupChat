


import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:thegorgeousotp/repos/storage_repo.dart';

class DatabaseMethods {
 
List users =[];

 getUserByUserPhone() async {
   return FirebaseFirestore.instance.collection("users").get().then((QuerySnapshot querySnapshot) {
    querySnapshot.docs.forEach((result) {
      // print(result.data());
       final Map value = result.data();
    users = value.values.toList();
    print(users[1]["phone"]);
    });
  });
  
  }



 Future<void> uploadUserInfo( uid , phone,  userMap) async {
    FirebaseFirestore.instance.collection("users").doc(uid).set(userMap).catchError((e) {
      print(e.toString());
    });
  }




}