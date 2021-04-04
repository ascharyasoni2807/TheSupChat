import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:theproject/enum/view_state.dart';
import 'package:theproject/firebasestorage/databsemethods.dart';
import 'package:theproject/providers/imageuploadprovider.dart';
import 'package:theproject/repos/storage_repo.dart';
import 'package:theproject/theme.dart';
import 'package:theproject/widgets/cachedImage.dart';
import 'package:theproject/widgets/cirindi.dart';
import 'package:theproject/pages/previewImage.dart';
import 'package:http/http.dart'as http;

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
TextEditingController messagetext = new TextEditingController();

class _ChatScreenState extends State<ChatScreen> {
  ImageUploadProvider _imageUploadProvider;
final FirebaseAuth _auth = FirebaseAuth.instance;


  showAttachmentBottomSheet(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return Container(
            child: Wrap(
              children: <Widget>[
                ListTile(
                    leading: Icon(Icons.image),
                    title: Text('Image'),
                    onTap: () => showFilePicker(FileType.image)),
                ListTile(
                    leading: Icon(Icons.videocam),
                    title: Text('Video'),
                    onTap: () => showFilePicker(FileType.video)),
                ListTile(
                  leading: Icon(Icons.insert_drive_file),
                  title: Text('File'),
                  onTap: () => showFilePicker(FileType.any),
                ),
              ],
            ),
          );
        });
  }

  showFilePicker(FileType fileType) async {
    FilePickerResult file = await FilePicker.platform.pickFiles(type: fileType );
    print(fileType);
    Navigator.pop(context);
    String url = await StorageRepo().uploadChatPic(file, otherUid, _imageUploadProvider);
    print(url);
    
    // chatBloc.dispatch(SendAttachmentEvent(chat.chatId,file,fileType));
    sendImage(url, fileType);
    print(file.paths);
    
    // GradientSnackBar.showMessage(context, 'Sending attachment..');
  }

  sendImage(url, fileType) async {
    Map<String, dynamic> imagedetailMap = {
      "imageUrl": url.toString(),
      "sendBy":  selfUid,
      "message": "Image is  here",
      "time": DateTime.now().millisecondsSinceEpoch,
      "type": fileType.toString()
    };
      Map<String, dynamic> othermessageMap =  {
        "message": messagetext.text,
        "sendBy": otherUid,
        "time": DateTime.now().millisecondsSinceEpoch,
        "type": "text"
      };
    await DatabaseMethods()
        .addImageConvMessage(server["phoneNumber"], imagedetailMap,server["uid"],othermessageMap);
    // GradientSnackBar.showError(context,"Image sent");
    print("Dedoneee");
  }

  sendMessage() async {
    if (messagetext.text.isNotEmpty && messagetext.text.trim().isNotEmpty) {
      Map<String, dynamic> messageMap = {
        "message": messagetext.text,
        "sendBy": selfUid,
        "time": DateTime.now().millisecondsSinceEpoch,
        "type": "text"
      };
       Map<String, dynamic> othermessageMap =  {
        "message": messagetext.text,
        "sendBy": otherUid,
        "time": DateTime.now().millisecondsSinceEpoch,
        "type": "text"
      };
      await DatabaseMethods().addConvMessage(server["phoneNumber"], messageMap,server["uid"],othermessageMap);
      messagetext.text = '';
    }
    else {
      print("please type something");
    }
  }
  
 
  
  
  FocusNode focusNode = FocusNode();
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
            onPressed: ()async {
              print("add button");
              // focusNode: focusNode.unfocus();
             await showAttachmentBottomSheet(context);
              // GradientSnackBar.showError(context, "Hello");
            },
          ),
          suffixIcon: IconButton(
            icon: Icon(
              Icons.send,
              color: Colors.white,
            ),
            onPressed: () {
              print("sending message");
              sendMessage();
            },
          ),
          hintText: "Type a message here.....",
          hintStyle: TextStyle(color: Colors.white54),
          border: InputBorder.none),
    );
  }
 Query q;
  QuerySnapshot querySnapshot;
DocumentSnapshot lastdocument;
  getMessages() async {
   await  DatabaseMethods().getConvoMessage(otherUid).then((value) async {
    
      print('heelo init');
      print(widget.server);
      print(widget.contact);
    //  final  Map values = value.value;
      
      setState(() {
        // q= value;
        chatMessageStream = value;
        // server = widget.server;
        print("ojojoajaos");
        // contact = widget.contact;
        // otherUid = server["uid"];
        // selfUid = _auth.currentUser.uid;
        // isLoading= false;

      });
      // print(q);
      // querySnapshot = await q.get();
      // lastdocument = querySnapshot.docs[querySnapshot.docs.length-1];
  
      print(server);
      print(contact);
    });
  }

  getNextMessages() async  {



  } 
  bool isLoading = true;

  @override
  void initState() {
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
     super.initState();
  });
  
 
  }

// @override
//   void dispose() {
//     // TODO: implement dispose
//     super.dispose();
//   }
  @override
  Widget build(BuildContext context) {
    _imageUploadProvider = Provider.of<ImageUploadProvider>(context);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
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
                    color: Colors.black,
                  ),
                ),
                const SizedBox(
                  width: 2,
                ),
                CircleAvatar(
                  backgroundColor: Colors.black,
                  minRadius: 25,
                  maxRadius: 25,
                  child: ClipOval(
                      child: AspectRatio(
                          aspectRatio: 1,
                          child: SizedBox(
                              height: 20,
                              width: 20,
                              child: CachedNetworkImage(imageUrl:server["profilePicture"] )
                              ))),
                ),
                const SizedBox(
                  width: 12,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        contact.displayName,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(
                        height: 6,
                      ),
                      Text(
                        "Online",
                        style: TextStyle(
                            color: Colors.grey.shade600, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.settings,
                  color: Colors.black54,
                ),
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
                 
                  //       RaisedButton(onPressed: () {
                  //   _imageUploadProvider.getViewState == ViewState.Loading
                  //       ? _imageUploadProvider.setToIdle()
                  //       : _imageUploadProvider.setToLoading();
                  //       print("wyewew");
                  // })
                     
                ],
              ),
            ),
          ),
           _imageUploadProvider.getViewState == ViewState.Loading
                      ? Container(

                        alignment: Alignment.bottomRight,
                        margin: EdgeInsets.only(right:15),
                        child: CustomprogressIndicator()
                        //  CircularProgressIndicator(strokeWidth: 2, backgroundColor: MyColors.maincolor, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)
                       ) :Container(),
                        
          // ignore: prefer_const_constructors
          Container(
            decoration: BoxDecoration(
              color: const Color(0xff536162),
              borderRadius: BorderRadius.circular(30),
            ),
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxHeight: 150.0,
                ),
                child: textInput()),
          ),

          // textInput()
        ],
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
  TileMessage(this.type,this.message, this.isSendByMe, this.timing ,this.imageUrl);

 bool isDownloading = false;

downloadImage(imgUrl) async {
  isDownloading = true;
    var now = new DateTime.now();
    var formatter = new DateFormat('yyyy-MM-dd');
    String formattedDate = formatter.format(now);
    print(formattedDate);
    bool downloaded = await StorageRepo().saveFile(
        imgUrl,
        
        formattedDate);
        var a = DateFormat.jm().format(DateTime.now());
        print(a);
     
    if (downloaded) {
      print("File Downloaded");
    } else {
      print("Problem Downloading File");
    }
  isDownloading = false;
  }

  @override
  Widget build(BuildContext context) {
    // DateTime myDateTime = timing.toDate();

    final date = DateTime.fromMillisecondsSinceEpoch(timing);
    final formattedDate = DateFormat.yMMMd().add_jm().format(date);

    return type!=null && type == "FileType.IMAGE" ? 
    GestureDetector(
      onTap: () {
        
          Navigator.push(context, MaterialPageRoute(builder: (context) => PreviewPage(imageUrl:imageUrl)));
      },
          child: Container(
       
        padding: EdgeInsets.symmetric(horizontal:5),
         margin: isSendByMe? const EdgeInsets.only(top: 5,bottom:5 ,left: 110):const EdgeInsets.only(top: 5,bottom:5 ,right: 110),
        //  height: 210,
        //  width: 200,
        alignment: isSendByMe? Alignment.centerRight : Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: isSendByMe? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            CachedImage(imageUrl:imageUrl),
            // ignore: prefer_const_constructors
            // ignore: deprecated_member_use
            !isSendByMe ? RaisedButton (
              // color: MyColors.buttoncolor,
              onPressed: () { 
               
                downloadImage(imageUrl); },
                
            child: Icon( Icons.file_download ,)): Container(),
            Padding(
              padding: isSendByMe? const EdgeInsets.only(right: 5):const EdgeInsets.only(left:5),
              child: Text(formattedDate,
                    textAlign: isSendByMe ? TextAlign.end : TextAlign.left,
                    style: const TextStyle(color: Colors.black, fontSize: 10)),
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
      alignment: isSendByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: isSendByMe
            ? const EdgeInsets.only(left: 110)
            : const EdgeInsets.only(right: 110),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: isSendByMe
                    ? [MyColors.maincolor, MyColors.buttoncolor]
                    : [MyColors.primaryColorLight, MyColors.maincolor]),
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
          crossAxisAlignment:
              isSendByMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              child: SelectableText(
                message,
                style: const TextStyle(
                    color: Colors.white, letterSpacing: 0, fontSize: 16),
              ),
            ),
            const SizedBox(height: 3),
            Text(formattedDate,
                textAlign: isSendByMe ? TextAlign.end : TextAlign.left,
                style: const TextStyle(color: Colors.white, fontSize: 9))
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
            return  Center(child: CustomprogressIndicator());

          return ListView.builder(
              controller: _controller,
              shrinkWrap: true,
              reverse: true,
              // print('hello in list');
              itemCount: snapshot.data.docs.length,
              itemBuilder: (context, index) {
                return TileMessage(
                  snapshot.data.docs[index].data()["type"],
                    snapshot.data.docs[index].data()["message"],
                    snapshot.data.docs[index].data()["sendBy"] == selfUid,
                    (snapshot.data.docs[index].data()["time"]),
                    snapshot.data.docs[index].data()["imageUrl"]
                    );
              });
        });
  }
}

