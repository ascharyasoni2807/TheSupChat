import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../theme.dart';

class LoaderScreen extends StatelessWidget {
  const LoaderScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: MyColors.maincolor,
      body: Container(
        // color:MyColors.maincolor,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: Shimmer.fromColors(
                baseColor: MyColors.maincolor,
                highlightColor: Colors.white,
                child: Text(
                  'TheSupChat',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 30.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // child: Container(
              //     height: 100,
              //     // width: 500,
              //     child: Center(
              //         child: Text("TheSupChat",
              //             style:TextStyle(
              //                     color: MyColors.maincolor,
              //                     letterSpacing: 3,
              //                     fontSize: 30,fontFamily: 'Rightss',
              //                     fontWeight: FontWeight.bold)
              //             )))
            ),
          ],
        ),
      ),
    );
  }
}
