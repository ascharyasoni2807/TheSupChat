import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:thegorgeousotp/firebasestorage/databsemethods.dart';
import 'package:thegorgeousotp/pages/contatcs1.dart';
import 'package:thegorgeousotp/pages/profilepage.dart';
import 'package:thegorgeousotp/repos/candidate.dart';
import 'package:thegorgeousotp/stores/login_store.dart';
import 'package:thegorgeousotp/theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:thegorgeousotp/widgets/cirindi.dart';
import '../theme.dart';
import "package:thegorgeousotp/pages/permission.dart";

class HomePage extends StatefulWidget {
  const HomePage({Key key}) : super(key: key);
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Stream chatroomstream;
  bool isbuilding = true;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  LoginStore loginStore = LoginStore();
  List users = [];
  FirebaseFirestore firestoreInstance = FirebaseFirestore.instance;

  // listalluser() async {
  //   firestoreInstance
  //       .collection("users")
  //       .get()
  //       .then((QuerySnapshot querySnapshot) {
  //     querySnapshot.docs.forEach((result) {
  //       // print(result.data());
  //       final Map value = result.data();
  //       users = value.values.toList();
  //       print(users[1]["phone"]);
  //     });
  //   });
  // }

  @override
  void initState() {
    // TODO: implement initState
    //  getContacts();
    getContacts();
    getUserInfo();
    // getContacts();
    super.initState();
  }

  final foundusers = [];
  final phonenumber = [];

  getContacts() async {
    final Iterable<Contact> contacts = await ContactsService.getContacts(
      withThumbnails: false,
    );
           var user =_auth.currentUser;
var selfPhone = user.phoneNumber.toString();
    selfPhone = selfPhone.substring(selfPhone.length - 10);

    // final contacts =  _contacts.toList();
    Map hashmap = Map();

    contacts.forEach((element) {
      element.phones.forEach((_element) {
        hashmap[_element.value.replaceAll(new RegExp(r'[\)\(\-\s]+'), "")] =
            element;
      });
      phonenumber.addAll(element.phones
          .map((e) => e.value.replaceAll(new RegExp(r'[\)\(\-\s]+'), "")));
    });
    await FirebaseFirestore.instance
        .collection(
            "ChatRoom/${selfPhone}/ListUsers")
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((result) {
        // print(result.data());
        final Map value = result.data();

        if (phonenumber.contains(value['chatroomId'])) {
          foundusers.add(
              {"serverData": value, "phoneData": hashmap[value['chatroomId']]});

          print("aaaaaaaaaaaaaaaaaaaaaaaaaaaaaa");
          print(value);
        }
      });
    });
    //  print(  foundusers[0]["phoneData"].displayName);
    setState(() {
      isbuilding = false;
     
    });
// //  await singelTonUsers.getContacts();
//  setState(() {
//   checkState = true;
//  });
  }

   getUserInfo() async {
    print('heeloji');
       var user =_auth.currentUser;
var phoneNumber = user.phoneNumber.toString();
    phoneNumber = phoneNumber.substring(phoneNumber.length - 10);
  
     var value = FirebaseFirestore.instance
        .collection("ChatRoom").doc(phoneNumber).collection("ListUsers").orderBy("time")
        .snapshots();
    // print(value);
    setState(() {
     
      chatroomstream = value;

      isbuilding = false;
      // getContacts();
    });
    // chatroomstream.listen((event) { 
      
    // });
  }

  Widget chatRoomList() {
    return foundusers != null
        ? !isbuilding
            ? StreamBuilder<QuerySnapshot>(
                stream: chatroomstream,
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  return snapshot.hasData
                      ? SingleChildScrollView(
                          physics: BouncingScrollPhysics(),
                          child: Column(
                            children: [
                              ListView.builder(
                                  physics: NeverScrollableScrollPhysics(),
                                  // scrollDirection: Axis.vertical,
                                  shrinkWrap: true,
                                  itemCount: foundusers.length,
                                  itemBuilder: (context, index) {
                                    final _contact =
                                        foundusers.elementAt(index);
                                    Contact contact = _contact["phoneData"];
                                    final serverData = _contact["serverData"];
                                    return Chatroomtile(
                                        userName: contact?.displayName ?? null,
                                        // .replaceAll("_", ""),
                                        // .replaceAll(Constants.myName, ''),
                                        chatRoomId: serverData["chatroomId"],
                                        image: serverData["otherUserProfile"]);
                                  }),
                            ],
                          ),
                        )

                      // ignore: prefer_const_constructors
                      : Center(child: CustomprogressIndicator());
                })
            : Center(child: CustomprogressIndicator())
        : Center(child: CustomprogressIndicator());
  }

  newstateup() async {
    var datareference = FirebaseFirestore.instance.collection("chatroomId");
  }

 

  @override
  Widget build(BuildContext context) {
    return Consumer<LoginStore>(
      builder: (_, loginStore, __) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
              title: Text(
                "Chats",
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: MyColors.buttoncolor,
              actions: [
                Container(
                    padding: EdgeInsets.symmetric(horizontal: 2),
                    child: IconButton(
                      icon: Icon(Icons.logout),
                      onPressed: () {
                        loginStore.signOut(context);

                        print("about to logout");
                      },
                    )),
                Container(
                    padding: EdgeInsets.symmetric(horizontal: 0),
                    child: IconButton(
                        icon: Icon(Icons.face_retouching_natural),
                        onPressed: () {
                          // loginStore.signOut(context);
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ProfilePage()));
                          print("profile");
                        }))
              ]),
          body: Container(
            // color: Color(0xff536162),
            child: Center(child: ListView(
              children: [chatRoomList()])
              ),



          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              ContactPermission().permissioncheck(context);
              print("hello supchat");
            },
            backgroundColor: MyColors.maincolor,
            splashColor: MyColors.buttoncolor,
            elevation: 2,
            child: Icon(Icons.message),
          ),
        );
      },
    );
  }
}

class Chatroomtile extends StatelessWidget {
  final String userName;
  final String chatRoomId;
  var image;

  Chatroomtile({this.userName, this.chatRoomId, this.image});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        print(chatRoomId);
        print("innnnnnn");
        // Navigator.push(context,
        //     MaterialPageRoute(builder: (context) => Chatscreen(chatRoomId)));
      },
      onDoubleTap: () {
        print("null");
      },
      child: ListTile(
        visualDensity: VisualDensity.adaptivePlatformDensity,
        // separatorBuilder: (BuildContext context, int index) => Divider(height: 1),
        leading: image != null
            ? CircleAvatar(
                radius: 30,
                backgroundColor: Colors.black,
                child: ClipOval(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: SizedBox(
                        height:50,
                        width: 50,
                        child: (image != null)
                            ? CachedNetworkImage(
                                imageUrl: image,
                                progressIndicatorBuilder:
                                    (context, url, downloadProgress) =>
                                        CircularProgressIndicator(
                                            value: downloadProgress.progress),
                                errorWidget: (context, url, error) =>
                                    Icon(Icons.error),
                              )

                            //  Image.network(
                            //  userPhotos,
                            //   fit: BoxFit.fill,
                            // )
                            : Image.asset('assets/img/pp.png')),
                  ),
                ),
              )
            : Image.asset('assets/img/pp.png'),
        title: Text(
          userName,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),

        subtitle: Text(
          "Last Mesaage Line",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        ),
      ),
    );
  }
}
