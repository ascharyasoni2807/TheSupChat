import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:theproject/firebasestorage/databsemethods.dart';
import 'package:theproject/pages/home_page.dart';
import 'package:theproject/pages/login_page.dart';
// import 'package:theproject/repos/candidate.dart';
import 'package:theproject/stores/login_store.dart';
import 'package:theproject/theme.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({Key key}) : super(key: key);
  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
var chatroomstream;
  
  @override
  void initState() {
    super.initState();
      

    Future.delayed(Duration(seconds: 2), () {
      Provider.of<LoginStore>(context, listen: false)
          .isAlreadyAuthenticated()
          .then((result) {
        if (result) {
          // Candidate().getContacts();
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const HomePage()),
              (Route<dynamic> route) => false);
        } else {
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const LoginPage()),
              (Route<dynamic> route) => false);
             
        }
      });
    });
  }

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
                baseColor:   MyColors.maincolor,
                highlightColor: Colors.white,
                child: Text(
                  'TheSupChat',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 30.0,
                    fontWeight:
                    FontWeight.bold,
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
