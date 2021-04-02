import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path/path.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:thegorgeousotp/firebasestorage/databsemethods.dart';
import 'package:thegorgeousotp/providers/imageuploadprovider.dart';
import 'package:thegorgeousotp/repos/candidate.dart';
import 'package:path_provider/path_provider.dart';
import 'package:thegorgeousotp/widgets/gradientbar.dart';
import 'package:image/image.dart' as Im; 

class StorageRepo{
 File profileImage;
 final picker = ImagePicker();
 List<firebase_storage.UploadTask> _uploadTasks = [];
final _scaffoldKey = GlobalKey<ScaffoldState>();
final FirebaseAuth _auth = FirebaseAuth.instance;
 String downloadUrl;
 
 Future uploadPic(File file ) async {
 String a;
 
 profileImage = file;
 print(file);
 var user = await _auth.currentUser;
  print(a);
  if (file!=null){
    firebase_storage.Reference reference =
        firebase_storage.FirebaseStorage.instance.ref().child("user/profiles/${user.uid}");
    firebase_storage.UploadTask uploadTask = reference.putFile(file );
    firebase_storage.TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => 
    
    print('complete'));
     downloadUrl = await taskSnapshot.ref.getDownloadURL();
    print(uploadTask.snapshot); 
    //  _scaffoldKey.currentState.showSnackBar( SnackBar(content: Text("Profile Pic updated")));  
       }
    print('completed');
 
 //uploading in users data
    FirebaseFirestore.instance
  .collection('users')
    .doc('${user.uid}')
     .update({
        "profilePicture" : downloadUrl.toString()
      });
  DatabaseMethods().updateProfilePictureinRTDB(user.uid, downloadUrl);

  return downloadUrl;
 }




Future uploadChatPic(File file , otherUid, ImageUploadProvider _imageUploadProvider) async {
var user = await _auth.currentUser;
var imageurl;


final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;


_imageUploadProvider.setToLoading();
  firebase_storage.Reference reference =
        firebase_storage.FirebaseStorage.instance.ref().child("chatImages/${user.uid}"+"_"+ otherUid);
    firebase_storage.UploadTask uploadTask = reference.putFile(file);
    firebase_storage.TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() =>  print('complete'));
    imageurl  = await taskSnapshot.ref.getDownloadURL();
    print(uploadTask.snapshot); 
 _imageUploadProvider.setToIdle();
    return imageurl;
 
  
    //  _scaffoldKey.currentState.showSnackBar( SnackBar(content: Text("Profile Pic updated")));  
 }


 getCurrentUidofUser() async {
   var user = await _auth.currentUser;
   return user;
 }


  // downloadFile () async {
  //  downloaded = await 

  // }




}