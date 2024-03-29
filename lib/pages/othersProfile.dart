import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:theproject/theme.dart';
import 'package:theproject/widgets/cachedImage.dart';

class OtherProfileView extends StatefulWidget {
  final server;
  final image;

  OtherProfileView({this.server, this.image});
  @override
  _OtherProfileViewState createState() => _OtherProfileViewState();
}

class _OtherProfileViewState extends State<OtherProfileView> {
  var naming;
  getName() async {
    DocumentSnapshot name = await FirebaseFirestore.instance
        .collection("users")
        .doc(widget.server['uid'])
        // snapshots();
        .get();
    // name.data().
setState(() {
 naming = name.data()['name'];
});
    

  //    name.first.then((value) {
  //    print(value.data());
  //    Map values = value.data();
  //    var a = values.values.toList();
  //    print(a);
  //    print(a[4]);
  // naming = a[4];
   
  //     }  );

  }

  @override
  void initState() {
 getName();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   backgroundColor: Colors.transparent.withOpacity(0.6),
      // ),
      body: Container(
        color: Colors.grey[400],
        child: Column(
          children: [
            Expanded(
              flex: 1,
                          child: Stack(
                children: [
                  Container(
                    // padding: EdgeInsets.all(8),
                    color: Colors.black,
                    // height: MediaQuery.of(context).size.height * 0.55,
                    width: MediaQuery.of(context).size.width,
                    child: CachedNetworkImage(imageUrl: widget.image),
                  ),
                  Positioned(
                    bottom: 12,
                    right: 0,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(

                          // width: 300,
                          color: Colors.transparent.withOpacity(0.6),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      children: [
                                        Text(
                                          widget.server["phoneNumber"],
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                              // fontStyle: FontStyle.italic,
                                              fontWeight: FontWeight.w500),
                                        ),
                                        Text(
                                          naming != null ? '~ ' + naming : '',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                              // fontStyle: FontStyle.italic,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          )),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 40),
                child: Container(
                    child: Text(
                        "We will be adding new features soon. Thanks for patience.")),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
