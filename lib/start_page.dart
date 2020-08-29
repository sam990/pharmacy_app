import 'package:flutter/material.dart';
import 'register_verify_number.dart';
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
                  Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => VerifyNumber()));
                },
                textColor: Colors.white,
                child: Text("Register Patient"),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.0),),
                color: Colors.indigo,
              ),
            ),

            ButtonTheme(
              minWidth: 200,
              child: RaisedButton(
                onPressed: () {
                  Navigator.push(
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
          ],
        ),
      )
      );
  }
}