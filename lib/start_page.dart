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
    var rand = Random();
    final ref = FirebaseFirestore.instance.collection('drugs');
    names.forEach((element) async {
      await ref.doc(element).set(
        {
          'name' : element,
          'restricted' : rand.nextDouble() >= 0.6,
        }
      );
    });

    Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Login()));
  }*/

}