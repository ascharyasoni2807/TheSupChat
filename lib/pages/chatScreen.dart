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
import 'package:theproject/widgets/alertdialog.dart';
import 'package:theproject/widgets/onlinestatus.dart';

import '../firebasestorage/databsemethods.dart';
import '../theme.dart';
// import 'package:http/http.dart' as http;

class ChatScreen extends StatefulWidget {
  final server;
  final contact;
  final image;
  final selfchatRoomMap;
  final secondchatRoomMap;
  ChatScreen({
    this.server,
    this.contact,
    this.image,
    this.selfchatRoomMap,
    this.secondchatRoomMap,
  });
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

Stream chatMessageStream;
var server;
var contact;
var otherUid;
var selfUid;
var otherURL;
TextEditingController messagetext = new TextEditingController();
final databaseReference = FirebaseDatabase.instance.reference();
ScrollController _controller = ScrollController();

class _ChatScreenState extends State<ChatScreen> {
  ImageUploadProvider _imageUploadProvider;
  ImageDownloadProvider _imageDownloadProvider;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  var picker = ImagePicker();
  final ScrollController listScrollController = ScrollController();
  final FocusNode focusNode = FocusNode();

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
    String url = await StorageRepo().uploadChatPic(
      files,
      otherUid,
      filename,
    );

    sendImage(url, filetype, filename, sizes);
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
    FilePickerResult file = await FilePicker.platform
        .pickFiles(type: fileType, allowMultiple: true);
    print(fileType);
    print(file.files);
    // File files = File(file.files.single.path);

    Navigator.pop(context);
    var url = await StorageRepo()
        .uploadFiles(file.files, otherUid, _imageUploadProvider);
    print(url);
    int i;
    List updata = [];
    for (i = 0; i < file.files.length; i++) {
      Map data = Map();
      data['url'] = url[i];
      data['file'] = file.files[i];
      updata.add(data);
    }
    print(updata);

    updata.forEach((element) {
      print(element);
      print(element['url']);
      print(element['file'].name);
      Map<String, dynamic> imagedetailMap;
      imagedetailMap = {
        "imageUrl": element['url'],
        "sendBy": selfUid,
        "isRead" : 'false',
        "message": element['file'].name,
        // "lastmessage": basenames.toString(),
        "time": DateTime.now().millisecondsSinceEpoch,
        "type": fileType.toString(),
        "size": filesize(element['file'].size)
      };

      DatabaseMethods().addImageConvMessage(
        server["phoneNumber"],
        imagedetailMap,
        server["uid"],
      );
    });
    updatetime(file.files.last.name.toString());
  }

  sendImage(url, fileType, basenames, sizes) async {
    settingRoom();

    Map<String, dynamic> imagedetailMap = {
      "imageUrl": url.toString(),
      "sendBy": selfUid,
      "message": basenames.toString(),
      // "lastmessage": basenames.toString(),
      "time": DateTime.now().millisecondsSinceEpoch,
      "type": fileType.toString(),
      "size": sizes,
    };
    updatetime(basenames.toString().trim());

    DatabaseMethods().addImageConvMessage(
      server["phoneNumber"],
      imagedetailMap,
      server["uid"],
    );
  }

  updatetime(a) async {
    var selfphoneNumber =
        CustomFunctions().shortPhoneNumber(_auth.currentUser.phoneNumber);
    await FirebaseFirestore.instance
        .collection('ChatRoom')
        .doc(selfphoneNumber)
        .collection('ListUsers')
        .doc((_auth.currentUser.uid + "_" + server["uid"]).toString())
        .update(
            {'time': DateTime.now().millisecondsSinceEpoch, 'lastMessage': a});
    await FirebaseFirestore.instance
        .collection('ChatRoom')
        .doc(server["phoneNumber"])
        .collection('ListUsers')
        .doc(server["uid"] + "_" + _auth.currentUser.uid)
        .update(
            {'time': DateTime.now().millisecondsSinceEpoch, 'lastMessage': a});
  }

  sendMessage() async {
    if (messagetext.text.isNotEmpty && messagetext.text.trim().isNotEmpty) {
      settingRoom();
      Map<String, dynamic> messageMap = {
        "message": messagetext.text.toString().trim(),
        "sendBy": selfUid,
        'isRead': 'false',
        "time": DateTime.now().millisecondsSinceEpoch,
        "type": "text"
      };

      await DatabaseMethods()
          .addConvMessage(
        server["phoneNumber"],
        messageMap,
        server["uid"],
      )
          .then((value) async {
        updatetime(
          messagetext.text.toString().trim(),
        );
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

  getMessages() async {
    await DatabaseMethods()
        .getConvoMessage(otherUid, server['phoneNumber'])
        .then((value) async {
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
  settingRoom() async {
    var currentUid = await StorageRepo().getCurrentUidofUser();
    var a;
    var b;
    var time1;
    var time2;
    print(server["uid"]);

    try {
      await FirebaseFirestore.instance
          .collection("ChatRoom")
          .doc(CustomFunctions().shortPhoneNumber(currentUid.phoneNumber))
          .collection("ListUsers")
          .doc((currentUid.uid + '_' + server["uid"]))
          .collection("Chats")
          .orderBy("time", descending: true)
          .limit(1)
          .get()
          .then((value) async {
        a = value.docs.first.data();
        print(a);
        time1 = a['time'];

        a = a['message'];

        await FirebaseFirestore.instance
            .collection("ChatRoom")
            .doc(server['phoneNumber'])
            .collection("ListUsers")
            .doc((server['uid'] + "_" + currentUid.uid))
            .collection("Chats")
            .orderBy("time", descending: true)
            .limit(1)
            .get()
            .then((value) async {
          b = value.docs.first.data();
          print(b);
          time2 = b['time'];
          b = b['message'];
        });
      });
// print(a+b);
    } catch (e) {
      print(e);
    }

    List<String> users = [server["uid"], currentUid.uid];
    List<String> phones = [
      server["phoneNumberWithCountry"],
      currentUid.phoneNumber
    ];
    final selfPhoneNumber =
        CustomFunctions().shortPhoneNumber(currentUid.phoneNumber);
    print(phones);
    print(users);
    Map<String, dynamic> selfchatRoomMap = {
      "users": users,
      "phoneNumberWithCountry": server["phoneNumberWithCountry"].toString(),
      "phoneNumber": server["phoneNumber"].toString(),
      "uid": server["uid"],
      "time": time1 != null ? time1 : DateTime.now().millisecondsSinceEpoch,
      "lastMessage": a != null ? a : '',
      "profilePicture": server["profilePicture"].toString(),
    };
    print(users.reversed.toList());
    Map<String, dynamic> secondchatRoomMap = {
      "users": users.reversed.toList(),
      "phoneNumberWithCountry": currentUid.phoneNumber,
      "phoneNumber": selfPhoneNumber,
      "uid": currentUid.uid,
      "time": time2 != null ? time2 : DateTime.now().millisecondsSinceEpoch,
      "lastMessage": b != null ? b : '',
      "profilePicture": currentUid.photoURL
    };

    DatabaseMethods()
        .createChatRoom(
            server["uid"],
            server["phoneNumberWithCountry"].toString(),
            selfchatRoomMap,
            secondchatRoomMap)
        .then((value) {});
  }

  _scrollListener() {
    if (listScrollController.offset >=
            listScrollController.position.maxScrollExtent &&
        !listScrollController.position.outOfRange) {
      print("reach the bottom");
      setState(() {
        print("reach the bottom");
        // _limit += _limitIncrement;
      });
    }
    if (listScrollController.offset <=
            listScrollController.position.minScrollExtent &&
        !listScrollController.position.outOfRange) {
      print("reach the top");
      setState(() {
        print("reach the top");
      });
    }
  }

  void onFocusChange() {
    if (focusNode.hasFocus) {
      // Hide sticker when keyboard appear
      setState(() {
        // isShowSticker = false;
        print('inFocus');
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState

    //  focusNode.addListener(onFocusChange);
    //   listScrollController.addListener(_scrollListener);
    server = widget.server;
    contact = widget.contact;
    otherUid = server["uid"];
    selfUid = _auth.currentUser.uid;

    getMessages();
    _controller.addListener(() {
      double maxScroll = _controller.position.maxScrollExtent;
      double currentScroll = _controller.position.pixels;
      double delta = MediaQuery.of(context).size.height * 0.03;
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
    _imageDownloadProvider.getViewState == ViewState.Loading
        ? _imageDownloadProvider.setToIdle()
        : '';

    _imageUploadProvider.getViewState == ViewState.Loading
        ? _imageUploadProvider.setToIdle()
        : '';
    super.dispose();
  }

  bool longPressed = false;

  @override
  Widget build(BuildContext context) {
    _imageUploadProvider = Provider.of<ImageUploadProvider>(context);
    _imageDownloadProvider = Provider.of<ImageDownloadProvider>(context);
// WillPopScope(
//       onWillPop: (){
//         Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => HomePage()), (Route<dynamic> route) => false);

//       },
//

    return Scaffold(
      appBar: AppBar(
        elevation: 5,
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
                              child: CachedNetworkImage(
                                  imageUrl: widget.image != null
                                      ? widget.image
                                      : server['profilePicture'])))),
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
                           contact!=null? contact.runtimeType != String 
                                ? contact?.displayName ??
                                    server['phoneNumberWithCountry']
                                : server['phoneNumberWithCountry']:server['phoneNumberWithCountry'],
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(
                            height: 2,
                          ),
                          SizedBox(
                              height: 20,
                              child: Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: OnlineStatus(server: server),
                              )),
                          // Text(
                          //   "Status",
                          //   style: TextStyle(color: Colors.white, fontSize: 10),
                          // ),
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
      // : AppBar(
      //     title: Text('1'),
      //     leading: Icon(Icons.close),
      //     actions: <Widget>[Icon(Icons.delete), Icon(Icons.more_vert)],
      //     backgroundColor: Color(0xff028090),
      //   ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/img/wall3.png'),
            fit: BoxFit.fill,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              // flex: 4,
              child: Container(
                //        decoration: BoxDecoration(
                // image: DecorationImage(
                //   image: AssetImage(
                //       'assets/img/wall3.png'),
                //   fit: BoxFit.fill,
                // ),),
                // color: Color(0xff028090).withOpacity(0.18),
                child: Stack(
                  children: <Widget>[
                    Image.asset(
                      'assets/img/wall3.png',
                      fit: BoxFit.cover,
                    ),
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
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/img/wall3.png'),
                            fit: BoxFit.fill,
                          ),
                        ),
                        alignment: Alignment.bottomLeft,
                        margin: EdgeInsets.only(left: 0, top: 3),
                        child: LinearProgressIndicator(
                            minHeight: 2,
                            backgroundColor: MyColors.maincolor,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white))
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
  final id;
  final bool isRead;
  TileMessage(this.id, this.type, this.size, this.message, this.isRead,
      this.isSendByMe, this.timing, this.imageUrl);

  bool isDownloading = false;

  downloadImage(imgUrl, _imageDownloadProvider) async {
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

  showDialogBox(context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            backgroundColor: MyColors.maincolor,
            //this right here
            child: Container(
              // color: Color(0xff114b5f),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: isSendByMe
                        ? [
                            Color(0xff114b5f),
                            Color(0xff028090),
                            Color(0xff114b5f)
                          ]
                        // [MyColors.maincolor, MyColors.buttoncolor]
                        : [
                            Color(0xff114b5f),
                            Color(0xff028090),
                            Color(0xff114b5f),
                          ]),
              ),
              width: MediaQuery.of(context).size.width * 0.9,
              height: 100,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  isSendByMe
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            FlatButton(
                              height: 40,
                              onPressed: () {
                                DatabaseMethods().deleteConvo(
                                    id, server['phoneNumber'], otherUid);
                                Navigator.pop(context);
                              },
                              child: Text(
                                "Delete for both",
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(color: Colors.white),
                              ),
                              // color: const Color(0xFF1BC0C5),
                            ),
                            FlatButton(
                              height: 40,
                              onPressed: () {
                                DatabaseMethods().deleteSingleConvo(
                                    id, server['phoneNumber'], otherUid);
                                Navigator.pop(context);
                              },
                              child: Text(
                                "Delete for me",
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(color: Colors.white),
                              ),
                              // color: const Color(0xFF1BC0C5),
                            )
                          ],
                        )
                      : FlatButton(
                          height: 20,
                          onPressed: () {
                            DatabaseMethods().deleteSingleConvo(
                                id, server['phoneNumber'], otherUid);
                            Navigator.pop(context);
                          },
                          child: Text(
                            "Delete for me",
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.white),
                          ),
                          // color: const Color(0xFF1BC0C5),
                        )
                ],
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    final now = new DateTime.now();
    var todaysdate = DateFormat.yMMMd().format(now);

    ImageDownloadProvider _imageDownloadProvider;
    _imageDownloadProvider = Provider.of<ImageDownloadProvider>(context);
    final date = DateTime.fromMillisecondsSinceEpoch(timing);
    final formattedDate = DateFormat.yMMMd().add_jm().format(date);
    String time = DateFormat.jm().format(date);
    print(time);

    return type != null && type == "FileType.image"
        ? InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => PreviewPage(imageUrl: imageUrl)));
            },
            onLongPress: () {
              print(type);
              print(formattedDate);
              print(id);
              showDialogBox(context);
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8),

              margin: isSendByMe
                  ? const EdgeInsets.only(top: 3, bottom: 2, left: 108)
                  : const EdgeInsets.only(top: 3, bottom: 2, right: 108),
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
                      ? RaisedButton(
                          color: MyColors.maincolor,
                          onPressed: () {
                            downloadImage(imageUrl, _imageDownloadProvider);
                          },
                          child: Icon(
                            Icons.file_download,
                            color: Colors.white,
                          ))
                      : Container(),
                  Padding(
                    padding: isSendByMe
                        ? const EdgeInsets.only(right: 5)
                        : const EdgeInsets.only(left: 5),
                    child: Row(
                      children: [
                        Text(
                            formattedDate.contains(todaysdate)
                                ? 'Today  ' + time.toString()
                                : formattedDate,
                            textAlign:
                                isSendByMe ? TextAlign.end : TextAlign.left,
                            style: const TextStyle(
                                color: Colors.black, fontSize: 9)),
                                  isSendByMe?  isRead
                          ? Icon(
                              Icons.done,
                              size: 15,
                            )
                          : Icon(
                              Icons.done_all,
                              color: Colors.lightBlue,
                              size: 15,
                            ):Container()
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
        : type != "text" && type != "FileType.image"
            ? InkWell(
                onLongPress: () {
                  print(type);
                  print(formattedDate);
                  print(id);
                  showDialogBox(context);
                },
                child: Container(
                  margin: isSendByMe
                      ? const EdgeInsets.only(left: 110, top: 3)
                      : const EdgeInsets.only(right: 110, top: 5),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  width: MediaQuery.of(context).size.width * 0.7,
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.70,
                  ),
                  alignment:
                      isSendByMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            // color: Colors.black,
                            blurRadius: 2.0,
                            // spreadRadius: 0.0,
                            // offset: Offset(
                            //     0,1.0), // shadow direction: bottom right
                          ),
                        ],
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
                                    : const BorderRadius.all(
                                        Radius.circular(2))),
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
                                        ? const EdgeInsets.only(
                                            right: 1, top: 2)
                                        : const EdgeInsets.only(
                                            left: 1, top: 2),
                                    child: size != null
                                        ? Text(size,
                                            textAlign: isSendByMe
                                                ? TextAlign.end
                                                : TextAlign.left,
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 9))
                                        : Container()),
                                // const SizedBox(height: 3),
                                Padding(
                                  padding: isSendByMe
                                      ? const EdgeInsets.only(right: 1)
                                      : const EdgeInsets.only(left: 1),
                                  child: Row(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(right:2.0),
                                        child: Text(
                                            formattedDate.contains(todaysdate)
                                                ? 'Today  ' + time.toString()
                                                : formattedDate,
                                            textAlign: isSendByMe
                                                ? TextAlign.end
                                                : TextAlign.left,
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 9)),
                                      ),
                                                isSendByMe?  isRead
                                    ? Icon(
                                        Icons.done,
                                        color: Colors.white,
                                        size: 15,
                                      )
                                    : Icon(
                                        Icons.done_all,
                                        color: Colors.lightBlue,
                                        size: 15,
                                      ):Container(),
                                    ],
                                  ),
                                ),
                                 
                              ],
                            ),
                            !isSendByMe
                                ? Expanded(
                                    child: Container(
                                      margin:
                                          EdgeInsets.only(right: 35, left: 35),
                                      child: RaisedButton(
                                          color: MyColors.maincolor,
                                          onPressed: () {
                                            downloadImage(imageUrl,
                                                _imageDownloadProvider);
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
                ),
              )
            : InkWell(
                onLongPress: () {
                  print(type);
                  print(formattedDate);
                  print(id);
                  showDialogBox(context);
                },
                child: Container(
                  margin: isSendByMe
                      ? const EdgeInsets.only(left: 110, top: 5)
                      : const EdgeInsets.only(right: 110, top: 5),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  width: MediaQuery.of(context).size.width * 0.7,
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.70,
                  ),
                  alignment:
                      isSendByMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 5, vertical: 7),
                    decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            // color: Colors.black,
                            blurRadius: 1.0,
                            // spreadRadius: 0.0,
                            //   offset: Offset(
                            //       0,1.0), // shadow direction: bottom right
                            // )
                          )
                        ],
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
                        Padding(
                          padding: isSendByMe
                              ? const EdgeInsets.only(right: 1)
                              : const EdgeInsets.only(left: 1),
                          child: Row( mainAxisSize: MainAxisSize.min,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(right:2.0),
                                child: Text(
                                    formattedDate.contains(todaysdate)
                                        ? 'Today  ' + time.toString()
                                        : formattedDate,
                                    textAlign: isSendByMe
                                        ? TextAlign.end
                                        : TextAlign.left,
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 9)),
                              ),
                                       isSendByMe? isRead
                            ? Icon(
                                Icons.done,
                                color: Colors.white,
                                size: 15,
                              )
                            : Icon(
                                Icons.done_all,
                                color: Colors.lightBlue,
                                size: 15,
                              ):Container(),
                            ],
                          ),
                        ),
                          
                      ],
                    ),
                  ),
                ),
              );
  }
}

class ChatMessageList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: chatMessageStream,
        
        builder: (context, snapshot) {
         update(id) async{
          try{ await FirebaseFirestore.instance
            .collection('ChatRoom')
            .doc(server['phoneNumber'])
            .collection('ListUsers')
            .doc((server['uid'] + "_" + selfUid)).collection('Chats').doc(id)
            .update(
              {
                 'isRead' : 'true'
              }
            );}catch(e){
              print(e);
            }
         }
     
          print('inside ot');
          // if (snapshot.data.docs.where((element) => 
          
          // false) .data()["isRead"] == 'false')
          if (snapshot.data == null)
            return Center(child: CustomprogressIndicator());

          return ListView.builder(
              controller: _controller,
              // physics: BouncingScrollPhysics(),
              shrinkWrap: true,
              reverse: true,

              // print('hello in list');
              itemCount: snapshot.data.docs.length,
              itemBuilder: (context, index) {
            snapshot.data.docs[index].data()["isRead"]=='false'? update(snapshot.data.docs[index].id,):print('updating');
                return TileMessage(
                    snapshot.data.docs[index].id,
                    snapshot.data.docs[index].data()["type"],
                    snapshot.data.docs[index].data()["size"],
                    snapshot.data.docs[index].data()["message"],
                    snapshot.data.docs[index].data()["isRead"] == 'false',
                    snapshot.data.docs[index].data()["sendBy"] == selfUid,
                    (snapshot.data.docs[index].data()["time"]),
                    snapshot.data.docs[index].data()["imageUrl"]);
              });
        });
  }
}
