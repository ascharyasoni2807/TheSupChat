import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:thegorgeousotp/firebasestorage/databsemethods.dart';
import 'package:thegorgeousotp/theme.dart';
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
TextEditingController messagetext = new TextEditingController();

class _ChatScreenState extends State<ChatScreen> {
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
    File file = await FilePicker.getFile(type: fileType);
    // chatBloc.dispatch(SendAttachmentEvent(chat.chatId,file,fileType));
    print(file.path);
    Navigator.pop(context);
    // GradientSnackBar.showMessage(context, 'Sending attachment..');
  }

  sendMessage() async {
    if (messagetext.text.isNotEmpty) {
      Map<String, dynamic> messageMap = {
        "message": messagetext.text,
        "sendBy": "KartikSoni",
        "time": DateTime.now().millisecondsSinceEpoch,
        "type": "text"
      };
      DateTime _now = DateTime.now();
      print('timestamp: ${_now.day}:${_now.month}:${_now.hour}.${_now.minute}');
      Timestamp time = Timestamp.now();
      var a = DateTime.fromMicrosecondsSinceEpoch(time.microsecondsSinceEpoch);
      print(a);

      await DatabaseMethods().addConvMessage("KartikSoni_welcome", messageMap);
      messagetext.text = '';
    }
  }

  Widget textInput() {
    return TextField(
      style: TextStyle(fontSize:19 ,color: Colors.white),
                  maxLines: null,
                  controller: messagetext,
                  onTap: () {},
                  decoration: InputDecoration(
                      prefixIcon: IconButton(
                        icon: Icon(Icons.add , color: Colors.white,),
                        onPressed: () {
                           print("add button");
                  showAttachmentBottomSheet(context);
                  // GradientSnackBar.showError(context, "Hello");
                        },
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.send , color: Colors.white,),
                        onPressed: () {
                          print("sending message");
    //               sendMessage();
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
      });
      print(server);
      print(contact);
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
                        style:const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    const  SizedBox(
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
                ],
              ),
            ),
          ),
          // ignore: prefer_const_constructors
          Container(
            decoration:BoxDecoration(
                    color: const Color(0xff536162),
                    borderRadius: BorderRadius.circular(30),
                  ), 
            margin: const EdgeInsets.symmetric(horizontal:8 , vertical :5),
           
            child:  ConstrainedBox(
                constraints: const BoxConstraints(
              
                  maxHeight: 150.0,
                ),
                child:textInput()),
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
  TileMessage(this.message, this.isSendByMe, this.timing);

  @override
  Widget build(BuildContext context) {
    // DateTime myDateTime = timing.toDate();

   final  date = DateTime.fromMillisecondsSinceEpoch(timing);
   final  formattedDate = DateFormat.yMMMd().add_jm().format(date);
  
    return Container(
      margin: EdgeInsets.symmetric(vertical: 2),
      padding: EdgeInsets.symmetric(horizontal: 6),
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
                :const BorderRadius.only(
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
                style:const TextStyle(
                    color: Colors.white, letterSpacing: 0, fontSize: 16),
              ),
            ),
         const   SizedBox(height: 2),
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
                    snapshot.data.docs[index].data()["message"],
                    snapshot.data.docs[index].data()["sendBy"] == "KartikSoni",
                    (snapshot.data.docs[index].data()["time"]));
              });
        });
  }
}
