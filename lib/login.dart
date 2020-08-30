import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:pharmacyapp/user_dashboard.dart';
import 'package:pin_entry_text_field/pin_entry_text_field.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'dart:async';
import 'user_dashboard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'start_page.dart';

class Login extends StatefulWidget {
  @override
  LoginState createState() => LoginState();
}


class LoginState extends State<Login> {

  PhoneNumber _number;
  bool valid = false;
  bool otpMode = false;
  bool isWaiting = false;
  bool verified = false;
  String verifyID;
  int resendCode;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () { return  gotoStart(context); },
      child: Scaffold(
        body:
        Container(
            margin: const EdgeInsets.only(left: 20.0, right: 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text("Mobile Number", style: TextStyle( fontSize: 20, fontWeight: FontWeight.bold),),
                SizedBox(height: 10,),
                InternationalPhoneNumberInput(
                  onInputChanged: (PhoneNumber number) {
                    _number = number;
                  },
                  onInputValidated: (bool val) {
                    if (val != valid) {
                      setState(() {
                        valid = val;
                      });
                    }
                  },

                  selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
                  initialValue: PhoneNumber(isoCode: 'IN'),
                  isEnabled: !otpMode,
                ),

                if(otpMode) Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(height: 50),
                      Text("Enter OTP", style: TextStyle( fontSize: 20, fontWeight: FontWeight.bold),),
                      SizedBox(height: 10),
                      Builder(
                        builder: (context) => PinEntryTextField(
                          fields: 6,
                          fontSize: 15.0,
                          onSubmit: (String pin) {
                            if (isWaiting) {
                              return;
                            }
                            this.setState(() {isWaiting = true;});
                            verifyOTP(context, pin);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
        ),
        floatingActionButton: Builder(
          builder: (context) => FloatingActionButton.extended(
            backgroundColor: valid ? Colors.green : Colors.red,
            label: getLabel(),
            icon: getIcon(),
            onPressed: () { handleClick(context); },
          ),
        ),
      ),
    );
  }

  Text getLabel() {
    if (verified) {
      return Text('Next');
    }
    else if (isWaiting) {
      if (otpMode) {
        return Text('Verifying OTP');
      } else {
        return Text('Sending OTP');
      }
    }
    else if (otpMode) {
      return Text('Enter OTP');
    }
    else {
      return Text('Send OTP');
    }
  }

  dynamic getIcon() {
    if (verified) {
      return Icon(Icons.arrow_forward);
    }
    else if (isWaiting) {
      return SpinKitChasingDots( color: Colors.white, size: 20.0,);
    }
    else if (!otpMode) {
      if (valid) {
        return Icon(Icons.check);
      } else {
        return Icon(Icons.error);
      }
    }
    else {
      return null;
    }
  }

  void verifyOTP(BuildContext context, String smsCode) async {
    PhoneAuthCredential phoneAuthCredential = PhoneAuthProvider.credential(verificationId: verifyID, smsCode: smsCode);

    try {
      await FirebaseAuth.instance.signInWithCredential(phoneAuthCredential);
      this.setState(() {
        isWaiting = false;
        verified = true;
      });
    } catch (e) {
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text('Wrong OTP'),
      ));
      this.setState(() {
        isWaiting = false;
      });
    }

  }

  void handleClick(BuildContext context) async {
    if (!valid || isWaiting) {
      return;
    }
    else if (verified) {
      gotoNext(context);
    }
    else if (!otpMode) {
      this.setState(() {
        isWaiting = true;
      });

      if ( ! await hasRegistered()) {
        Scaffold.of(context).showSnackBar(SnackBar(
          content: Text('User not registered'),
        ));

        this.setState(() {
          isWaiting = false;
        });
        return;
      }

      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: _number.toString(),
        verificationCompleted: (PhoneAuthCredential credential) async {
          try{
            await FirebaseAuth.instance.signInWithCredential(credential);
            this.setState(() {
              isWaiting = false;
              verified = true;
              otpMode = false;
            });
          } catch (e) {
            print(e);
            this.setState(() {
              isWaiting = false;
              otpMode = false;
            });
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          Scaffold.of(context).showSnackBar(SnackBar(
            content: Text('Some error occurred'),
          ));

          this.setState(() {
            otpMode = false;
            isWaiting = false;
          });
        },
        codeSent: (String verificationId, int resendToken) {
          this.setState(() {
            otpMode = true;
            isWaiting = false;
            verifyID = verificationId;
            resendCode = resendToken;
          });
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    }
  }

  Future<bool> hasRegistered() async {
    final ref = FirebaseFirestore.instance.collection('users');
    var res = await ref.doc(_number.toString()).get();
    return res.exists;
  }

  void gotoNext(BuildContext context) {
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (context) => Dashboard() )
    );
  }

  Future<bool> gotoStart(BuildContext context) async {
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (context) => StartPage() )
    );
    return false;
  }
}





