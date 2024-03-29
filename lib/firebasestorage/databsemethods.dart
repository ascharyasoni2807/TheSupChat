import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:theproject/enum/userState.dart';

import 'package:theproject/repos/customfunctions.dart';
import 'package:theproject/utilities.dart/utility.dart';

import '../pages/chatScreen.dart';
import '../pages/chatScreen.dart';

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
      serveruid, serverPhone, selfchatRoomMap, secondchatRoomMap) async {
    var user = _auth.currentUser;
    var phoneNumber =
        CustomFunctions().shortPhoneNumber(user.phoneNumber.toString());

    if (serverPhone.contains("+")) {
      print("yesss");
      serverPhone = serverPhone.substring(serverPhone.length - 10);
    } else {
      serverPhone = serverPhone;
    }

    final snapShot = await FirebaseFirestore.instance
        .collection('ChatRoom')
        .doc(phoneNumber)
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
      FirebaseFirestore.instance.collection("ChatRoom").doc(phoneNumber)
          // .collection("Chats").doc(serverPhone.toString())
          .set({'uid': _auth.currentUser.uid}).catchError((e) {
        print(e.toString());
      }).then((value) {
        FirebaseFirestore.instance
            .collection("ChatRoom")
            .doc(phoneNumber)
            .collection("ListUsers")
            .doc(_auth.currentUser.uid.toString() + "_" + serveruid)
            .set(selfchatRoomMap);
        if (serversnapShot.data() == null || !serversnapShot.exists) {
          FirebaseFirestore.instance.collection("ChatRoom").doc(serverPhone)
              // .collection("Chats").doc(serverPhone.toString())
              .set({'uid': serveruid}).catchError((e) {
            print(e);
          }).then((value) {
            print("server data created and adding data");
            FirebaseFirestore.instance
                .collection("ChatRoom")
                .doc(serverPhone.toString())
                .collection("ListUsers")
                .doc(serveruid + "_" + _auth.currentUser.uid.toString())
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
              .doc(serveruid + "_" + _auth.currentUser.uid.toString())
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
          .doc(phoneNumber)
          .collection("ListUsers")
          .doc(_auth.currentUser.uid.toString() + "_" + serveruid)
          .set(selfchatRoomMap);
      if (serversnapShot.data() == null || !serversnapShot.exists) {
        FirebaseFirestore.instance.collection("ChatRoom").doc(serverPhone)
            // .collection("Chats").doc(serverPhone.toString())
            .set({'uid': serveruid}).catchError((e) {
          print(e);
        }).then((value) {
          print("server data created and adding data");
          FirebaseFirestore.instance
              .collection("ChatRoom")
              .doc(serverPhone.toString())
              .collection("ListUsers")
              .doc(serveruid + "_" + _auth.currentUser.uid.toString())
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
            .doc(serveruid + "_" + _auth.currentUser.uid.toString())
            .set(secondchatRoomMap)
            .catchError((e) {
          print(e.toString());
        });
      }
    }
  }

 Future<void> addConvMessage(
    otherphone,
    messageMap,
    serveruid,
  ) async {
    var user = _auth.currentUser;
    var phoneNumber = user.phoneNumber.toString();

    phoneNumber = phoneNumber.substring(phoneNumber.length - 10);

    print("ppppppppppppppppppppppppppppppp" + phoneNumber);

    FirebaseFirestore.instance
        .collection("ChatRoom")
        .doc(phoneNumber)
        .collection("ListUsers")
        .doc((_auth.currentUser.uid.toString() + "_" + serveruid))
        .collection("Chats")
        .add(messageMap)
        .catchError((e) {
      print(e.toString());
    }).then((value) async {
      print(value.id);
      print(otherphone);
      if (otherphone.contains("+")) {
        print("yesss");
        otherphone = otherphone.substring(otherphone.length - 10);
        print(otherphone);
      } else {
        otherphone = otherphone;
        print(otherphone);
      }
      await FirebaseFirestore.instance
          .collection("ChatRoom")
          .doc(otherphone)
          .collection("ListUsers")
          .doc((serveruid + "_" + _auth.currentUser.uid.toString()))
          .collection("Chats")
          .doc(value.id)
          .set(messageMap)
          .catchError((onError) {
        print(onError);
      });
    });
  }

  addImageConvMessage(
    otherPhone,
    messageMap,
    serveruid,
  ) {
    // ImageUploadProvider _imageUploadProvider;
    print(_auth.currentUser.phoneNumber);
    var user = _auth.currentUser;
    var phoneNumber = CustomFunctions().shortPhoneNumber(user.phoneNumber);
    FirebaseFirestore.instance
        .collection("ChatRoom")
        .doc(phoneNumber)
        .collection("ListUsers")
        .doc((_auth.currentUser.uid.toString() + '_' + serveruid))
        .collection("Chats")
        .add(messageMap)
        .catchError((e) {
      print(e.toString());
    }).then((value) {
      if (otherPhone.contains("+")) {
        print("yesss");
        otherPhone = CustomFunctions().shortPhoneNumber(otherPhone);
        print(otherPhone);
      } else {
        otherPhone = otherPhone;
        print(otherPhone);
      }

      FirebaseFirestore.instance
          .collection("ChatRoom")
          .doc(otherPhone)
          .collection("ListUsers")
          .doc((serveruid + "_" + _auth.currentUser.uid.toString()))
          .collection("Chats")
          .doc(value.id)
          .set(messageMap);
    });

    return 'completed';
  }

  int perPage = 30;
 
  getConvoMessage(serveruid,contact) async {
    var user = _auth.currentUser;
    var phoneNumber = CustomFunctions().shortPhoneNumber(user.phoneNumber);
    var b = await FirebaseFirestore.instance
            .collection('ChatRoom')
            .doc(contact)
            .collection('ListUsers')
            .doc(serveruid + "_" + _auth.currentUser.uid).collection('Chats').orderBy('time').where('isRead',isEqualTo:'false').get();
        b.docs.forEach((document) {
         print(document.id);
         FirebaseFirestore.instance
            .collection('ChatRoom')
            .doc(contact)
            .collection('ListUsers')
            .doc((serveruid + "_" + _auth.currentUser.uid)).collection('Chats').doc(document.id).update(
              {
                 'isRead' : 'true'
              }
            );

         });

    return await FirebaseFirestore.instance
        .collection("ChatRoom")
        .doc(phoneNumber)
        .collection("ListUsers")
        .doc((_auth.currentUser.uid.toString() + '_' + serveruid))
        .collection("Chats")
        .orderBy("time", descending: true)
        // .limit(25)
        .snapshots();
  }

  getFcmToken() async {
   var tok= await FirebaseMessaging.instance.getToken();

   return tok;
  }

  getHomeUsers() async {
    return await FirebaseFirestore.instance
        .collection("ChatRoom")
        .doc(_auth.currentUser.phoneNumber.toString())
        .collection("ListUsers")
        .orderBy("time")
        .snapshots();
  }

  getPhotoUrlofanyUser(uid) async {
    var url;
    var data =
        await FirebaseFirestore.instance.doc("users/$uid").get().then((value) {
      return value['profilePicture'];
    });

    return data.toString();
  }

 Future<void> deleteConvo(id, otherphone, serveruid) {
    var user = _auth.currentUser;
    var phoneNumber =
        CustomFunctions().shortPhoneNumber(user.phoneNumber.toString());

    FirebaseFirestore.instance
        .collection("ChatRoom")
        .doc(phoneNumber)
        .collection("ListUsers")
        .doc((_auth.currentUser.uid.toString() + "_" + serveruid))
        .collection("Chats")
        .doc(id)
        .delete()
        .catchError((e) {
      print(e.toString());
    }).then((value) async {
      print(otherphone);
      if (otherphone.contains("+")) {
        print("yesss");
        otherphone = otherphone.substring(otherphone.length - 10);
        print(otherphone);
      } else {
        otherphone = otherphone;
        print(otherphone);
      }
      await FirebaseFirestore.instance
          .collection("ChatRoom")
          .doc(otherphone)
          .collection("ListUsers")
          .doc((serveruid + "_" + _auth.currentUser.uid.toString()))
          .collection("Chats")
          .doc(id)
          .delete()
          .catchError((onError) {
        print(onError);
      });

     
    });

     FirebaseFirestore.instance
          .collection("ChatRoom")
          .doc(phoneNumber)
          .collection("ListUsers")
          .doc((_auth.currentUser.uid.toString() + '_' + serveruid))
          .collection("Chats")
          .orderBy("time", descending: true)
          .limit(1)
          .get()
          .then((value) async {
        var a = value.docs.first.data();
        print(a['message']);

        FirebaseFirestore.instance
            .collection('ChatRoom')
            .doc(phoneNumber)
            .collection('ListUsers')
            .doc((_auth.currentUser.uid + "_" + serveruid))
            .update({'lastMessage': a['message'],
                      'time': a['time']});
      });

      FirebaseFirestore.instance
          .collection("ChatRoom")
          .doc(otherphone)
          .collection("ListUsers")
          .doc((serveruid + "_" + _auth.currentUser.uid))
          .collection("Chats")
          .orderBy("time", descending: true)
          .limit(1)
          .get()
          .then((value) async {
        var a = value.docs.first.data();
        print(a['message']);

        FirebaseFirestore.instance
            .collection('ChatRoom')
            .doc(otherphone)
            .collection('ListUsers')
            .doc(serveruid + "_" + _auth.currentUser.uid)
            .update({'lastMessage': a['message'],
            'time': a['time']});
      });
  }

  Future<void> deleteSingleConvo(id, otherphone, serveruid) {
    var user = _auth.currentUser;
    var phoneNumber =
        CustomFunctions().shortPhoneNumber(user.phoneNumber.toString());

    FirebaseFirestore.instance
        .collection("ChatRoom")
        .doc(phoneNumber)
        .collection("ListUsers")
        .doc((_auth.currentUser.uid.toString() + "_" + serveruid))
        .collection("Chats")
        .doc(id)
        .delete()
        .catchError((e) {
      print(e.toString());
    }).then((value) async {
      await FirebaseFirestore.instance
          .collection("ChatRoom")
          .doc(phoneNumber)
          .collection("ListUsers")
          .doc((_auth.currentUser.uid.toString() + '_' + serveruid))
          .collection("Chats")
          .orderBy("time", descending: true)
          .limit(1)
          .get()
          .then((value) async {
            
        var a = value.docs.first.data();
        print(a['message']);

        FirebaseFirestore.instance
            .collection('ChatRoom')
            .doc(phoneNumber)
            .collection('ListUsers')
            .doc((_auth.currentUser.uid + "_" + serveruid))
            .update({'lastMessage': a['message'],
            'time': a['time']});
      });

    });
  }



   void setUserState({ userState}) async {
      var user = _auth.currentUser;
    var phoneNumber =
        CustomFunctions().shortPhoneNumber(user.phoneNumber.toString());
    int stateNum = Utils.stateToNum(userState);
    
    await FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .update({
         "state": stateNum,
      }

      );

   
  }




   
 Stream<QuerySnapshot> getListStream()  {
  return   FirebaseFirestore.instance
        .collection("ChatRoom")
        .doc(CustomFunctions().shortPhoneNumber(_auth.currentUser.phoneNumber))
        .collection("ListUsers")
        .orderBy("time", descending: true)
        .snapshots();

  }

  Stream<DocumentSnapshot> getUserStream(uid) {
    return FirebaseFirestore.instance
      .collection('users')
      .doc(uid).snapshots();
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
