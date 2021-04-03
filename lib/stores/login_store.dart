import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';
import 'package:thegorgeousotp/firebasestorage/databsemethods.dart';
import 'package:thegorgeousotp/pages/home_page.dart';
import 'package:thegorgeousotp/pages/login_page.dart';
import 'package:thegorgeousotp/pages/onboardprofile.dart';
import 'package:thegorgeousotp/pages/otp_page.dart';
import 'package:thegorgeousotp/pages/profilepage.dart';
import 'package:thegorgeousotp/repos/candidate.dart';

part 'login_store.g.dart';

class LoginStore = LoginStoreBase with _$LoginStore;

abstract class LoginStoreBase with Store {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String actualCode;

  @observable
  bool isLoginLoading = false;
  @observable
  bool isOtpLoading = false;

  @observable
  GlobalKey<ScaffoldState> loginScaffoldKey = GlobalKey<ScaffoldState>();
  @observable
  GlobalKey<ScaffoldState> otpScaffoldKey = GlobalKey<ScaffoldState>();

  @observable
  User firebaseUser;

  @action
  Future<bool> isAlreadyAuthenticated() async {
    firebaseUser = await _auth.currentUser;

    if (firebaseUser != null) {
      return true ;
    } else {
      return false;
    }
  }
// Candidate _userFromFirebaseUser(User user) {
//   print(user.phoneNumber);
//     return user != null
//         ? Candidate(
//             uid: user.uid,
//             phoneNumber: user.phoneNumber
//           )
//         : null;
//   }
  @action
  Future<void> getCodeWithPhoneNumber(BuildContext context, String phoneNumber) async {
    isLoginLoading = true;

    await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (AuthCredential auth) async {
          await _auth
              .signInWithCredential(auth)
              .then((UserCredential value) {
            if (value != null && value.user != null) {
              print('Authentication successful');
              onAuthenticationSuccessful(context, value);
            } else {
              loginScaffoldKey.currentState.showSnackBar(SnackBar(
                behavior: SnackBarBehavior.floating,
                backgroundColor: Colors.red,
                content: Text('Invalid code/invalid authentication', style: TextStyle(color: Colors.white),),
              ));
            }
          }).catchError((error) {
            loginScaffoldKey.currentState.showSnackBar(SnackBar(
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.red,
              content: Text('Something has gone wrong, please try later', style: TextStyle(color: Colors.white),),
            ));
          });
        },
        verificationFailed: (FirebaseAuthException authException) {
          print('Error message: ' + authException.message);
          loginScaffoldKey.currentState.showSnackBar(SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red,
            content: Text('The phone number format is incorrect. Please enter your number in E.164 format. [+][country code][number]', style: TextStyle(color: Colors.white),),
          ));
          isLoginLoading = false;
        },
        codeSent: (String verificationId, [int forceResendingToken]) async {
          actualCode = verificationId;
          isLoginLoading = false;
          await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const OtpPage()));
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          actualCode = verificationId;
        }
    );
  }

  @action
  Future<void> validateOtpAndLogin(BuildContext context, String smsCode) async {
    isOtpLoading = true;
    final AuthCredential _authCredential = PhoneAuthProvider.credential(
        verificationId: actualCode, smsCode: smsCode);

    await _auth.signInWithCredential(_authCredential).catchError((error) {
      isOtpLoading = false;
      // ignore: deprecated_member_use
      otpScaffoldKey.currentState.showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.red,
        content: Text('Wrong code ! Please enter the last code received.', style: TextStyle(color: Colors.white),),
      ));
    }).then((UserCredential authResult) {
      if (authResult != null && authResult.user != null) {
        print('Authentication successful');
       
        // HomePage(uid : authResult.user.uid ,phoneNumber :authResult.user.phoneNumber);
        onAuthenticationSuccessful(context, authResult);
      }
    });
  }

  Future<void> onAuthenticationSuccessful(BuildContext context, UserCredential result) async {
    isLoginLoading = true;
    isOtpLoading = true;

    firebaseUser = result.user;

       try { final snapShot = await FirebaseFirestore.instance
      .collection('users')
      .doc(result.user.uid)
      .get();

    if (snapShot == null || !snapShot.exists) {
      print("hurrrrrrrrrrrrrrrrrayyyy  your  new here    ");
      print(snapShot.data());
        Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => OnboardProfilePage(user : result.user)), (Route<dynamic> route) => false);
  // Document with id == docId doesn't exist.
    }else {
        print("hurrrrrrrrrrrrrrrrrayyyy  your  already exist there   ");
        Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) =>  HomePage()), (Route<dynamic> route) => false);
    }}catch(e) {
      print(e);
    }
  
        //  _userFromFirebaseUser(result.user);

         
       

    isLoginLoading = false;
    isOtpLoading = false;
  }

  @action
  Future<void> signOut(BuildContext context) async {
    await _auth.signOut();
    await Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const LoginPage()), (Route<dynamic> route) => false);
    firebaseUser = null;
  }
}