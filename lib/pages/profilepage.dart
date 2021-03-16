import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:thegorgeousotp/repos/candidate.dart';
import 'package:thegorgeousotp/repos/storage_repo.dart';
import 'package:thegorgeousotp/theme.dart';


class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
   File _image;
  final picker = ImagePicker();
  //  List<firebase_storage.UploadTask> _uploadTasks = [];
  Future getImage() async {
    var pickedFile = await picker.getImage(source: ImageSource.gallery );

    setState(()  {
      if (pickedFile != null)  {
        _image = File(pickedFile.path);
         _cropImage(pickedFile.path);
       
       
      } else {
        print('No image selected.');
      }
    });
  }
  _cropImage(filePath) async {
    File croppedImage = await ImageCropper.cropImage(
        sourcePath: filePath,
        // maxWidth: 1080,
        // maxHeight: 1080,
    );
     if (croppedImage != null) {
        _image = croppedImage;
         StorageRepo().uploadPic(_image);
          print('completed' );
      setState(() {
        
      });
    }
}

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyColors.maincolor ,
        title: Text('Profile Info'),
      ),
      body:Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                height: 20.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Align(
                    alignment: Alignment.center,
                    child: GestureDetector(
                      onTap: getImage,
                                          child: CircleAvatar(
                        radius: 100,
                        
                        backgroundColor: Colors.black,
                        child: ClipOval(
                          
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: new SizedBox(
                              
                              width:double.infinity,
                              height: double.infinity,
                              child: (_image!=null)?Image.file(
                                 
                                _image,
                                fit: BoxFit.fill,
                              ):Image.network(
                                "https://firebasestorage.googleapis.com/v0/b/hellochat-e7e2e.appspot.com/o/image_cropper_1615918134209.jpg?alt=media&token=23924540-0773-40b1-be38-7ced1ddec1c4",
                                fit: BoxFit.fill,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),]
                  ), 
                SizedBox(height: 50),
                  Container(
                    width: 300,
                    height: 50,
                    child: Card(
                      color: MyColors.maincolor,
                      child: Center(child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal:8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text('Name :' , style: TextStyle(color :Colors.white,fontWeight: FontWeight.bold),),
                          ],
                        ),
                      )),
                    ),
                  ),
                  Container(
                    width: 300,
                    height: 50,
                    child: Card(
                      color: MyColors.maincolor,
                      child: Center(child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal:8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text('PhoneNumber:' , style: TextStyle(color :Colors.white,fontWeight: FontWeight.bold),),
                          ],
                        ),
                      )),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20 , vertical : 20),
                    child: Container(
                      height:50,
                      // color: Colors.black
                      child: CupertinoTextField(
                                    
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    decoration: BoxDecoration(
                                      
                                      color: Colors.white,
                                      border: Border.all(),
                                      borderRadius: const BorderRadius.all(Radius.circular(10))
                                    ),
                                    // controller: phoneController,
                                    
                                    clearButtonMode: OverlayVisibilityMode.always,
                                    // keyboardType: ,
                                    maxLines: 1,
                                    placeholder: 'Provide your name here',
                                  ),
                    ),
                  )
                  
                  ]),
      floatingActionButton: FloatingActionButton(
        onPressed: getImage,
        backgroundColor: MyColors.maincolor,
        tooltip: 'Next Page',
        child: Icon(Icons.forward),
      ),
    );
  }
}
//   File _image;
//  final picker = ImagePicker();

//    Future getImage() async {
//     final pickedFile = await picker.getImage(source: ImageSource.camera);

//     setState(() {
//       if (pickedFile != null) {
//         _image = File(pickedFile.path);
//       } else {
//         print('No image selected.');
//       }
//     });}

//  Future getImageGallery() async {
//     final pickedFile = await picker.getImage(source: ImageSource.gallery);

//     setState(() {
//       if (pickedFile != null) {
//         _image = File(pickedFile.path);
//       } else {
//         print('No image selected.');
//       }
//     });
// }


// void _showPicker(context) {
//   showModalBottomSheet(
//       context: context,
//       builder: (BuildContext bc) {
//         return SafeArea(
//           child: Container(
//             child: new Wrap(
//               children: <Widget>[
//                 new ListTile(
//                     leading: new Icon(Icons.photo_library),
//                     title: new Text('Photo Library'),
//                     onTap: () {
//                       getImage();
//                       Navigator.of(context).pop();
//                     }),
//                 new ListTile(
//                   leading: new Icon(Icons.photo_camera),
//                   title: new Text('Camera'),
//                   onTap: () {
//                     getImageGallery();
//                     Navigator.of(context).pop();
//                   },
//                 ),
//               ],
//             ),
//           ),
//         );
//       }
//     );
// }
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//           body:Column(
//       children: <Widget>[
//         SizedBox(
//           height: 32,
//         ),
//         Center(
//           child: GestureDetector(
//             onTap: () {
//               _showPicker(context);
//             },
//             child: CircleAvatar(
//               radius: 55,
//               backgroundColor: Color(0xffFDCF09),
//               child: _image != null
//                   ? ClipRRect(
//                       borderRadius: BorderRadius.circular(50),
//                       child: Image.file(
//                         _image,
//                         width: 100,
//                         height: 100,
//                         fit: BoxFit.fitHeight,
//                       ),
//                     )
//                   : Container(
//                       decoration: BoxDecoration(
//                           color: Colors.grey[200],
//                           borderRadius: BorderRadius.circular(50)),
//                       width: 100,
//                       height: 100,
//                       child: Icon(
//                         Icons.camera_alt,
//                         color: Colors.grey[800],
//                       ),
//                     ),
//             ),
//           ),
//         )
//       ],
//     ),
//     );
//   }
// }