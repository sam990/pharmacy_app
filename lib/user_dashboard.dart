import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pharmacyapp/prescriptions_add.dart';
import 'package:pharmacyapp/start_page.dart';
import 'select_order.dart';


class Dashboard extends StatelessWidget {

  final Future<String> userName = getUserName();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
        automaticallyImplyLeading: false,
        actions: <Widget>[
          PopupMenuButton(
            onSelected: (item) { logout(context, item); },
            itemBuilder: (BuildContext context) =>
            [
              PopupMenuItem(
                value: 'logout',
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(Icons.person_outline, color: Colors.black,),
                      SizedBox(width: 2.0,),
                      Text('Logout'),
                    ],
                  ),
                ),
              )
            ],
          )
        ],
      ),

      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[

            FutureBuilder<String>(
              future: userName,
              builder: (context, snapshot){
                if (snapshot.hasData) {
                  return Text('Hola ' + snapshot.data, style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),);
                }
                return SpinKitChasingDots( color: Colors.black, size: 20.0,);
              },
            ),

            SizedBox(height: 100.0,),

            ButtonTheme(
              minWidth: 200,
              child: RaisedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PrescriptionAdd()));
              },
                textColor: Colors.white,
                child: Row (
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Icon(Icons.add),
                    SizedBox(width: 5.0,),
                    Text('Add Prescriptions'),
                  ],
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.0),),
                color: Colors.teal[800],
              ),
            ),

            ButtonTheme(
              minWidth: 200,
              child: RaisedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SelectOrder()));
              },
                textColor: Colors.white,
                child: Row (
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Icon(Icons.refresh),
                    SizedBox(width: 5.0,),
                    Text('Order Refill'),
                  ],
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.0),),
                color: Colors.blueGrey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Future<String> getUserName() async {
    return (await FirebaseFirestore.instance.collection('users').doc(
      FirebaseAuth.instance.currentUser.phoneNumber
    ).get()).get('name');
  }

  void logout(BuildContext context, item) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(context, MaterialPageRoute( builder: (context) => StartPage() ));
  }
}