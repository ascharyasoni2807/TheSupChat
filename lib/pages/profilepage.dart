import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path/path.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:theproject/enum/view_state.dart';
import 'package:theproject/firebasestorage/databsemethods.dart';
import 'package:theproject/pages/bottomsheet.dart';
import 'package:theproject/pages/previewImage.dart';
import 'package:theproject/providers/imageuploadprovider.dart';
import 'package:theproject/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:theproject/pages/home_page.dart';
import 'package:theproject/repos/storage_repo.dart';
import 'package:theproject/theme.dart';
import 'package:theproject/widgets/cirindi.dart';


class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  File _image;
  File localImage;
  bool isCompleted = false;
  var picker = ImagePicker();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  var nameofuser;
  var phoneNumberuser;
  Directory appDocDir;
 ImageUploadProvider _imageUploadProvider;

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
        phoneNumberuser = event.get("phoneNumber");
        print(userPhotos);
        isCompleted = true;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    getPhoto();
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

      print('completed cropping');

      await StorageRepo().uploadPic(_image, _imageUploadProvider);

      print("completed upload");
      setState(() {
        _image = croppedImage;
        isCompleted = true;
      });
    }
  }


  Widget _buildPopupDialog(BuildContext context, image) {

  return Center(
    child: GestureDetector(
      onTap:(){
       Navigator.push(context, MaterialPageRoute(builder: (context) => PreviewPage(imageUrl:image)));
        print("bvfhjgjdfe");
      } ,
          child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black),
            color: Colors.black,
          ),
          height: 300,
          width: 300,
          // color: Colors.black,
          child: Padding(
            padding: const EdgeInsets.all(2),
            child: CachedNetworkImage(imageUrl: image),
          )),
    ),
  );
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
         
          backgroundColor: Color(0xff028090), title: Text('Profile Info',style: TextStyle(fontSize: 16),)),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        color: Colors.white,
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
    
                children: [
                  Stack(children: [
                      
                    // Container(
                    //   height: MediaQuery.of(context).size.height * 0.22,
                    //   decoration: BoxDecoration(
                    //     color: Color(0xff028090),
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
                              onTap:() {showDialog(
                        
                        barrierColor: Colors.black.withOpacity(0.5),
                        context: context,
                        builder: (BuildContext context) =>
                            _buildPopupDialog(context, userPhotos),
                      );},
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
                                                            CircularProgressIndicator( strokeWidth: 2, backgroundColor: MyColors.maincolor, valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
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
                                                : CircularProgressIndicator
                                                    .adaptive()
                                            : CircularProgressIndicator.adaptive(
                                              strokeWidth: 2, backgroundColor: MyColors.maincolor, valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                            )),
                                  ),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: getImage,
                              child: Padding(
                                  padding: EdgeInsets.only(top: 110.0, left: 111.0),
                                  child: new Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      new CircleAvatar(
                                        backgroundColor: MyColors.maincolor,
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
                  SizedBox(height:20),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.75,
                    height: 60,
                    child: Card(
                    color: Color(0xff028090),
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
                                      child: Container(child: BottomSheetExample(imageUploadProvider: _imageUploadProvider,nameofuser: nameofuser,)),
                                    )));
                          },
                        ),
                        title: Row(
                          // crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Flexible(
                                child: Text("$nameofuser",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.white)))
                          ],
                        ),
                        // subtitle: Text("Your Name ",
                        //     style: TextStyle(color: Colors.grey)),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      elevation: 5,
                     
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.75,
                    height: 60,
                    child: Card(
                     color: Color(0xff028090),
                      child: ListTile(
                        leading:   Icon(Icons.phone,color: Colors.white,),
                        title:   Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Flexible(
                              child: Text("$phoneNumberuser",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
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
                    padding: const EdgeInsets.all(12.0),
                    child: Container(
                        child: Text(
                            "Your profile is end-to-end encrypted.  Your profile and changes will be visible to your contacts.",style: TextStyle(color: Colors.grey[500],fontSize: 12),)),
                  ),
            
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
    );
  }
}
