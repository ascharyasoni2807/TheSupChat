import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path/path.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:theproject/firebasestorage/databsemethods.dart';
import 'package:theproject/providers/imageuploadprovider.dart';
// import 'package:theproject/repos/candidate.dart';
import 'package:path_provider/path_provider.dart';
import 'package:theproject/widgets/gradientbar.dart';
import 'package:image/image.dart' as Im; 

class StorageRepo{
 File profileImage;
 final picker = ImagePicker();
 List<firebase_storage.UploadTask> _uploadTasks = [];
final _scaffoldKey = GlobalKey<ScaffoldState>();
final FirebaseAuth _auth = FirebaseAuth.instance;
 String downloadUrl;
 
 
 Future uploadPic(File file,ImageUploadProvider _imageUploadProvider ) async {
 String a;


 profileImage = file;
 print(file);
 var user = await _auth.currentUser;
  print(a);

 _imageUploadProvider.setToLoading();
  if (file!=null){
    firebase_storage.Reference reference =
        firebase_storage.FirebaseStorage.instance.ref().child("user/profiles/${user.uid}");
    firebase_storage.UploadTask uploadTask = reference.putFile(file );
    firebase_storage.TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => 
    
    print('complete'));
     downloadUrl = await taskSnapshot.ref.getDownloadURL();
   await  user.updateProfile(photoURL: downloadUrl);
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
 _imageUploadProvider.setToIdle();
  return downloadUrl;
 }




Future uploadChatPic(File file , otherUid,basenames, ImageUploadProvider _imageUploadProvider) async {
var user = await _auth.currentUser;
var imageurl;


final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;


_imageUploadProvider.setToLoading();
 startUpload(reference) async {
  firebase_storage.UploadTask uploadTask = reference.putFile(file);
    firebase_storage.TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() =>  print('complete'));
   
    imageurl  = await taskSnapshot.ref.getDownloadURL();
    print(uploadTask.snapshot); 
 _imageUploadProvider.setToIdle();
    return imageurl;

 }

   var ran= Random();
   int random = ran.nextInt(999999);
  firebase_storage.Reference reference1 =  firebase_storage.FirebaseStorage.instance.ref().child("chatImages/${otherUid}_${user.uid}");
        // firebase_storage.FirebaseStorage.instance.ref().child("chatImages/${user.uid}_${otherUid}/${user.uid}"+"_"+otherUid);
   firebase_storage.Reference reference2 =firebase_storage.FirebaseStorage.instance.ref().child("chatImages/${user.uid}_${otherUid}/${user.uid}"+"_"+otherUid+random.toString()+"_"+basenames);
  if(reference1==null && reference2==null ) {

    firebase_storage.Reference reference =  firebase_storage.FirebaseStorage.instance.ref().child("chatImages/${otherUid}_${user.uid}/${user.uid}"+"_"+otherUid+random.toString()+"_"+basenames);
    imageurl= startUpload(reference);
  }else {
  firebase_storage.Reference reference =firebase_storage.FirebaseStorage.instance.ref().child("chatImages/${user.uid}_${otherUid}/${user.uid}"+"_"+otherUid+random.toString()+"_"+basenames); 
   imageurl = startUpload(reference);
  }
 return imageurl;
 
 }


 getCurrentUidofUser() async {
   var user = await _auth.currentUser;
   return user;
 }


  // downloadFile () async {
  //  downloaded = await 

  // }








final Dio dio = Dio();
  bool loading = false;
  double progress = 0;

Future<bool> _requestPermission(Permission permission) async {
    if (await permission.isGranted) {
      return true;
    } else {
      var result = await permission.request();
      if (result == PermissionStatus.granted) {
        return true;
      }
      else{
        result=await permission.request();
      }
    }
    return false;
  }
Future<bool> saveFile(String url, String date,basenames) async {
    Directory directory;
     final random = Random();
    int randoms = random.nextInt(99999);
    try {
      if (Platform.isAndroid) {
        if (await _requestPermission(Permission.storage)) {
          directory = await getExternalStorageDirectory();
          String newPath = "";
          print(directory);
          List<String> paths = directory.path.split("/");
          for (int x = 1; x < paths.length; x++) {
            String folder = paths[x];
            if (folder != "Android") {
              newPath += "/" + folder;
            } else {
              break;
            }
          }
          newPath = newPath + "/SupChat/Received";
          directory = Directory(newPath);
        } else {
          return false;
        }
      } else {
        if (await _requestPermission(Permission.photos)) {
          directory = await getExternalStorageDirectory();
        } else {
          return false;
        }
      }
      File saveFile = File(directory.path + "/${basenames}");
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }
      if (await directory.exists()) {
  
        await dio.download(url, saveFile.path,
            onReceiveProgress: (value1, value2) {

            });
        if (Platform.isIOS) {
          // await ImageGallerySaver.saveFile(saveFile.path,
          //     isReturnPathOfIOS: true);
        }
        return true;
      }
      return false;
    } catch (e) {
      print(e);
      return false;
    }
  }



}