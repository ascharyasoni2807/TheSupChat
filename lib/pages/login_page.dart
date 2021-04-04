import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:theproject/pages/permission.dart';
import 'package:theproject/stores/login_store.dart';
import 'package:theproject/theme.dart';
import 'package:theproject/widgets/loader_hud.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key key}) : super(key: key);
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Consumer<LoginStore>(
      builder: (_, loginStore, __) {
        return Observer(
          builder: (_) => LoaderHUD(
            inAsyncCall: loginStore.isLoginLoading,
            child: Scaffold(
              backgroundColor: Colors.white,
              key: loginStore.loginScaffoldKey,
              body: SingleChildScrollView(
                child: Container(
                  color: MyColors.maincolor,
                  height: MediaQuery.of(context).size.height,
                  child: Column(
                    children: <Widget>[
                      Expanded(
                        flex: 2,
                        child: Column(
                          children: <Widget>[
                            Container(
                              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              child: Stack(
                                children: <Widget>[
                                  Center(
                                    child: Container(
                                      height: 150,
                                      width: 500,
                                      constraints: const BoxConstraints(
                                        maxWidth: 500
                                      ),
                                      //Color(0xFFE1E0F5)
                                      margin: const EdgeInsets.only(top: 70),
                                      decoration: const BoxDecoration(color: Colors.white , borderRadius: BorderRadius.all(Radius.circular(1000))),
                                     child: Center(
                                       child: Text("TheSupChat",
                                       style:  GoogleFonts.redressed(
                                            textStyle: TextStyle(
                            color: MyColors.maincolor,
                            letterSpacing: 2,
                            fontSize: 65,
                            fontWeight: FontWeight.bold)
                                       )
                                       )
                                  
                                       )   ),
                                  ),
                                
                             
                                ],
                              ),
                            ),
                            
                           
                             Container(
                                margin: const EdgeInsets.symmetric(horizontal: 10 , vertical: 45),
                                // ignore: prefer_const_constructors
                                child: Text('OTP VERIFICATION',
                                    style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w800 , ))),
                           
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Column(
                          children: <Widget>[
                            
                            Container(
                                constraints: const BoxConstraints(
                                    maxWidth:500
                                    
                                ),
                                margin: const EdgeInsets.symmetric(horizontal: 10),
                                child: RichText(
                                  textAlign: TextAlign.center,
                                  text: TextSpan(children: <TextSpan>[
                                    TextSpan(text: 'We will send you an ', style: TextStyle(color:Colors.white)),
                                    TextSpan(
                                        text: 'One Time Password ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                    TextSpan(text: 'on this mobile number', style: TextStyle(color:Colors.white)),
                                  ]),
                                )),
                            Container(
                              height: 40,
                              constraints: const BoxConstraints(
                                maxWidth: 200
                              ),
                              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              child: CupertinoTextField(
                                
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                decoration: BoxDecoration(
                                  
                                  color: Colors.white,
                                  border: Border.all(),
                                  borderRadius: const BorderRadius.all(Radius.circular(10))
                                ),
                                controller: phoneController,
                                
                                clearButtonMode: OverlayVisibilityMode.always,
                                keyboardType: TextInputType.phone,
                                maxLines: 1,
                                placeholder: '+91...',
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              constraints: const BoxConstraints(
                                  maxWidth: 500
                              ),
                              child: RaisedButton(
                                onPressed: () async{
                                  if (phoneController.text.isNotEmpty) {
                                   await ContactPermission().permissioncheck2(context);
                                    loginStore.getCodeWithPhoneNumber(context, phoneController.text.toString());
                                  } else {
                                    loginStore.loginScaffoldKey.currentState.showSnackBar(SnackBar(
                                      behavior: SnackBarBehavior.floating,
                                      backgroundColor: Colors.red,
                                      content: Text(
                                        'Please enter a phone number',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ));
                                  }
                                },
                                color: Colors.white,
                                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(14))),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                     const Text(
                                        'Next',
                                        style: TextStyle(color:MyColors.maincolor),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: const BoxDecoration(
                                          borderRadius:  BorderRadius.all(Radius.circular(20)),
                                          color: MyColors.buttoncolor,
                                        ),
                                        child: const Icon(
                                          Icons.arrow_forward_ios,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
