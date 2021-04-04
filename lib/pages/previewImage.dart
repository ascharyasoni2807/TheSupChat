



import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:theproject/theme.dart';

import 'package:photo_view/photo_view.dart';

 

class PreviewPage extends StatelessWidget {

   final String imageUrl;

PreviewPage({this.imageUrl});
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        backgroundColor:Colors.black,
      ),
      body: Container(
        color: Colors.black,
        child: Center(
          child: CachedNetworkImage(imageUrl: imageUrl,
                      imageBuilder: (context, imageProvider) => PhotoView(
                         minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered * 2,
        imageProvider: imageProvider,
    ),
          
            placeholder: (context ,url) => Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircularProgressIndicator(strokeWidth: 2, backgroundColor: MyColors.maincolor, valueColor: AlwaysStoppedAnimation<Color>(Colors.white),),
            )),
          ),
        ),
      );
  }
}