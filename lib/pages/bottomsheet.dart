
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:theproject/firebasestorage/databsemethods.dart';
import 'package:theproject/providers/imageuploadprovider.dart';
import 'package:theproject/theme.dart';

class BottomSheetExample extends StatelessWidget {
  

  final imageUploadProvider;
  final nameofuser;
  BottomSheetExample({this.imageUploadProvider,this.nameofuser});
  
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
        maxLength: 12,
        decoration: InputDecoration(
    hintText: "Enter Name...",
     ),
        autofocus: true,
        controller: nameofuser,
        // onChanged: (value) {
        //   print(value);
        //   // value = text;
        // },
        ),
        // ignore: deprecated_member_use
        RaisedButton(
          color: MyColors.maincolor,
          onPressed: () async {
            imageUploadProvider.setToLoading();
            print("inininnini");
            DatabaseMethods().saveName(nameofuser.value.text);
            print(nameofuser.value.text);
            // print( nameofuser.value.text.split());
            if(nameofuser.value.text.trim().toString().isNotEmpty){
                     print("udruththdhtdhjtdj");
                              await DatabaseMethods().updateNameofuser(nameofuser.value.text);
                                imageUploadProvider.setToIdle(); 
                              Navigator.pop(context);
                  
            }else{
                imageUploadProvider.setToIdle(); 
                              print("nothing");
            }
             print("hello");
              //  Navigator.pop(context);
             }, 
          child: Text("Update And Save",style: TextStyle(color: Colors.white),)),
        
      
        ],
      ),
    ),
      
    );
  }
}