import 'dart:async';
import 'package:intl/intl.dart';
import 'package:theproject/repos/customfunctions.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:theproject/firebasestorage/databsemethods.dart';
// import 'package:theproject/pages/contatcs1.dart';
import 'package:theproject/pages/profilepage.dart';
// import 'package:theproject/repos/candidate.dart';
import 'package:theproject/stores/login_store.dart';
import 'package:theproject/theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:theproject/widgets/cachedImage.dart';
import 'package:theproject/widgets/cirindi.dart';
import '../theme.dart';
import 'package:theproject/pages/chatScreen.dart';
import "package:theproject/pages/permission.dart";

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
  //

  @override
  void initState() {
    // TODO: implement initState
    //  getContacts();
    // ContactPermission().permissioncheck(context);
    // getUserInfo();
    chatroomstream = FirebaseFirestore.instance
        .collection("ChatRoom")
        .doc(CustomFunctions().shortPhoneNumber(_auth.currentUser.phoneNumber))
        .collection("ListUsers")
        .orderBy("time", descending: true)
        .snapshots();

    getContacts();

    super.initState();
    // getContacts();
  }

  Map hashmap;
  List foundusers = [];
  final phonenumber = [];
  String selfPhone;
  getContacts() async {
    final Iterable<Contact> contacts = await ContactsService.getContacts(
      withThumbnails: false,
    );
    var user = _auth.currentUser;
    selfPhone = CustomFunctions().shortPhoneNumber(user.phoneNumber);

    // final contacts =  _contacts.toList();
    hashmap = Map();

    contacts.forEach((element) {
      element.phones.forEach((_element) {
        hashmap[_element.value.replaceAll(new RegExp(r'[\)\(\-\s]+'), "")] =
            element;
      });
      phonenumber.addAll(element.phones
          .map((e) => e.value.replaceAll(new RegExp(r'[\)\(\-\s]+'), "")));
    });
  }

  values(QuerySnapshot querySnapshot) async {
    final _foundusers = [];
    for (int i = 0, len = querySnapshot?.docs?.length; i < len; i++) {
      final result = querySnapshot?.docs[i];
      final Map value = result.data();

      bool a = phonenumber.contains(value['chatroomIdWithCountry']);
      bool b = phonenumber.contains(value['phoneNumber']);
      var allProfilePic;
      allProfilePic =
          await DatabaseMethods().getPhotoUrlofanyUser(value["uid"]);

      if (phonenumber.contains(value['phoneNumber']) ||
          phonenumber.contains(value['chatroomIdWithCountry'])) {
        print(value['chatroomIdWithCountry']);
        print(value['phoneNumber']);
        print(a);
        print(b);
        _foundusers.add({
          "serverData": value,
          "profilePicture": allProfilePic,
          "phoneData": a
              ? hashmap[value['chatroomIdWithCountry']]
              : hashmap[value['phoneNumber']]
        });
        print(value);
        print(_foundusers);
      }
    }

    return _foundusers;
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget chatRoomList() {
    return StreamBuilder<QuerySnapshot>(
        stream: chatroomstream,
        
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          return snapshot.hasData && snapshot.data.docs.isNotEmpty
              ? FutureBuilder(
                  future: values(snapshot.data),
                  builder: (context, snap) {
                    return snap.hasData
                        ? SingleChildScrollView(
                            physics: BouncingScrollPhysics(),
                            child: Column(
                              children: [
                                ListView.builder(
                                    physics: NeverScrollableScrollPhysics(),
                                    // scrollDirection: Axis.vertical,
                                    shrinkWrap: true,
                                    itemCount: snap?.data?.length,
                                    itemBuilder: (context, index) {
                                      final _contact =
                                          snap.data?.elementAt(index);
                                      Contact contact = _contact["phoneData"];
                                      final serverData = _contact["serverData"];
                                      final imageurl =
                                          _contact["profilePicture"];
                                      return Column(
                                        children: [
                                          Chatroomtile(
                                              userName: contact?.displayName ??
                                                  contact.phones.first,
                                              // .replaceAll("_", ""),
                                              // .replaceAll(Constants.myName, ''),
                                              server: serverData,
                                              contact: contact,
                                              image: imageurl),
                                          Container(
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            margin: EdgeInsets.only(left: 90),
                                            decoration: BoxDecoration(
                                              color: Colors.yellow,
                                              border: Border(
                                                bottom: BorderSide(
                                                    color: Colors.grey,
                                                    width: 1),
                                              ),
                                            ),
                                          )
                                        ],
                                      );
                                    }),
                              ],
                            ),
                          )
                        : Center(child: CustomprogressIndicator());
                  })

              : Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Happy to see you here. \n Start messaging.',style: TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,),
                ],
              );
        });
    //     : Center(child: CustomprogressIndicator())
    // : Center(child: CustomprogressIndicator());
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
              backgroundColor: Color(0xff028090),
              actions: [
                Container(
                    padding: EdgeInsets.symmetric(horizontal: 2),
                    child: IconButton(
                      icon: Icon(
                        Icons.logout,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        loginStore.signOut(context);

                        print("about to logout");
                      },
                    )),
                Container(
                    padding: EdgeInsets.symmetric(horizontal: 0),
                    child: IconButton(
                        icon: Icon(
                          Icons.face_retouching_natural,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          // loginStore.signOut(context);
                          Navigator.push(
                              context,
                              CupertinoPageRoute(
                                  builder: (context) => ProfilePage()));
                          print("profile");
                        }))
              ]),
          body: Container(
            child: Center(child: ListView(children: [chatRoomList()])),
          
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

// profile show dialogBox

Widget _buildPopupDialog(BuildContext context, image, name) {
  return Center(
    child: Container(
        decoration: BoxDecoration(
          // border: Border.all(color: Colors.black),
          color: Colors.black,
        ),
        height: 300,
        width: 300,
        // color: Colors.black,
        child: Padding(
          padding: const EdgeInsets.all(2),
          child: Stack(
            children: [
              CachedNetworkImage(imageUrl: image),
              Container(
                  width: 300,
                  color: Colors.transparent.withOpacity(0.6),
                  child: Text(
                    name,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w500),
                  )),
            ],
          ),
        )),
  );
}

class Chatroomtile extends StatelessWidget {
  final String userName;
  final server;
  final contact;

  var image;

  Chatroomtile({this.userName, this.server, this.contact, this.image});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        print(contact.displayName);
        print("innnnnnn");
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return ChatScreen(server: server, contact: contact, image: image);
        }));
      },
      onDoubleTap: () {
        print("null");
      },
      child: ListTile(
        visualDensity: VisualDensity.adaptivePlatformDensity,
        // separatorBuilder: (BuildContext context, int index) => Divider(height: 1),
        leading: image != null
            ? GestureDetector(
                onTap: () {
                  print("opening image");
                  showDialog(
                    // barrierColor: Colors.black.withOpacity(0.5),
                    context: context,
                    builder: (BuildContext context) =>
                        _buildPopupDialog(context, image, userName),
                  );
                },
                child: CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.black,
                  child: ClipOval(
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: SizedBox(
                          height: 50,
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
                              : Image.asset('assets/img/pp.png')),
                    ),
                  ),
                ),
              )
            : CircleAvatar(
                radius: 30,
                backgroundColor: Colors.black,
                child: ClipOval(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: SizedBox(
                        height: 50,
                        width: 50,
                        child: Image.asset('assets/img/pp.png')),
                  ),
                ),
              ),
        title: Row(
           mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              userName,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(DateFormat.yMMMd()
                    .format(DateTime.fromMillisecondsSinceEpoch(server['time'])
                    ),style: TextStyle(fontSize: 11,color: Colors.black),
                    )
          ],
        ),

        subtitle: Padding(
          padding: const EdgeInsets.only(top:10.0),
          child: Row(
            
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
  server['lastMessage']!=null? ( server['lastMessage'].toString().length>24)?Text(
                server['lastMessage'].toString().substring(0,24)+'...',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14,color: Colors.grey),
              ): Text(
                server['lastMessage'].toString(),
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14,color: Colors.grey),
              )
              :Container(),

              Text(DateFormat.jm()
                    .format(DateTime.fromMillisecondsSinceEpoch(server['time'])
                    ),style: TextStyle(fontSize: 11,color: Colors.black),
                    )
            ],
          ),
        ),
      ),
    );
  }
}
