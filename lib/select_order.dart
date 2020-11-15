import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'order_verification.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SelectOrder extends StatefulWidget {
  @override
  _SelectOrderState createState() => _SelectOrderState();
}


class _SelectOrderState extends State<SelectOrder> {

  Future<List<Prescription>> futurePres;
  List<Prescription> pres = [];
  List<bool> values = [];


  @override
  void initState() {
    super.initState();
    futurePres = loadPrescriptions();
  }

  @override
  Widget build(BuildContext context) {

    bool selOne = chosenMinOne();

    return Scaffold(
      appBar: AppBar(
        title: Text('Picker'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: EdgeInsets.only(top: 20.0, left: 10.0, right: 10.0),
        child: FutureBuilder<List<Prescription>>(
          future: futurePres,
          builder: (context, snapshot) {
            print(snapshot);
            if (snapshot.hasData){
              pres.addAll(snapshot.data);
              List<Widget> children = [];
              for (var i = 0; i < snapshot.data.length; i++) {
                children.add(
                  CheckItem(
                    label: snapshot.data[i].name,
                    value: values[i],
                    restricted: snapshot.data[i].restricted,
                    approved: snapshot.data[i].approved,
                    onChanged: (value) {
                      this.setState(() {
                        values[i] = value;
                      });
                    },
                    padding: EdgeInsets.only(left: 10.0, right: 10.0),
                  )
                );

                children.add(SizedBox( height: 10.0 ));
              }

              return Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(Icons.album, color: Colors.green[100],),
                      SizedBox(width: 5.0,),
                      Text('Unrestricted drug'),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(Icons.album, color: Colors.blue[100],),
                      SizedBox(width: 5.0,),
                      Text('Restricted & Approved'),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(Icons.album, color: Colors.red[100],),
                      SizedBox(width: 5.0,),
                      Text('Restricted & Not Approved'),
                    ],
                  ),
                  SizedBox(height: 10.0,),
                  Expanded(
                    child: ListView(
                      children: children,
                    ),
                  ),
                ],
              );
            }

            return Center(
              child: SpinKitChasingDots( color: Colors.black, size: 40.0,),
            );
          },
        )
      ),

      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: selOne ? Colors.green : Colors.red,
        label: selOne ? Text('Order') : Text('Choose'),
        onPressed: () {
          if (!selOne) {
            return;
          }
          Navigator.push(context, MaterialPageRoute( builder: (context) => OrderVerification(needsVerify: needsVerification(),) ) );
        },
      ),
    );
  }


  bool needsVerification() {
    for (var i = 0; i < values.length; i++) {
      if (values[i] && pres[i].restricted) {
        return true;
      }
    }
    return false;
  }

  bool chosenMinOne() {
    for (var i in values) {
      if (i) {
        return true;
      }
    }
    return false;
  }

  Future<List<Prescription>> loadPrescriptions() async {

    var querySnapshot = await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser.phoneNumber).collection('prescriptions').get();

    List<Prescription> presc = querySnapshot.docs.map((e) => Prescription(
      name: e.get('name'),
      restricted: e.get('restricted'),
      approved: e.get('approved'),
    )).toList();

    values = List.filled(presc.length, false);

    return presc;
  }

}




class CheckItem extends StatelessWidget {

  CheckItem({
    this.label,
    this.onChanged,
    this.value,
    this.padding = const EdgeInsets.all(10.0),
    this.restricted,
    this.approved,
  });

  final Function onChanged;
  final String label;
  final bool value;
  final EdgeInsets padding;
  final bool restricted;
  final bool approved;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (restricted && !approved) {
          return;
        }
        onChanged(!value);
      },

      child: Ink(
        color: getColor(),
        child: Padding(
          padding: padding,
          child: Row(
            children: <Widget>[
              Expanded(child: Text(label)),
              Checkbox(
                value: value,
                onChanged: (bool newValue) {
                  if (restricted && !approved) {
                    return;
                  }
                  onChanged(newValue);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color getColor() {
    if (restricted) {
      if (approved) {
        return Colors.blue[100];
      } else {
        return Colors.red[100];
      }
    } else {
      return Colors.green[100];
    }
  }
}


class Prescription {
  final String name;
  final bool restricted;
  final bool approved;

  Prescription(
  {
    this.name,
    this.restricted,
    this.approved,
  });
}