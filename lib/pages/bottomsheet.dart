
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:theproject/firebasestorage/databsemethods.dart';
import 'package:theproject/theme.dart';

class BottomSheetExample extends StatelessWidget {

  TextEditingController nameofuser = TextEditingController();
 
  @override
  Widget build(BuildContext context) {
    return Container(
       decoration : BoxDecoration(
      //  color: Colors.blue,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(20),
        topRight:Radius.circular(30)) 
   ),
    child: Container(
       
      padding: EdgeInsets.all(20),
      
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
      TextField(
        decoration: InputDecoration(
    hintText: "Enter Name...",
     ),
        autofocus: true,
        controller: nameofuser,
        onChanged: (text) {
          print(text);
          // value = text;
        },
        ),
        // ignore: deprecated_member_use
        RaisedButton(
          color: MyColors.maincolor,
          onPressed: () async {
            Center(child: CircularProgressIndicator());
            print("inininnini");
            DatabaseMethods().saveName(nameofuser.value.text);
         await DatabaseMethods().updateNameofuser(nameofuser.value.text);
             print("hello");
               Navigator.pop(context);
             }, 
          child: Text("Update And Save",style: TextStyle(color: Colors.white),)),
        
      
        ],
      ),
    ),
      
    );
  }
}