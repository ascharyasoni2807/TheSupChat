import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:thegorgeousotp/pages/contacts.dart';
import 'package:thegorgeousotp/pages/profilepage.dart';
import 'package:thegorgeousotp/stores/login_store.dart';
import 'package:thegorgeousotp/theme.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import "package:thegorgeousotp/pages/permission.dart";


class HomePage extends StatefulWidget {
  const HomePage({Key key}) : super(key: key);
  @override
  _HomePageState createState() => _HomePageState();
}


class _HomePageState extends State<HomePage> {

Stream chatroomstream;

LoginStore loginStore = LoginStore();
  @override
  void initState() {
    // TODO: implement initState
    getUserInfo();
    super.initState();
  }
 Widget chatRoomList() {
    return StreamBuilder<QuerySnapshot>(
        stream: chatroomstream,
        builder: ( BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          
          return snapshot.hasData
              ? SingleChildScrollView(
                physics:BouncingScrollPhysics(),
                              child: Column(
                  children: [
                    ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                        // scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        itemCount: snapshot.data.docs.length,
                        itemBuilder: (context, index) {
                          
                          return Chatroomtile(
                            
                              userName: snapshot.data.docs[index]
                                  .data()["chatroomId"]
                                  .toString()
                                  .replaceAll("_", ""),
                                  // .replaceAll(Constants.myName, ''),
                              chatRoomId:
                                  snapshot.data.docs[index].data()["chatroomId"],
                              image:  snapshot.data.docs[index].data()["image"]
                            );
                        }),
                  ],
                ),
              )
                  
              : CircularProgressIndicator();

              
        });
       
  }

newstateup()async{
var datareference = FirebaseFirestore.instance.collection("chatroomId");

}

// listenplayers(roomTokenn) async {
//     var databseReference = FirebaseFire.instance
//         .reference()
//         .child('/rooms/room_' + widget.roomToken.toString() + '/players');
//     print(roomTokenn);
//     print("listenplayers================");
//     final roomtokens = roomTokenn;
//     databseReference.once().then((DataSnapshot snapshot) {
//       final Map value = snapshot.value;
//       setState(() {
//         players = value.values.toList();
//       });
//     });
//     setState(() {});
//   }


getUserInfo() async {
    print('heeloji');
    
   var value = await FirebaseFirestore.instance
        .collection("ChatRoom")
        .where("users", arrayContains: 'commando')
        .snapshots();
      setState(() {
        chatroomstream = value;}
      );
    
  }


  @override
  Widget build(BuildContext context) {
    return Consumer<LoginStore>(
      builder: (_, loginStore, __) {
        return Scaffold(
          
          backgroundColor: Colors.white,
          appBar: AppBar(
           title: Text("UpChat", style: TextStyle(color: Colors.white),),
           backgroundColor: MyColors.buttoncolor,
           actions: [
              Container(
              padding: EdgeInsets.symmetric(horizontal: 2),
              child: IconButton(
                icon: Icon(Icons.logout),
                onPressed: () {
                // loginStore.signOut(context);
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
                Navigator.push(context, MaterialPageRoute(builder:(context) => ProfilePage()));
                print("profile");
                }))
              ]
               ),
                        body: Center(
                          child: ListView(children: [
                                chatRoomList(),
                               ])     ),
                               floatingActionButton: FloatingActionButton(
                                 onPressed: ()async {
                                ContactPermission().permissioncheck(context);
                                   print("hello supchat");
                                 },backgroundColor: MyColors.maincolor,
                                 splashColor: MyColors.buttoncolor,
                                 elevation: 2 ,
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
    return GestureDetector(
      onTap: () {
        print(chatRoomId);
        print("innnnnnn");
        // Navigator.push(context,
        //     MaterialPageRoute(builder: (context) => Chatscreen(chatRoomId)));
      },
      child: Column(
        
        children: [
          Container(
             decoration: BoxDecoration(
              //  color:Colors.blue,
      border: Border(bottom: BorderSide(color: Colors.black26))),
            // h: Colors.black26,
            padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
            child: Row(
              children: [
                Container(
                  //
                  height: 50.0,
                  alignment: Alignment.center,
                  width: 50,
                  decoration: BoxDecoration(
                      color: Colors.orange[600],
                      borderRadius: BorderRadius.circular(40)),
                  child:(image!=null) ? Image.network(image)  : Text("${userName.substring(0, 1).toUpperCase()}",
                      style: GoogleFonts.hammersmithOne(
                          textStyle: TextStyle(
                              color: Colors.black,
                              letterSpacing: 3,
                              fontSize: 20))),
                  // Image.network("https://www.pikpng.com/pngl/m/138-1383747_colourful-small-round-png-circle-clipart.png")
                  
                ),
                SizedBox(
                  width: 10,
                ),
                Text(userName,
                    style: TextStyle(
                            color: Colors.black, fontSize: 18 , fontWeight: FontWeight.bold))
              ],
            ),
          ),
          //  Divider(thickness: 0,)
        ],
      ),
    );
  }
}