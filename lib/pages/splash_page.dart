import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:thegorgeousotp/pages/home_page.dart';
import 'package:thegorgeousotp/pages/login_page.dart';
import 'package:thegorgeousotp/stores/login_store.dart';
import 'package:thegorgeousotp/theme.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({Key key}) : super(key: key);
  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
 
  @override
  void initState() {
    super.initState();
    Provider.of<LoginStore>(context, listen: false).isAlreadyAuthenticated().then((result) {
      if (result) {
        Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const HomePage()), (Route<dynamic> route) => false);
      } else {
        Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const LoginPage()), (Route<dynamic> route) => false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: MyColors.maincolor,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
 children: [
    Center( child: Container(
                                        height: 240,
                                        width: 500,
                                        constraints: const BoxConstraints(
                                          maxWidth: 500
                                        ),
                                        //Color(0xFFE1E0F5)
                                        margin: const EdgeInsets.only(top: 70),
                                        decoration: const BoxDecoration(color: MyColors.maincolor , borderRadius: BorderRadius.all(Radius.circular(1000))),
                                       child: Center(
                                         child: Text("TheSupChat",
                                         style:  GoogleFonts.redressed(
                                              textStyle: TextStyle(
                              color: Colors.white,
                              letterSpacing: 3,
                              fontSize: 60,
                              fontWeight: FontWeight.bold)
                                         )
                                         )
                                         )   ),
                                    ),
 ],
      ),

    );
  }
}
