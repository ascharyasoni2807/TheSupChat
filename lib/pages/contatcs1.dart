import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:theproject/firebasestorage/databsemethods.dart';
import 'package:theproject/pages/chatScreen.dart';
import 'package:theproject/repos/customfunctions.dart';
import 'package:theproject/theme.dart';
import 'package:theproject/repos/storage_repo.dart';

class ContactsPage extends StatefulWidget {
  @override
  _ContactsPageState createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  final FirebaseFirestore _auth = FirebaseFirestore.instance;
  Iterable<Contact> _contacts;
  // QuerySnapshot dbcontacts;
  List users = [];
  final foundusers = [];
  final phonenumber = [];
  bool isbuilding = false;

  List<Contact> contacts = [];
  List<Contact> contactsFiltered = [];
  Map<String, Color> contactsColorMap = new Map();
  TextEditingController searchController = new TextEditingController();
  @override
  void initState() {
    getContacts();
    super.initState();
  }

  String flattenPhoneNumber(String phoneStr) {
    return phoneStr.replaceAllMapped(RegExp(r'^(\+)|\D'), (Match m) {
      return m[0] == "+" ? "+" : "";
    });
  }

  createChatRoom(server, contact) async {
    var currentUid = await StorageRepo().getCurrentUidofUser();

    print(server["uid"]);

    List<String> users = [server["uid"], currentUid.uid];
    List<String> phones = [
      server["phoneNumberWithCountry"],
      currentUid.phoneNumber
    ];
    final selfPhoneNumber = CustomFunctions().shortPhoneNumber(currentUid.phoneNumber);
    print(phones);
    print(users);
    Map<String, dynamic> selfchatRoomMap = {
      "users": users,
      "chatroomIdWithCountry": server["phoneNumberWithCountry"].toString(),
      "phoneNumber" : server["phoneNumber"].toString(),
      "uid":server["uid"],
      "time" : DateTime.now().millisecondsSinceEpoch,
      "profilePicture" : server["profilePicture"].toString(),
    };
    print(users.reversed.toList());
    Map<String, dynamic> secondchatRoomMap = {
      "users": users.reversed.toList(),
      "chatroomIdWithCountry": currentUid.phoneNumber,
      "phoneNumber" :selfPhoneNumber,
       "uid":currentUid.uid,
      "time" : DateTime.now().millisecondsSinceEpoch,
      "profilePicture" : currentUid.photoURL
    };
    DatabaseMethods()
        .createChatRoom(
            server["uid"],
            server["phoneNumberWithCountry"].toString(),
            selfchatRoomMap,
            secondchatRoomMap
            )
        .then((value) {
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return ChatScreen(server: server, contact: contact);
      }));
    });
    print("inserver");
  }

  Future<void> getContacts() async {
    final Iterable<Contact> contacts = await ContactsService.getContacts(
      withThumbnails: false,
    );

    // final contacts =  _contacts.toList();
    Map hashmap = Map();
  
    contacts.forEach((element) {
      element.phones.forEach((_element) {
        hashmap[_element.value.replaceAll(new RegExp(r'[\)\(\-\s]+'), "")] = element;
      });
      phonenumber.addAll(element.phones.map((e) => e.value.replaceAll(new RegExp(r'[\)\(\-\s]+'), "")));
    });
    print(hashmap);
    await FirebaseFirestore.instance
        .collection("users")
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((result) {
        // print(result.data());
        final Map value = result.data();
        bool a = phonenumber.contains(value['phoneNumberWithCountry']);
        bool b = phonenumber.contains(value['phoneNumber']);

        if (phonenumber.contains(value['phoneNumberWithCountry']) ||  phonenumber.contains(value['phoneNumber']) ) {
          print(value['phoneNumberWithCountry']);
          print(value['phoneNumber']);
          foundusers.add({
            "serverData": value,
            "phoneData":  a? hashmap[value['phoneNumberWithCountry']] : hashmap[value['phoneNumber']]
          });
         
        
          print("aaaaaaaaaaaaaaaaaaaaaaaaaaaaaa");
          print(value);
        }
      });
    });
    print(foundusers);
    //  print(  foundusers[0]["phoneData"].displayName);
    setState(() {
      isbuilding = true;
    });
  }

 

  Icon actionIcon = new Icon(Icons.search);
  Widget appBarTitle = new Text("Select Contact",style: TextStyle(color: Colors.white
  ),);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor:MyColors.maincolor,
        title: appBarTitle,
        actions: [
          new IconButton(
            icon: actionIcon,
            onPressed: () {
              setState(() {
                if (this.actionIcon.icon == Icons.search) {
                  this.actionIcon = Icon(Icons.close);
                  this.appBarTitle =  TextField(
                    cursorHeight: 20,
                    cursorColor: Colors.white,
                    autofocus: true,
                    autocorrect: false,
                    style: TextStyle(color: Colors.white, fontSize: 18),
                    // controller: searchController,
                    decoration: new InputDecoration(
                        hintText: "Search...",
                        hintStyle: new TextStyle(color: Colors.white)),
                  );
                } else {
                  this.actionIcon = new Icon(Icons.search);
                  this.appBarTitle = new Text("Select Contact",style: TextStyle(color: Colors.white),);

                }
              });
            },
          ),
        ],
      ),
      body: foundusers != null
          ? isbuilding
              ? Container(
                // color: Color(0xff03506f).withOpacity(0.3),
                // Colors.blueGrey.withOpacity(0.5),
                  child: Column(
                    children: [
                      Expanded(
                          child: foundusers != null
                              ? ListView.builder(
                                  itemCount: foundusers.length ?? 0,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    final _contact =
                                        foundusers.elementAt(index);
                                    Contact contact = _contact["phoneData"];
                                    final serverData = _contact["serverData"];
                                    //  setState(() {
                                    //      isbuilding = true;
                                    //  });

                                    return contact != null
                                        ? Container(
                                            padding: EdgeInsets.only(top: 2),
                                            child: InkWell(
                                              onTap: () {
                                                createChatRoom(
                                                    serverData, contact);
                                              },
                                              onDoubleTap: () {},
                                              splashColor: Colors.grey,
                                              child: ListTile(
                                                minVerticalPadding: 5,
                                                contentPadding:
                                                    const EdgeInsets.symmetric(
                                                  vertical: 2,
                                                ),
                                                leading: serverData[
                                                            "profilePicture"] !=
                                                        null
                                                    ? CircleAvatar(
                                                        radius: 50,
                                                        backgroundColor:
                                                            Colors.black,
                                                        child: ClipOval(
                                                          child: AspectRatio(
                                                            aspectRatio: 1,
                                                            child: SizedBox(
                                                                height: 20,
                                                                width: 20,
                                                                child:
                                                                    CachedNetworkImage(
                                                                  imageUrl:
                                                                      serverData[
                                                                          "profilePicture"],
                                                                  progressIndicatorBuilder: (context,
                                                                          url,
                                                                          downloadProgress) =>
                                                                      CircularProgressIndicator(
                                                              strokeWidth: 2, backgroundColor: MyColors.maincolor, valueColor: AlwaysStoppedAnimation<Color>(MyColors.maincolor)  ,        
                                                                          value:
                                                                              downloadProgress.progress),
                                                                  errorWidget: (context,
                                                                          url,
                                                                          error) =>
                                                                      Icon(Icons
                                                                          .error),
                                                                )),
                                                          ),
                                                        ),
                                                      )
                                                    : CircleAvatar(
                                                        child: Text(
                                                            contact.initials()),
                                                        backgroundColor:
                                                            MyColors.maincolor,
                                                      ),
                                                title: Text(
                                                  contact.displayName,
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 18),
                                                ),
                                                subtitle: Text(
                                                  contact.phones.length != 0
                                                      ? serverData["phoneNumber"]
                                                      : '',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                //This can be further expanded to showing contacts detail
                                                // onPressed().
                                              ),
                                            ),
                                          )
                                        : SizedBox.shrink();
                                  },
                                )
                              : Container(
                                  //  color: Colors.blueGrey.withOpacity(0.5),
                                child: Center(
                                    child: progressIndicator()),
                              ))
                    ],
                  ),
                )
              : Container(
                   color: Colors.blueGrey.withOpacity(0.5),
                child: Center(child: progressIndicator()))
          : Container(
               color: Colors.blueGrey.withOpacity(0.5),
            child: Center(child:  progressIndicator())),
    );
    
  }
  
}

class progressIndicator  extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CircularProgressIndicator(strokeWidth: 2, backgroundColor: MyColors.maincolor, valueColor: AlwaysStoppedAnimation<Color>(Colors.white),);
  }
}