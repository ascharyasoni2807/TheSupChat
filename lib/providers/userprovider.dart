import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:theproject/enum/userState.dart';


class UserProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // User _user;
 UserState _userState = UserState.Online;
  UserState get getStatus => _userState;

  Future<void> refreshUser() async {
   var user =  FirebaseFirestore.instance
      .collection('users')
      .doc(_auth.currentUser.uid).snapshots();

    notifyListeners();
  }

}