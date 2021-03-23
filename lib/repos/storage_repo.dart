import 'dart:io';
import 'package:path/path.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:thegorgeousotp/repos/candidate.dart';
import 'package:path_provider/path_provider.dart';

class StorageRepo{
 File profileImage;
 final picker = ImagePicker();
 List<firebase_storage.UploadTask> _uploadTasks = [];

 
 Future uploadPic(File file ) async {
 String a;
 profileImage = file;
 print(file);

  a = '+18888888888.jpg';
  print(a);
 

  if (file!=null){
    firebase_storage.Reference reference =
        firebase_storage.FirebaseStorage.instance.ref().child('$a');
    firebase_storage.UploadTask uploadTask = reference.putFile(file );
    firebase_storage.TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => print('complete'));
    print(uploadTask.snapshot);    }
    print(Candidate().uid );
    print('completed');
    
 }





}