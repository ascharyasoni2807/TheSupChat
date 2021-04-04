

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Candidate {
    String uid;
   String phoneNumber;
   File image;
   static List data;
   List users = [];
  final foundusers = [];
  final phonenumber = [];
   Map hashmap = Map();
    final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Iterable 
  Candidate();

  Future<void> getContacts() async {
    final Iterable<Contact> contacts = await ContactsService.getContacts(
      withThumbnails: false,
    );

    // final contacts =  _contacts.toList();
   
  
    contacts.forEach((element) {
      element.phones.forEach((_element) {
        hashmap[_element.value.replaceAll(new RegExp(r'[\)\(\-\s]+'), "")] = element;
      });
      phonenumber.addAll(element.phones.map((e) => e.value.replaceAll(new RegExp(r'[\)\(\-\s]+'), "")));
    });
     await FirebaseFirestore.instance.collection("ChatRoom/${_auth.currentUser.phoneNumber.toString()}/ListUsers")
        .get()
        .then((QuerySnapshot querySnapshot)  {
      querySnapshot.docs.forEach((result) async{
        // print(result.data());
        final Map value = result.data();
              if (phonenumber.contains(value['chatroomId'])) {
          foundusers.add({
            "serverData": value,
            "phoneData": hashmap[value['chatroomId']]
          });
       
         
      //   await FirebaseFirestore.instance
      //   .collection("users")
      //   .get()
      //   .then((QuerySnapshot querySnapshot) {
      // querySnapshot.docs.forEach((userresult) {
      //    final Map uservalue = userresult.data();

     
      //      }}
      //      );
      //      }
      //      );
        }
      });
    });
  
   print(foundusers);
    //  print(  foundusers[0]["phoneData"].displayName);
  }

  foundUsers(phoneNumberIn) {
    return foundusers.firstWhere((element) {
    return  element["phoneData"].phones.any( (value){
      return value.value ==  phoneNumberIn;
    });
    });
  }
 
}



final  singelTonUsers = Candidate();