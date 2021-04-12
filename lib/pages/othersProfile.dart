import 'package:cached_network_image/cached_network_image.dart';
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyColors.maincolor,
      ),
      body: Container(
          color: Colors.grey[400],
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  // padding: EdgeInsets.all(8),
                  color: Colors.black,
                  height: MediaQuery.of(context).size.height * 0.55,
                  width: MediaQuery.of(context).size.width,
                  child: CachedNetworkImage(imageUrl: widget.image),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(

                      // width: 300,
                      color: Colors.transparent.withOpacity(0.6),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              widget.server["phoneNumber"],
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  // fontStyle: FontStyle.italic,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      )),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 40),
              child: Container(
                  child: Text(
                      "We will be adding new features soon. Thanks for patience.")),
            ),
          ],
        ),
      ),
    );
  }
}
