import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:pin_entry_text_field/pin_entry_text_field.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'dart:async';
import 'user_details.dart';

class VerifyNumber extends StatefulWidget {
  @override
  VerifyNumberState createState() => VerifyNumberState();
}


class VerifyNumberState extends State<VerifyNumber> {

  PhoneNumber _number;
  bool valid = false;
  bool otpMode = false;
  bool isWaiting = false;
  bool verified = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
//                              Scaffold.of(context).showSnackBar(
//                                  SnackBar(
//                                    content: Text("OTP Not Matched"),
//                                  )
//                              );
                              Timer(Duration(seconds: 3), () => {
                                this.setState(() {valid = true; verified = true; isWaiting = false;})
                              });
                              this.setState(() {isWaiting = true;});
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

  void handleClick(BuildContext context) {
    if (!valid || isWaiting) {
      return;
    }
    else if (verified) {
      Navigator.push(context,
        MaterialPageRoute(builder: (context) => UserDetails() )
      );
    }
    else if (!otpMode) {

      Timer(Duration(seconds: 3), () => {
        this.setState(() { isWaiting = false; valid = false; otpMode = true; })
      });

      this.setState(() {
        isWaiting = true;
      });
    }

  }
}





