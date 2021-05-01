
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class HeroWidgetImage extends StatelessWidget {
  final context;
  final image;
  final userName;
  const HeroWidgetImage({this.context,this.image,this.userName});

  @override
  Widget build(context) {
  return Material(
    type: MaterialType.transparency,
      child: Container(
      color: Colors.transparent,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: ClipRRect(
          
            borderRadius: BorderRadius.circular(15.0),
                child: Container(
                  child: Stack(
                    children: [
                      Hero(
                        tag: 'image1',
                        child: CachedNetworkImage(imageUrl: image)
                        ),
                      Container(
                        padding:const EdgeInsets.all(5.0),
                          width: double.maxFinite,
                          color: Colors.transparent.withOpacity(0.6),
                          child: Text(
                            userName ,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.w500),
                          )),
                    ],
                  ),
                ),
          
          )  ),
      ),
    ),
  );
  }
}