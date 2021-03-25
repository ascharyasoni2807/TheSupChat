import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path/path.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:thegorgeousotp/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thegorgeousotp/pages/home_page.dart';
import 'package:thegorgeousotp/repos/storage_repo.dart';
import 'package:thegorgeousotp/theme.dart';
import 'package:path_provider/path_provider.dart';


class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
   File _image;
   File localImage;
   File _profileimage;
   var profilepath;
  var picker = ImagePicker();
   final FirebaseAuth _auth = FirebaseAuth.instance;
 Directory appDocDir;




 var userPhotos;
      Future<void> getPhoto( ) async {
        var id = _auth.currentUser.uid;
        CircularProgressIndicator.adaptive();
        //query the user photo
        await FirebaseFirestore.instance.collection("users").doc(id).snapshots().listen((event) {
          setState(() {
            userPhotos = event.get("photoUrl");
            print(userPhotos);
          });
        });
      }


@override
void initState() { 
  super.initState();
  getPhoto();
  setState(() {
    
  });
 print(profilepath);
}
 
// documentdirectory(_image ,pathImage ,pickedFile)async {
//  print('houiiiugugiygu');
//  appDocDir =  await getApplicationDocumentsDirectory();
//  String appDocPath = appDocDir.path;
// final File localImage = await pickedFile.copy('$appDocPath/$pathImage');


// SharedPreferences prefs = await SharedPreferences.getInstance();
// prefs.setString('profile_image', localImage.path);

// setState(() {
//   profilepath = prefs.getString('profile_image'); 
// });

// setState(() {
//    _image = FileImage(File(prefs.getString('profile_image')));
// });
// print('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'+ profilepath);
// }

  //  getting selecting profile picture for user
  Future getImage() async {
    var pickedFile = await picker.getImage(source: ImageSource.gallery );
      if (pickedFile != null)  {
        _image = File(pickedFile.path);
         _cropImage(pickedFile.path);
        //  documentdirectory(_image ,pathimage,pickedFile);

      } else {
        print('No image selected.');
      }
    
  }
  //  croppinng and uploading profile picture
  _cropImage(filePath) async {
    File croppedImage = await ImageCropper.cropImage(
        sourcePath: filePath,
    );
     if (croppedImage != null)  {
        _image = croppedImage;

       await StorageRepo().uploadPic(_image) ;
         CircularProgressIndicator.adaptive();
          print('completed' );
      setState(() {
        _image = croppedImage;
      });
    }
}

@override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyColors.maincolor ,
        title: Text('Profile Info'
        )
      ),
      body:Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              // SizedBox(
              //   height: 20.0,
              // ),
              Container(
                height: MediaQuery.of(context).size.height*0.28,
                decoration: BoxDecoration(
                color: MyColors.maincolor,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(80.0),
                  bottomRight: Radius.circular(80.0),
                ),
              ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Align(
                      alignment: Alignment.center,
                      child: GestureDetector(
                        onTap: getImage,
                        child: CircleAvatar(
                          
                          radius: 70,
                          backgroundColor: Colors.black,
                          child: ClipOval(
                            child: AspectRatio(
                              aspectRatio: 1,
                              child: SizedBox(
                                width:double.infinity,
                                height: double.infinity,
                                child: (userPhotos!=null )?  Image.network(
                                 userPhotos,
                                  fit: BoxFit.fill,
                                )
                               : _image!=null? Image.file(
                                  _image,
                                  fit: BoxFit.fill,
                                ) :  CircularProgressIndicator.adaptive()
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),]
                    ),
              ), 
                SizedBox(height: 50),
                  // Container(
                  //   width: 300,
                  //   height: 60,
                  //   child: Card(
                  //     color: MyColors.maincolor,
                  //     child: Center(child: Column(
                  //       children: [
                  //         Padding(
                  //          padding: const EdgeInsets.symmetric(horizontal:8.0,vertical:10),
                  //           child: Row(
                  //             mainAxisAlignment: MainAxisAlignment.center,
                  //             crossAxisAlignment: CrossAxisAlignment.center,
                  //             children: [
                  //               Text('Name :' , style: TextStyle(color :Colors.white,fontWeight: FontWeight.bold),),
                  //               SizedBox(width:10),
                  //                Text('Ascharya Soni' , style: TextStyle(color :Colors.white,fontWeight: FontWeight.bold),)
                  //             ],
                  //           ),
                          
                  //         ),
                  //           Row(
                  //             crossAxisAlignment: CrossAxisAlignment.end,
                  //             mainAxisAlignment: MainAxisAlignment.center,
                  //             children: [
                  //               Text('(This is not your username , This name will be visible to your App Contacts)' , style: TextStyle(color :Colors.white,fontSize: 10)),
                  //             ],
                  //           )
                  //       ],
                  //     )),
                  //   ),
                  // ),
                  // Container(
                  //   width: 300,
                  //   height: 50,
                  //   child: Card(
                  //     color: MyColors.maincolor,
                  //     child: Center(child: Padding(
                  //       padding: const EdgeInsets.symmetric(horizontal:8.0),
                  //       child: Row(
                  //         mainAxisAlignment: MainAxisAlignment.start,
                  //         children: [
                  //           Text('PhoneNumber:' , style: TextStyle(color :Colors.white,fontWeight: FontWeight.bold),),
                  //         ],
                  //       ),
                  //     )),
                  //   ),
                  // ),
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