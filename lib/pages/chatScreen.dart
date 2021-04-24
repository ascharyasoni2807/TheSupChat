import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:filesize/filesize.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:theproject/enum/view_state.dart';
import 'package:theproject/firebasestorage/databsemethods.dart';
import 'package:theproject/pages/home_page.dart';
import 'package:theproject/pages/othersProfile.dart';
import 'package:theproject/pages/permission.dart';
import 'package:theproject/providers/imagedownloadprovider.dart';
import 'package:theproject/providers/imageuploadprovider.dart';
import 'package:theproject/repos/customfunctions.dart';
import 'package:theproject/repos/storage_repo.dart';
import 'package:theproject/theme.dart';
import 'package:theproject/widgets/cachedImage.dart';
import 'package:theproject/widgets/cirindi.dart';
import 'package:theproject/pages/previewImage.dart';
// import 'package:http/http.dart' as http;

class ChatScreen extends StatefulWidget {
  final server;
  final contact;
  ChatScreen({this.server, this.contact});
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

ScrollController _controller = ScrollController();
Stream chatMessageStream;
var server;
var contact;
var otherUid;
var selfUid;
var otherURL;
TextEditingController messagetext = new TextEditingController();
final databaseReference = FirebaseDatabase.instance.reference();

class _ChatScreenState extends State<ChatScreen> {
  ImageUploadProvider _imageUploadProvider;
  ImageDownloadProvider _imageDownloadProvider;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  var picker = ImagePicker();

  getCamera() async {
    Random random = new Random();
    int randomNumber = random.nextInt(999999);
    var pickedFile =
        await picker.getImage(source: ImageSource.camera, imageQuality: 50);
    var now = new DateTime.now();
    var formatter = new DateFormat('yyyy-MM-dd');
    String formattedDate = formatter.format(now);
    var a = DateFormat.jm().format(DateTime.now());
    File files = File(pickedFile.path);
    var fs = filesize(files.lengthSync());
    String sizes = fs;
    String filename = 'Image' + randomNumber.toString() + ".jpg";
    filename = filename.trim();
    var filetype = 'FileType.image';
    print(pickedFile.path);
    print(filename);
    Navigator.pop(context);
    String url = await StorageRepo()
        .uploadChatPic(files, otherUid, filename, _imageUploadProvider);

    sendImage(url, filetype, filename,sizes);
  }

  showAttachmentBottomSheet(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return Container(
            child: Wrap(
              children: <Widget>[
                ListTile(
                  leading: Icon(
                    Icons.camera_alt,
                    color: MyColors.maincolor,
                  ),
                  title: Text('Camera',
                      style: TextStyle(
                          color: MyColors.maincolor,
                          fontWeight: FontWeight.w500)),
                  onTap: () async {
                    await ContactPermission().permissioncheck2(context);
                    await getCamera();
                    print("ok");
                  },
                ),
                ListTile(
                    leading: Icon(
                      Icons.image,
                      color: MyColors.maincolor,
                    ),
                    title: Text(
                      'Image',
                      style: TextStyle(
                          color: MyColors.maincolor,
                          fontWeight: FontWeight.w500),
                    ),
                    onTap: () => showFilePicker(FileType.image)),
                ListTile(
                  leading: Icon(
                    Icons.insert_drive_file,
                    color: MyColors.maincolor,
                  ),
                  title: Text('File',
                      style: TextStyle(
                          color: MyColors.maincolor,
                          fontWeight: FontWeight.w500)),
                  onTap: () => showFilePicker(FileType.any),
                ),
              ],
            ),
          );
        });
  }

  showFilePicker(FileType fileType) async {
    FilePickerResult file = await FilePicker.platform.pickFiles(type: fileType);
    print(fileType);
    File files = File(file.files.single.path);
  
    
      var fs = filesize(files.lengthSync());


    String sizes = fs;
   
    String basenames = file.files.single.name;
    print('a');

    Navigator.pop(context);
    String url = await StorageRepo()
        .uploadChatPic(files, otherUid, basenames, _imageUploadProvider,);
    print(url);

    // chatBloc.dispatch(SendAttachmentEvent(chat.chatId,file,fileType));
    sendImage(url, fileType, basenames,sizes);
    print(file.paths);

    // GradientSnackBar.showMessage(context, 'Sending attachment..');
  }

  sendImage(url, fileType, basenames,sizes) async {
    Map<String, dynamic> imagedetailMap = {
      "imageUrl": url.toString(),
      "sendBy": selfUid,
      "message": basenames.toString(),
      "time": DateTime.now().millisecondsSinceEpoch,
      "type": fileType.toString(),
      "size": sizes,
    };
    // Map<String, dynamic> othermessageMap = {
    //   "message": messagetext.text,
    //   "sendBy": otherUid,
    //   "time": DateTime.now().millisecondsSinceEpoch,
    //   "type": "text",
    //   "size": sizes,
    // };
    DatabaseMethods()
        .addImageConvMessage(server["phoneNumber"], imagedetailMap,
            server["uid"], )
        .then(() {
      updatetime();
    });
    // GradientSnackBar.showError(context,"Image sent");
    print("Dedoneee");
  }

  updatetime() async {
    var selfphoneNumber =
        CustomFunctions().shortPhoneNumber(_auth.currentUser.phoneNumber);
    await FirebaseFirestore.instance
        .collection('ChatRoom')
        .doc(selfphoneNumber)
        .collection('ListUsers')
        .doc((_auth.currentUser.uid + "_" + server["uid"]).toString())
        .update({'time': DateTime.now().millisecondsSinceEpoch});
    await FirebaseFirestore.instance
        .collection('ChatRoom')
        .doc(server["phoneNumber"])
        .collection('ListUsers')
        .doc(server["uid"] + "_" + _auth.currentUser.uid)
        .update({'time': DateTime.now().millisecondsSinceEpoch});
  }

  sendMessage() async {
    if (messagetext.text.isNotEmpty && messagetext.text.trim().isNotEmpty) {

      Map<String, dynamic> messageMap = {
        "message": messagetext.text.toString().trim(),
        "sendBy": selfUid,
        "time": DateTime.now().millisecondsSinceEpoch,
        "type": "text"
      };
      // Map<String, dynamic> othermessageMap = {
      //   "message":messagetext.text.toString().trim(),
      //   "sendBy": otherUid,
      //   "time": DateTime.now().millisecondsSinceEpoch,
      //   "type": "text"
      // };
      await DatabaseMethods()
          .addConvMessage(
              server["phoneNumber"], messageMap, server["uid"], )
          .then((value) async {
        updatetime();
      });
      messagetext.text = '';
    } else {
      print("please type something");
    }
  }

  // FocusNode focusNode = FocusNode();
  Widget textInput() {
    return TextField(
      // readOnly: true,
      autofocus: false,
      style: TextStyle(fontSize: 19, color: Colors.white),
      maxLines: null,
      controller: messagetext,
      // onTap: () {

      // },
      decoration: InputDecoration(
          prefixIcon: IconButton(
            icon: Icon(
              Icons.add,
              color: Colors.white,
            ),
            onPressed: () async {
              
              print("add button");
              // focusNode: focusNode.unfocus();
              await showAttachmentBottomSheet(context);
              // GradientSnackBar.showError(context, "Hello");
            },
          ),
          hintText: "Type a message here.....",
          hintStyle: TextStyle(color: Colors.white54),
          border: InputBorder.none),
    );
  }

//   QuerySnapshot querySnapshot;
// DocumentSnapshot lastdocument;
  getMessages() async {
    await DatabaseMethods().getConvoMessage(otherUid).then((value) async {
       setState(() {
        chatMessageStream = value;
      });
      print('heelo init');
      print(widget.server);
      print(widget.contact);
      //  final  Map values = value.value;
      otherURL = await DatabaseMethods().getPhotoUrlofanyUser(otherUid);
      print("ojojoajaos");
      print(otherURL);
     
      print(server);
      print(contact);
    });
  }

  bool isLoading = true;

  @override
  void initState()  {
    // TODO: implement initState

    server = widget.server;
    contact = widget.contact;
    otherUid = server["uid"];
    selfUid = _auth.currentUser.uid;
    getMessages();
    _controller.addListener(() {
      double maxScroll = _controller.position.maxScrollExtent;
      double currentScroll = _controller.position.pixels;
      double delta = MediaQuery.of(context).size.height * 0.20;
      if (maxScroll - currentScroll <= delta) {
        print("upar");
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    // Navigator.pop(context);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _imageUploadProvider = Provider.of<ImageUploadProvider>(context);
      _imageDownloadProvider = Provider.of<ImageDownloadProvider>(context);
// WillPopScope(
//       onWillPop: (){
//         Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => HomePage()), (Route<dynamic> route) => false);

//       },
    return WillPopScope(
       onWillPop: (){
        Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => HomePage()), (Route<dynamic> route) => false);

      },
          child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          automaticallyImplyLeading: false,
          backgroundColor: Color(0xff028090),
          flexibleSpace: SafeArea(
            child: Container(
              height: MediaQuery.of(context).size.height * 95,
              padding: const EdgeInsets.only(right: 16),
              child: Row(
                children: <Widget>[
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(
                    width: 2,
                  ),
                  CircleAvatar(
                    backgroundColor: Colors.black,
                    minRadius: 20,
                    maxRadius: 20,
                    child: ClipOval(
                        child: AspectRatio(
                            aspectRatio: 1,
                            child: SizedBox(
                                height: 20,
                                width: 20,
                                child: CachedNetworkImage(imageUrl: otherURL)))),
                  ),
                  const SizedBox(
                    width: 12,
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            CupertinoPageRoute(
                                builder: (context) => OtherProfileView(
                                    server: server, image: otherURL)));
                      },
                      onDoubleTap: () {},
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              contact.displayName,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(
                              height: 6,
                            ),
                            Text(
                              "Status",
                              style: TextStyle(color: Colors.white, fontSize: 10),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // const Icon(
                  //   Icons.settings,
                  //   color: Colors.black54,
                  // ),
                ],
              ),
            ),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              flex: 8,
              child: Container(
                child: Stack(
                  children: <Widget>[
                    ChatMessageList(),
                  ],
                ),
              ),
            ),
            _imageUploadProvider.getViewState == ViewState.Loading
                ? Container(
                  
                    alignment: Alignment.bottomRight,
                    margin: EdgeInsets.only(right: 15),
                    child: CustomprogressIndicator()
                    //  CircularProgressIndicator(strokeWidth: 2, backgroundColor: MyColors.maincolor, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)
                    )
                : Container(),
              _imageDownloadProvider.getViewState == ViewState.Loading
                ? SizedBox(
                  // height: 50,
                  // width: 50,
                  child: Container(
                      alignment: Alignment.bottomLeft,
                      margin: EdgeInsets.only(left: 15,top: 3),
                      child: LinearProgressIndicator(
                      minHeight:2,
                        backgroundColor: MyColors.maincolor, valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      )
                      // CustomprogressIndicator()
                      //  CircularProgressIndicator(strokeWidth: 2, backgroundColor: MyColors.maincolor, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)
                      ),
                )
                              : Container(),

            // ignore: prefer_const_constructors
            Container(
              width: MediaQuery.of(context).size.width * 0.99,
              decoration: BoxDecoration(
                color: const Color(0xff536162),
                borderRadius: BorderRadius.circular(30),
              ),
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: Row(
                  children: [
                    Expanded(
                      flex: 5,
                      child: Column(
                        children: [
                          ConstrainedBox(
                              constraints: const BoxConstraints(
                                  maxHeight: 150.0, maxWidth: 300),
                              child: textInput()),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: InkWell(
                            onTap: () {
                              sendMessage();
                            },
                            child: Icon(
                              Icons.send,
                              color: Colors.white,
                            )),
                      ),
                    )
                  ],
                ),
              ),
            ),

            // textInput()
          ],
        ),
      ),
    );
  }
}

class TileMessage extends StatelessWidget {
  final String message;
  final bool isSendByMe;
  final timing;
  final type;
  final imageUrl;
  final size;
  TileMessage(
      this.type, this.size, this.message, this.isSendByMe, this.timing, this.imageUrl);

  bool isDownloading = false;

  downloadImage(imgUrl,_imageDownloadProvider) async {

    isDownloading = true;
    var now = new DateTime.now();
    var formatter = new DateFormat('yyyy-MM-dd');
    String formattedDate = formatter.format(now);
    print(formattedDate);
    _imageDownloadProvider.setToLoading();
    bool downloaded =
        await StorageRepo().saveFile(imgUrl, formattedDate, message);
    var a = DateFormat.jm().format(DateTime.now());
    print(a);
    _imageDownloadProvider.setToIdle();
    if (downloaded) {
      print("File Downloaded");

      return Fluttertoast.showToast(
          msg: "File downloaded in TheSupChat folder",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 2);
    } else {
      isDownloading = false;
      return Fluttertoast.showToast(
          msg: "Problem Downloading File",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          backgroundColor: MyColors.maincolor,
          timeInSecForIosWeb: 2);
    }
  }

  @override
  Widget build(BuildContext context) {
    // DateTime myDateTime = timing.toDate();
  ImageDownloadProvider _imageDownloadProvider;
   _imageDownloadProvider = Provider.of<ImageDownloadProvider>(context);
    final date = DateTime.fromMillisecondsSinceEpoch(timing);
    final formattedDate = DateFormat.yMMMd().add_jm().format(date);

    return type != null && type == "FileType.image"
        ? GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => PreviewPage(imageUrl: imageUrl)));
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 5),

              margin: isSendByMe
                  ? const EdgeInsets.only(top: 3, bottom: 5, left: 110)
                  : const EdgeInsets.only(top: 3, bottom: 5, right: 110),
              //  height: 210,
              //  width: 200,
              alignment:
                  isSendByMe ? Alignment.centerRight : Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: isSendByMe
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  CachedImage(imageUrl: imageUrl),
                  // ignore: prefer_const_constructors
                  // ignore: deprecated_member_use
                  !isSendByMe
                      ?     RaisedButton(
                          // color: MyColors.buttoncolor,
                          onPressed: () {
                            downloadImage(imageUrl,_imageDownloadProvider);
                          },
                          child: Icon(
                            Icons.file_download,
                          ))
                      :   Container(),
                  Padding(
                    padding: isSendByMe
                        ? const EdgeInsets.only(right: 5)
                        : const EdgeInsets.only(left: 5),
                    child: Text(formattedDate,
                        textAlign: isSendByMe ? TextAlign.end : TextAlign.left,
                        style:
                            const TextStyle(color: Colors.black, fontSize: 9)),
                  ),
                ],
              ),
            ),
          )
        : type != "text" && type != "FileType.image"
            ? Container(
                margin: isSendByMe
                    ? const EdgeInsets.only(left: 110, top:2)
                    : const EdgeInsets.only(right: 110, top: 2),
                padding: const EdgeInsets.symmetric(horizontal: 6),
                width: MediaQuery.of(context).size.width * 0.7,
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.70,
                ),
                alignment:
                    isSendByMe ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                      // color: MyColors.maincolor,
                      gradient: LinearGradient(
                          colors: isSendByMe
                              ? [Color(0xff114b5f), Color(0xff114b5f)]
                              // [MyColors.maincolor, MyColors.buttoncolor]
                              : [
                                  Color(0xff028090),
                                  Color(0xff114b5f),
                                ]),
                      borderRadius: isSendByMe
                          ? const BorderRadius.only(
                              topLeft: Radius.circular(10),
                              topRight: Radius.circular(10),
                              bottomLeft: Radius.circular(10))
                          : const BorderRadius.only(
                              topLeft: Radius.circular(10),
                              topRight: Radius.circular(10),
                              bottomRight: Radius.circular(10),
                            )),
                  child: Column(
                    crossAxisAlignment: isSendByMe
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      Container(
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: isSendByMe
                                  ? const BorderRadius.all(Radius.circular(2))
                                  : const BorderRadius.all(Radius.circular(2))),
                          padding: EdgeInsets.all(2),
                          child: Row(
                            children: [
                              Icon(Icons.file_copy_sharp,
                                  color: Color(0xff114b5f)),
                              SizedBox(width: 2),
                              Flexible(
                                child: Text(
                                  message,
                                  style: TextStyle(fontSize: 13),
                                ),
                              ),
                            ],
                          )),
                      // ignore: prefer_const_constructors
                      // ignore: deprecated_member_use
                     Row(
                   
                            mainAxisAlignment: isSendByMe
                            ? MainAxisAlignment.end
                            : MainAxisAlignment.start,
                       children: [
                         Column(
                           crossAxisAlignment: isSendByMe
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                           children: [
                              Padding(
                            padding: isSendByMe
                                ? const EdgeInsets.only(right: 1 ,top:2 )
                                : const EdgeInsets.only(left: 1,top:2),
                            child: size!=null ?Text(
                              size,
                                textAlign:
                                    isSendByMe ? TextAlign.end : TextAlign.left,
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 9)):
                                    Container()
                          ),
                          // const SizedBox(height: 3),
                          Padding(
                            padding: isSendByMe
                                ? const EdgeInsets.only(right: 1)
                                : const EdgeInsets.only(left: 1),
                            child: Text(formattedDate,
                                textAlign:
                                    isSendByMe ? TextAlign.end : TextAlign.left,
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 9)),
                          ),

                           ],
                         ),
                           !isSendByMe
                          ? Padding(
                            padding: const EdgeInsets.only(left :30),
                            child: Container(
                               
                                child: RaisedButton(
                                    color: MyColors.maincolor,
                                    onPressed: () {
                                      downloadImage(imageUrl,_imageDownloadProvider);
                                    },
                                    child: Icon(
                                      Icons.file_download,
                                      color: Colors.white,
                                    )),
                              ),
                          )
                          : Container(),
                         
                       ],
                     ),
                      
                    ],
                  ),
                ),
              )
            : Container(
                margin: const EdgeInsets.symmetric(vertical: 2),
                padding: const EdgeInsets.symmetric(horizontal: 6),
                width: MediaQuery.of(context).size.width * 0.7,
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.70,
                ),
                alignment:
                    isSendByMe ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  margin: isSendByMe
                      ? const EdgeInsets.only(left: 110)
                      : const EdgeInsets.only(
                          right: 110,
                        ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                          colors: isSendByMe
                              ? [Color(0xff114b5f), Color(0xff114b5f)]
                              // [MyColors.maincolor, MyColors.buttoncolor]
                              : [
                                  Color(0xff028090),
                                  Color(0xff114b5f),
                                ]),
                      // [MyColors.primaryColorLight, MyColors.maincolor]),
                      borderRadius: isSendByMe
                          ? const BorderRadius.only(
                              topLeft: Radius.circular(10),
                              topRight: Radius.circular(10),
                              bottomLeft: Radius.circular(10))
                          : const BorderRadius.only(
                              topLeft: Radius.circular(10),
                              topRight: Radius.circular(10),
                              bottomRight: Radius.circular(10),
                            )),
                  // height: 15,

                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: isSendByMe
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      Container(
                        child: SelectableText(
                          message,
                          style: const TextStyle(
                              color: Colors.white,
                              letterSpacing: 0,
                              fontSize: 16),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(formattedDate,
                          textAlign:
                              isSendByMe ? TextAlign.end : TextAlign.left,
                          style:
                              const TextStyle(color: Colors.white, fontSize: 9))
                    ],
                  ),
                ),
              );
  }
}

class ChatMessageList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //  WidgetsBinding.instance.addPostFrameCallback((_) => scroll());
    return StreamBuilder<QuerySnapshot>(
        stream: chatMessageStream,
        builder: (context, snapshot) {
          print(snapshot.data);
          print('inside ot');
          if (snapshot.data == null)
            return Center(child: CustomprogressIndicator());

          return ListView.builder(
              // controller: _controller,
              shrinkWrap: true,
              reverse: true,
              // print('hello in list');
              itemCount: snapshot.data.docs.length,
              itemBuilder: (context, index) {
                return TileMessage(
                    snapshot.data.docs[index].data()["type"],
                      snapshot.data.docs[index].data()["size"],
                    snapshot.data.docs[index].data()["message"],
                    snapshot.data.docs[index].data()["sendBy"] == selfUid,
                    (snapshot.data.docs[index].data()["time"]),
                    snapshot.data.docs[index].data()["imageUrl"]);
              });
        });
  }
}
