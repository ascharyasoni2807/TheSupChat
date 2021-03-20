import 'package:flutter/material.dart';

void main() {
  runApp(FirstScreen());
}

class FirstScreen extends StatelessWidget {
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
                  padding: const EdgeInsets.only(left: 30, top: 100),
                  child: Text(
                    'A new way to connect \nwith your favourite \npeople',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 35),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 0, right: 0, top: 0),
                  child: Container(
                    height: 300,
                    width: 300,
                    child: FittedBox(
                      child: Image.asset(
                        'images/connected.png',
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      top: 15, left: 95, right: 95, bottom: 15),
                  child: Center(
                    child: Container(
                      height: 100,
                      width: 200,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.only(
                              top: 5, bottom: 5, left: 5, right: 5),
                          child: Container(
                            child: Center(
                              child: Text(
                                'Login/Sign up',
                                style: TextStyle(
                                    color: Color(0xFF001233),
                                    fontSize: 30,
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                            height: 90,
                            width: 190,
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
