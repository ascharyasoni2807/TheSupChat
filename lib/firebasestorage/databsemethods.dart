import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thegorgeousotp/providers/imageuploadprovider.dart';
import 'package:thegorgeousotp/repos/storage_repo.dart';

final databaseReference = FirebaseDatabase.instance.reference();
final FirebaseAuth _auth = FirebaseAuth.instance;

class DatabaseMethods {
  List users = [];

  getUserByUserPhone() async {
    return FirebaseFirestore.instance
        .collection("users")
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((result) {
        // print(result.data());
        final Map value = result.data();
        users = value.values.toList();
        print(users[1]["phone"]);
      });
    });
  }

  updateProfilePictureinRTDB(uid, url) async {
    await databaseReference.child(uid).update({'profilePicture': url});
    readProfile(uid);
  }

  var currentuser = _auth.currentUser.uid;

  Future<void> updateNameofuser(name) async {
    await databaseReference.child(currentuser).update({'name': name});

    await FirebaseFirestore.instance
        .collection('users')
        .doc('$currentuser')
        .update({'name': name});
  }

  Future<void> uploadingUserInfo(uid, userMap) async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .set(userMap)
        .catchError((e) {
      print(e.toString());
    });

    await databaseReference.child(uid).set(userMap).catchError((e) {
      print(e);
    });
  }

  List userdetail;
  void readProfile(uid) {
    databaseReference.child(uid).onValue.listen((event) {
      final Map value = event.snapshot.value;
      userdetail = value.values.toList();
      print(userdetail);
      return userdetail[0];
      //  print("in data");
    });
  }

  Future<void> createChatRoom(
      serveruid,serverPhone, selfchatRoomMap, secondchatRoomMap) async {
    final snapShot = await FirebaseFirestore.instance
        .collection('ChatRoom')
        .doc(_auth.currentUser.phoneNumber)
        // .collection('Chats').where('chatroomId' , isEqualTo : serverPhone.toString())
        .get();

    final serversnapShot = await FirebaseFirestore.instance
        .collection('ChatRoom')
        .doc(serverPhone.toString())
        // collection('Chats').where('chatroomId' , isEqualTo :_auth.currentUser.uid)
        .get();
    print(snapShot.data());
    print(serversnapShot.data());
    if (snapShot.data() == null || !snapShot.exists) {
      print("current user not exist krta hai");
      FirebaseFirestore.instance
          .collection("ChatRoom")
          .doc(_auth.currentUser.phoneNumber)
          // .collection("Chats").doc(serverPhone.toString())
          .set({'uid':_auth.currentUser.uid})
          .catchError((e) {
        print(e.toString());
      }).then((value) {
        FirebaseFirestore.instance
            .collection("ChatRoom")
            .doc(_auth.currentUser.phoneNumber)
            .collection("ListUsers")
            .doc(_auth.currentUser.uid.toString()+"_"+serveruid)
            .set(selfchatRoomMap);
        if (serversnapShot.data() == null || !serversnapShot.exists) {

          FirebaseFirestore.instance
              .collection("ChatRoom")
              .doc(serverPhone)
              // .collection("Chats").doc(serverPhone.toString())
              .set({'uid':serveruid})
              .catchError((e) {
            print(e);
          }).then((value) {
            print("server data created and adding data");
            FirebaseFirestore.instance
                .collection("ChatRoom")
                .doc(serverPhone.toString())
                .collection("ListUsers")
                .doc(serveruid+"_"+_auth.currentUser.uid.toString())
                .set(secondchatRoomMap)
                .catchError((e) {
              print(e.toString());
            });
          });
        } else {
          print("other user exist already  hai , chat room bana rahe hai");
          FirebaseFirestore.instance
              .collection("ChatRoom")
              .doc(serverPhone.toString())
              .collection("ListUsers")
              .doc(serveruid+"_"+_auth.currentUser.uid.toString())
              .set(secondchatRoomMap)
              .catchError((e) {
            print(e.toString());
          });
        }
      });
    } else {
      print("current user exist already , to direct current user ka data ");
      FirebaseFirestore.instance
          .collection("ChatRoom")
          .doc(_auth.currentUser.phoneNumber)
          .collection("ListUsers")
          .doc(_auth.currentUser.uid.toString()+"_"+serveruid)
          .set(selfchatRoomMap);


       if (serversnapShot.data() == null || !serversnapShot.exists) {
          FirebaseFirestore.instance
              .collection("ChatRoom")
              .doc(serverPhone)
              // .collection("Chats").doc(serverPhone.toString())
              .set({'uid':serveruid})
              .catchError((e) {
            print(e);
          }).then((value) {
            print("server data created and adding data");
            FirebaseFirestore.instance
                .collection("ChatRoom")
                .doc(serverPhone.toString())
                .collection("ListUsers")
                .doc(serveruid+"_"+_auth.currentUser.uid.toString())
                .set(secondchatRoomMap)
                .catchError((e) {
              print(e.toString());
            });
          });
        } else {
          print("other user exist already  hai , chat room bana rahe hai");
          FirebaseFirestore.instance
              .collection("ChatRoom")
              .doc(serverPhone.toString())
              .collection("ListUsers")
              .doc(serveruid+"_"+_auth.currentUser.uid.toString())
              .set(secondchatRoomMap)
              .catchError((e) {
            print(e.toString());
          });
        }   
    }

   



  }

   addConvMessage(String chatroomId, messageMap) {
    FirebaseFirestore.instance
        .collection("ChatRoom")
        .doc(chatroomId)
        .collection("chats")
        .add(messageMap)
        .catchError((e) {
      print(e.toString());
    }).then((value) => print(value));
  }


   addImageConvMessage(String chatroomId, messageMap ) {
    // ImageUploadProvider _imageUploadProvider;
    
    FirebaseFirestore.instance
        .collection("ChatRoom")
        .doc(chatroomId)
        .collection("chats")
        .add(messageMap)
        .catchError((e) {
      print(e.toString());
    }).then((value) => print(value));
  }

 int perPage = 10;
   getConvoMessage(String chatroomId) async {
    return await FirebaseFirestore.instance
        .collection("ChatRoom")
        .doc("KartikSoni_welcome")
        .collection("chats")
        .orderBy("time", descending: true).limit(perPage)
        .snapshots();
  }

  getNextConvo (String chatroomId) async {

    return await FirebaseFirestore.instance
        .collection("ChatRoom")
        .doc("KartikSoni_welcome")
        .collection("chats")
        // .orderBy("time", descending: true).startAfter(values)
        .limit(perPage)
        .snapshots();


  }

  Future<void> savePhonenumber(phone) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('phone', phone);
  }

  Future<void> saveName(name) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('name', name.toString());
  }

  Future<void> saveUid(uid) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('uid', uid);
  }

  Future<void> clearAll() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.clear();
  }
}
