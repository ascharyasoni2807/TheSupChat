


import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:theproject/theme.dart';

class CachedImage extends StatelessWidget {
  final String imageUrl;

CachedImage({this.imageUrl});
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      // borderRadius: BorderRadius.circular(5),
      child: CachedNetworkImage(imageUrl: imageUrl,
      imageBuilder: (context, imageProvider) => Container(
    width: 220.0,
    height: 220.0,
     decoration: BoxDecoration(
        border: Border.all(
                    color: Colors.black ,
                    width: 3,
                  ),
        image: DecorationImage(
          
        image: imageProvider, fit: BoxFit.cover),
        borderRadius: BorderRadius.only(
          bottomRight: Radius.circular(10),
          topLeft:Radius.circular(10),
          bottomLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
        ),
  ),
      // ignore: prefer_const_constructors
      placeholder: (context ,url) => Padding(
        padding: const EdgeInsets.all(6.0),
        child: CircularProgressIndicator(strokeWidth: 2, backgroundColor: MyColors.maincolor, valueColor: AlwaysStoppedAnimation<Color>(Colors.white),),
      )),
    );
  }
}


class BuildPopUp extends StatelessWidget {

  final context;
  final image;
  final name;
  BuildPopUp({this.context,this.image,this.name});

  @override
  Widget build(BuildContext context) { {
  return Center(
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
          child: Stack(
            children: [
              CachedNetworkImage(imageUrl: image),
              Container(
                  width: 300,
                  color: Colors.transparent.withOpacity(0.6),
                  child: Text(
                    name,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w500),
                  )),
            ],
          ),
        )),
  );
}
  }
}