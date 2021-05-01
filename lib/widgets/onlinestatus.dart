




import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:theproject/enum/userState.dart';
import 'package:theproject/utilities.dart/utility.dart';

import '../firebasestorage/databsemethods.dart';

class OnlineStatus extends StatelessWidget {
  final server;
 OnlineStatus({this.server});

  

  @override
  Widget build(BuildContext context) {
     var a;
    
    getStatus(int state) {
      switch(Utils.numToState(state)){
        case UserState.Offline:
          return 'offline';
        case UserState.Online:
          return 'online';
        default :
          return 'offline';
      }
    }
    return StreamBuilder<DocumentSnapshot> (
     stream:  DatabaseMethods().getUserStream(server['uid']),
   builder: (context,snapshot){
    
    if(snapshot.hasData && snapshot.data.data!=null){
  a =snapshot.data.data();
     print(snapshot.data.data());
return Text(getStatus(a['state'])  ,style: TextStyle(
      color: Colors.white,fontStyle: FontStyle.italic,fontSize: 12),);
   }
   return Text('');
    

  });
}}