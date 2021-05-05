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
//     var currentUid = await StorageRepo().getCurrentUidofUser();
//   var a;
//    var b;
//    var time1;
//    var time2;
//     print(server["uid"]);

// try{
//  await FirebaseFirestore.instance
//           .collection("ChatRoom")
//           .doc( CustomFunctions().shortPhoneNumber(currentUid.phoneNumber) )
//           .collection("ListUsers")
//           .doc((currentUid.uid + '_' + server["uid"]))
//           .collection("Chats")
//           .orderBy("time", descending: true)
//           .limit(1)
//           .get()
//           .then((value) async {
//         a = value.docs.first.data();
//         print(a);
//          time1=a['time'];

//         a=a['message'];
       
//   await FirebaseFirestore.instance
//           .collection("ChatRoom")
//           .doc(server['phoneNumber'])
//           .collection("ListUsers")
//           .doc((server['uid'] + "_" + currentUid.uid))
//           .collection("Chats")
//           .orderBy("time", descending: true)
//           .limit(1)
//           .get()
//           .then((value) async {
//         b= value.docs.first.data();
//      print(b);
//         time2=b['time'];
//         b=b['message'];
     
//        }
//           );


//         });
// // print(a+b);
// }catch(e){
//   print(e);
// }
   


//     List<String> users = [server["uid"], currentUid.uid];
//     List<String> phones = [
//       server["phoneNumberWithCountry"],
//       currentUid.phoneNumber
//     ];
//     final selfPhoneNumber = CustomFunctions().shortPhoneNumber(currentUid.phoneNumber);
//     print(phones);
//     print(users);
//     Map<String, dynamic> selfchatRoomMap = {
//       "users": users,
//       "chatroomIdWithCountry": server["phoneNumberWithCountry"].toString(),
//       "phoneNumber" : server["phoneNumber"].toString(),
//       "uid":server["uid"],
//       "time" : time1!=null? time1:DateTime.now().millisecondsSinceEpoch,
//       "lastMessage": a!=null? a:'',
//       "profilePicture" : server["profilePicture"].toString(),
//     };
//     print(users.reversed.toList());
//     Map<String, dynamic> secondchatRoomMap = {
//       "users": users.reversed.toList(),
//       "chatroomIdWithCountry": currentUid.phoneNumber,
//       "phoneNumber" :selfPhoneNumber,
//        "uid":currentUid.uid,
//       "time" : time2!=null?time2:DateTime.now().millisecondsSinceEpoch,
//       "lastMessage": b!=null?b:'',
//       "profilePicture" : currentUid.photoURL
//     };

    
//     DatabaseMethods()
//         .createChatRoom(
//             server["uid"],
//             server["phoneNumberWithCountry"].toString(),
//             selfchatRoomMap,
//             secondchatRoomMap
//             )
//         .then((value) {
//       Navigator.push(context, MaterialPageRoute(builder: (context) {
//         return ChatScreen(server: server, contact: contact);
//       }));
//     });
     Navigator.push(context, MaterialPageRoute(builder: (context) {
        return ChatScreen(server: server, contact: contact);
      }));
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
          // learnt new thing
           foundusers.sort((a,b) => a['phoneData'].displayName.toString().toLowerCase().compareTo(b['phoneData'].displayName.toString().toLowerCase()));
        }
      });
    });
    print(foundusers);
    //  print(  foundusers[0]["phoneData"].displayName);
    setState(() {
      isbuilding = true;
    });
  }

// var items;
// void filterSearchResults(String query) {
//     List<dynamic> dummySearchList ;
//     dummySearchList.addAll(foundusers);
//     if(query.isNotEmpty) {
//       List<dynamic> dummyListData ;
//       dummySearchList.forEach((item) {
//         if(item.contains(query)) s{
//           dummyListData.add(item);
//         }
//       });
//       setState(() {
//         items.clear();
//         items.addAll(dummyListData);
//       });
//       return;
//     } else {
//       setState(() {
//         items.clear();
//         items.addAll(foundusers);
//       });
//     }

//   }
 

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
                    onChanged: (value){
                      print(value);
                      // filterSearchResults(value);
                    },
                    decoration: new InputDecoration(
                        hintText: "developing this feature",
                        hintStyle: new TextStyle(color: Colors.white30,)),
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
                        //  contact.displayName.contains()==searchController;
                      return contact != null
                          ? Container(
                                padding: EdgeInsets.only(top:1),
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
                                          fontSize: 18,fontFamily: 'Crimson'),
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