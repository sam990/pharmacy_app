import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'register_verify_number.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login.dart';



class StartPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return
      Scaffold(
//        backgroundColor: Colors.grey[900],
        body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ButtonTheme(
              minWidth: 200,
              child: RaisedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => VerifyNumber()));
                },
                textColor: Colors.white,
                child: Text("Register"),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.0),),
                color: Colors.indigo,
              ),
            ),

            ButtonTheme(
              minWidth: 200,
              child: RaisedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => Login()));
                },
                textColor: Colors.white,
                child: Text("Login"),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.0),),
                color: Colors.red,
              ),
            ),


            /*ButtonTheme(
              minWidth: 200,
              child: RaisedButton(
                onPressed: () {
                  pushData(context);
                },
                textColor: Colors.white,
                child: Text("Start"),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.0),),
                color: Colors.red,
              ),
            ),*/
          ],
        ),
      )
      );
  }

  /*void pushData(BuildContext context) async {
    final ref = FirebaseFirestore.instance.collection('clinics');

    for (var line in data) {
      await ref.add(
        {
          'name' : line[0],
          'address' : line[1],
          'city' : line[2],
          'telephone' : line[3],
          'type' : line[4],
          'latitude' : line[5],
          'longitude' : line[6],
        }
      );
    }

    Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Login()));
  }*/

}