import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:theproject/enum/view_state.dart';
import 'package:theproject/firebasestorage/databsemethods.dart';
import 'package:theproject/pages/bottomsheet.dart';
import 'package:theproject/providers/imageuploadprovider.dart';
// import 'package:theproject/repos/candidate.dart';
import 'package:theproject/theme.dart';
import 'package:theproject/repos/customfunctions.dart';
import 'package:theproject/pages/home_page.dart';
import 'package:theproject/repos/storage_repo.dart';
import 'package:theproject/widgets/cirindi.dart';


class OnboardProfilePage extends StatefulWidget {
  final user;
  OnboardProfilePage({this.user});

  @override
  _OnboardProfilePageState createState() => _OnboardProfilePageState();
}

class _OnboardProfilePageState extends State<OnboardProfilePage> {
  File _image;
  File localImage;
  bool isCompleted = false;
  var picker = ImagePicker();
  final FirebaseAuth _auth = FirebaseAuth.instance;
   ImageUploadProvider _imageUploadProvider;
  var nameofuser;
  var phoneNumberuser;
  Directory appDocDir;

  var userPhotos;
  Future<void> getPhoto() async {
    var id = _auth.currentUser.uid;
    CircularProgressIndicator.adaptive();
    await FirebaseFirestore.instance
        .collection("users")
        .doc(id)
        .snapshots()
        .listen((event) {
      setState(() {
        userPhotos = event.get("profilePicture");
        nameofuser = event.get("name");
        phoneNumberuser = widget.user.phoneNumber;
        print(userPhotos);
        isCompleted = true;
      });
    });
  }
  permission() async {


    final PermissionStatus permission = await Permission.storage.status;
    final PermissionStatus permissions = await Permission.storage.request(); 
   
    if (permission != PermissionStatus.granted &&
        permission != PermissionStatus.denied) {
      final Map<Permission, PermissionStatus> permissionStatus =
          await [Permission.storage].request();
      return permissionStatus[Permission.storage] ??
          PermissionStatus.limited;
    } else {
      return permission;
    }
  

  }

  @override
  void initState() {
    super.initState();
    getPhoto();
     permission();
    //  Candidate().getContacts();
    mapping(widget.user);
  }

  //  getting selecting profile picture for user
  Future getImage() async {
    var pickedFile =
        await picker.getImage(source: ImageSource.gallery, imageQuality: 50);
    isCompleted = false;
    if (pickedFile != null) {
      _image = File(pickedFile.path);
      CircularProgressIndicator.adaptive();
      _cropImage(pickedFile.path);
    } else {
      print('No image selected.');
    }
  }

  //  croppinng and uploading profile picture
  _cropImage(filePath) async {
    File croppedImage = await ImageCropper.cropImage(
      sourcePath: filePath,
    );
    if (croppedImage != null) {
      _image = croppedImage;

      print('completed');

      await StorageRepo().uploadPic(_image,_imageUploadProvider);
      setState(() {
        _image = croppedImage;
        isCompleted = true;
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
    _imageUploadProvider = Provider.of<ImageUploadProvider>(context);
    return Scaffold(
      appBar: AppBar(
          backgroundColor: MyColors.maincolor, title: Text('Profile Info')),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        color: Colors.grey[400],
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  Stack(children: [
                    // Container(
                    //   height: MediaQuery.of(context).size.height * 0.22,
                    //   decoration: BoxDecoration(
                    //     color: MyColors.maincolor,
                    //     borderRadius: BorderRadius.only(
                    //       bottomLeft: Radius.circular(80.0),
                    //       bottomRight: Radius.circular(80.0),
                    //     ),
                    //   ),
                    // ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Stack(children: [
                            GestureDetector(
                              onTap: getImage,
                              child: CircleAvatar(
                                radius: 80,
                                backgroundColor: Colors.black,
                                child: ClipOval(
                                  child: AspectRatio(
                                    aspectRatio: 1,
                                    child: SizedBox(
                                        width: double.infinity,
                                        height: double.infinity,
                                        child: isCompleted
                                            ? (userPhotos != null)
                                                ? CachedNetworkImage(
                                                    imageUrl: userPhotos,
                                                    progressIndicatorBuilder:
                                                        (context, url,
                                                                downloadProgress) =>
                                                            CircularProgressIndicator(
                                                                value:
                                                                    downloadProgress
                                                                        .progress),
                                                    errorWidget:
                                                        (context, url, error) =>
                                                            Icon(Icons.error),
                                                  )

                                                //  Image.network(
                                                //  userPhotos,
                                                //   fit: BoxFit.fill,
                                                // )
                                                : Image.asset('assets/img/pp.png')
                                            : Image.asset('assets/img/pp.png')),
                                  ),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: getImage,
                              child: Padding(
                                  padding: EdgeInsets.only(top: 110.0, left: 110.0),
                                  child: new Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      new CircleAvatar(
                                        backgroundColor:MyColors.maincolor,
                                        radius: 20.0,
                                        child: new Icon(
                                          Icons.camera_alt,
                                          color: Colors.white,
                                        ),
                                      )
                                    ],
                                  )),
                            ),
                          ]),
                        ],
                      ),
                    ),
                  ]),
                  SizedBox(
                    height:20
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.75,
                    height: 80,
                    child: Card(
                      color: MyColors.maincolor,
                      child: ListTile(
                        leading: Icon(
                          Icons.people_alt,
                          color: Colors.white,
                        ),
                        trailing: InkWell(
                          splashColor: Colors.transparent,
                          child: Icon(
                            Icons.edit,
                            color: Colors.white,
                          ),
                          onTap: () {
                            print("name changinng");
                            TextEditingController nameofuser = TextEditingController();
                        
                            showModalBottomSheet(
                                context: context,
                                isScrollControlled: false,
                                builder: (context) => SingleChildScrollView(
                                        child: Container(
                                      child: Container(child: BottomSheetExample(imageUploadProvider:_imageUploadProvider,nameofuser:nameofuser)),
                                    )));
                          },
                        ),
                        title: Row(
                          children: [
                            Flexible(
                                child: Text(
                                    nameofuser != null
                                        ? "$nameofuser"
                                        : "Enter Name",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: Colors.white)))
                          ],
                        ),
                        // subtitle: Text("Your Name ",
                        //     style: TextStyle(color: Colors.grey[400])),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      elevation: 5,
                      margin: EdgeInsets.all(10),
                    ),
                  ),
                   Container(
                    width: MediaQuery.of(context).size.width * 0.75,
                    height: 60,
                    child: Card(
                      color: MyColors.maincolor,
                      child: ListTile(
                        leading:   Icon(Icons.phone,color: Colors.white,),
                        title:   Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Flexible(
                              child: Text("$phoneNumberuser",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: Colors.white)))
                        ],
                      ),
                      ),
                       shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      elevation: 5,
                    ),
                  
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                        child: Text(
                            "Your profile is end-to-end encrypted.  Your Profile And changes will be visible to your contacts.",style: TextStyle(fontSize: 10,color: Colors.grey[700]),)),
                  )
                ],
              ),
            ),
               _imageUploadProvider.getViewState == ViewState.Loading
              ? Container(
                
                  alignment: Alignment.center,
                  margin: EdgeInsets.only(right: 15),
                  child: CustomprogressIndicator()
                  //  CircularProgressIndicator(strokeWidth: 2, backgroundColor: MyColors.maincolor, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)
                  )
              : Container(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: MyColors.maincolor,
        child: Icon(Icons.arrow_forward),
        elevation: 10,
        onPressed: () async {
          print("Hello World");
          if (nameofuser!=null && nameofuser.toString().isNotEmpty){
          print(widget.user.phoneNumber);
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => HomePage()),
              (Route<dynamic> route) => false);
        }else {
          print('retry');
        }
        }
      ),
    );
  }

  void mapping(user) {
    var phoneNumber = user.phoneNumber.toString();
    phoneNumber = CustomFunctions().shortPhoneNumber(user.phoneNumber);
    print("ppppppppppppppppppppppppppppppp" + phoneNumber);
   final now = DateTime.now();
  String formatter = DateFormat('yMd').add_jm().format(now);

    Map<String, dynamic> userInfoMap = {
      "uid": user.uid,
      "phoneNumberWithCountry": user.phoneNumber,
      "phoneNumber": phoneNumber,
      "status": '',
      "createdON": DateTime.now().millisecondsSinceEpoch,
      "DateCreated" : formatter,
      "name": null,
      "profilePicture":
          "https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png"
    };
    DatabaseMethods().uploadingUserInfo(user.uid, userInfoMap);
    DatabaseMethods().savePhonenumber(phoneNumber);
    DatabaseMethods().saveUid(user.uid);
    print("aaaaaaaaaaaaaaaaaaaaa" + user.uid);
  }
}
