import 'package:flutter/material.dart';


class OTP extends StatefulWidget {
  @override
  _OTPState createState() => _OTPState();
}

class _OTPState extends State<OTP> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            color: Color(0xFF001233),
          ),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(30, 35, 0, 0),
                  child: Text(
                    'SupChat',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 50),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 200, left: 20, right: 20),
                  child: Container(
                    width: 200,
                    height: 70,
                    child: Center(
                      child: TextField(
                        style: TextStyle(color: Colors.white, fontSize: 40),
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          enabledBorder: UnderlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.transparent)),
                          hintText: 'Enter your phone number',
                          hintStyle: TextStyle(color: Color(0x62FFFFFF)),
                        ),
                      ),
                    ),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      border: Border.all(width: 2, color: Colors.white),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      top: 15, left: 95, right: 95, bottom: 15),
                  child: Center(
                    child: InkWell(
                      onTap: () {},
                      child: Container(
                        height: 80,
                        width: 150,
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.only(
                                top: 5, bottom: 5, left: 5, right: 5),
                            child: Container(
                              child: Center(
                                child: Text(
                                  'Get OTP',
                                  style: TextStyle(
                                      color: Color(0xFF001233),
                                      fontSize: 30,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                              height: 70,
                              width: 140,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10))),
                            ),
                          ),
                        ),
                        decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            border: Border.all(width: 2, color: Colors.white)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
