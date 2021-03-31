import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:thegorgeousotp/enum/view_state.dart';
import 'package:thegorgeousotp/firebasestorage/databsemethods.dart';
import 'package:thegorgeousotp/providers/imageuploadprovider.dart';
import 'package:thegorgeousotp/repos/storage_repo.dart';
import 'package:thegorgeousotp/theme.dart';
import 'package:thegorgeousotp/widgets/cachedImage.dart';
import 'package:thegorgeousotp/widgets/cirindi.dart';
import 'package:thegorgeousotp/widgets/gradientbar.dart';

class ChatScreen extends StatefulWidget {
  final server;
  final contact;
  ChatScreen({this.server, this.contact});
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

Stream chatMessageStream;
var server;
var contact;
var otherUid;
TextEditingController messagetext = new TextEditingController();

class _ChatScreenState extends State<ChatScreen> {
  ImageUploadProvider _imageUploadProvider;

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
                    onTap: () => showFilePicker(FileType.IMAGE)),
                ListTile(
                    leading: Icon(Icons.videocam),
                    title: Text('Video'),
                    onTap: () => showFilePicker(FileType.VIDEO)),
                ListTile(
                  leading: Icon(Icons.insert_drive_file),
                  title: Text('File'),
                  onTap: () => showFilePicker(FileType.ANY),
                ),
              ],
            ),
          );
        });
  }

  showFilePicker(FileType fileType) async {
    CircularIndi();
    File file = await FilePicker.getFile(type: fileType );
    print(fileType);
    Navigator.pop(context);
    String url = await StorageRepo().uploadChatPic(file, otherUid, _imageUploadProvider);
    print(url);
    
    // chatBloc.dispatch(SendAttachmentEvent(chat.chatId,file,fileType));
    sendImage(url, fileType);
    print(file.path);
    
    GradientSnackBar.showMessage(context, "sending completed");
    // GradientSnackBar.showMessage(context, 'Sending attachment..');
  }

  sendImage(url, fileType) async {
    Map<String, dynamic> imagedetailMap = {
      "imageUrl": url.toString(),
      "sendBy": "KartikSoni",
      "message": "Image is  here",
      "time": DateTime.now().millisecondsSinceEpoch,
      "type": fileType.toString()
    };
    await DatabaseMethods()
        .addImageConvMessage("KartikSoni_welcome", imagedetailMap, );
    // GradientSnackBar.showError(context,"Image sent");
    print("Dedoneee");
  }

  sendMessage() async {
    if (messagetext.text.isNotEmpty) {
      Map<String, dynamic> messageMap = {
        "message": messagetext.text,
        "sendBy": "KartikSoni",
        "time": DateTime.now().millisecondsSinceEpoch,
        "type": "text"
      };
      await DatabaseMethods().addConvMessage("KartikSoni_welcome", messageMap);
      messagetext.text = '';
    }
  }

  Widget textInput() {
    return TextField(
      style: TextStyle(fontSize: 19, color: Colors.white),
      maxLines: null,
      controller: messagetext,
      onTap: () {},
      decoration: InputDecoration(
          prefixIcon: IconButton(
            icon: Icon(
              Icons.add,
              color: Colors.white,
            ),
            onPressed: () {
              print("add button");
              showAttachmentBottomSheet(context);
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

  @override
  void initState() {
    // TODO: implement initState
    DatabaseMethods().getConvoMessage("KartikSoni_welcome").then((value) {
      print(value);
      print('heelo init');
      print(widget.server);
      print(widget.contact);

      setState(() {
        chatMessageStream = value;
        server = widget.server;
        contact = widget.contact;
        otherUid = server["uid"];
      });
      print(server);
      print(contact);
    });

    super.initState();
  }

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
                              child: Image.network(server["profilePicture"])))),
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
                        child: CircularProgressIndicator())
                      : Container(),
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

  @override
  Widget build(BuildContext context) {
    // DateTime myDateTime = timing.toDate();

    final date = DateTime.fromMillisecondsSinceEpoch(timing);
    final formattedDate = DateFormat.yMMMd().add_jm().format(date);

    return type!=null && type == "FileType.IMAGE" ? 
    
    Container(
     
      padding: EdgeInsets.symmetric(horizontal:5),
       margin: isSendByMe? const EdgeInsets.only(top: 12,left: 110):const EdgeInsets.only(top: 12,right: 110),
      //  height: 210,
      //  width: 200,
      alignment: isSendByMe? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        children: [
          CachedImage(imageUrl:imageUrl),
          Text(formattedDate,
                textAlign: isSendByMe ? TextAlign.end : TextAlign.left,
                style: const TextStyle(color: Colors.black, fontSize: 10))
        ],
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
            const SizedBox(height: 2),
            Text(formattedDate,
                textAlign: isSendByMe ? TextAlign.end : TextAlign.left,
                style: const TextStyle(color: Colors.white, fontSize: 8))
          ],
        ),
      ),
    );
  }
}

ScrollController _controller = ScrollController();

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
            return const Center(child: CircularProgressIndicator());

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
                    snapshot.data.docs[index].data()["sendBy"] == "KartikSoni",
                    (snapshot.data.docs[index].data()["time"]),
                    snapshot.data.docs[index].data()["imageUrl"]
                    );
              });
        });
  }
}
