


import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class CachedImage extends StatelessWidget {
  final String imageUrl;

CachedImage({this.imageUrl});
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      // borderRadius: BorderRadius.circular(5),
      child: CachedNetworkImage(imageUrl: imageUrl,
      imageBuilder: (context, imageProvider) => Container(
    width: 200.0,
    height: 200.0,
     decoration: BoxDecoration(
        border: Border.all(
                    color: const Color(0xff536162),
                    width: 5,
                  ),
        image: DecorationImage(
          
        image: imageProvider, fit: BoxFit.cover),
        borderRadius: BorderRadius.only(
          bottomRight: Radius.circular(10),
          topRight:Radius.circular(10),
          bottomLeft: Radius.circular(10)
        ),),
  ),
      placeholder: (context ,url) => Center(child: CircularProgressIndicator()),),
    );
  }
}