import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:searchable_dropdown/searchable_dropdown.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_dashboard.dart';
import 'dart:async';
import 'select_order.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PrescriptionInputs extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => PrescriptionInputsState();
}

class PrescriptionInputsState extends State<PrescriptionInputs> {

  Future<List<Prescription>> futurePres;
  var nameMap = {};
  List<DropdownMenuItem> dropdownItems;

  List<String> values = [null];
  var totalCount = 1;
  var currState = 0;

  var colors = [Colors.red, Colors.blue[700], Colors.green];
  var desc = ['Save', 'Save', 'Saving'];

  @override
  void initState() {
    super.initState();
    futurePres = fetchPrescriptions();
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text('Prescription Input'),
        automaticallyImplyLeading: false,
      ),
      body: FutureBuilder<List<Prescription>>(
        future: futurePres,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView(
              children: buildCompanion(context),
            );
          }

          return Center(
            child: SpinKitChasingDots( color: Colors.black, size: 40.0,),
          );
        },
      ),

      floatingActionButton: Builder(
        builder: (context) => FloatingActionButton.extended(
            onPressed: () { handleClick(context); },
            backgroundColor: colors[currState],
            label: Text(desc[currState]),
            icon: getIcon(),
        ),
      ),
    );
  }

  List<Widget> buildCompanion(BuildContext context) {
    List<Widget> children = [];
    for (var i = values.length; i < totalCount; i++) {
      values.add(null);
    }
    for (var i = 0; i < totalCount; i++) {
      children.add(getDropdown(i, dropdownItems, values));
    }
    children.add(
        Center (
          child: RaisedButton.icon(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18.0),
            ),
            color: Colors.red,
            icon: Icon(Icons.add, color: Colors.white,),
            textColor: Colors.white,
            label: Text('Add More'),
            onPressed: () {
              if (currState == 2) {
                return;
              }

              this.setState(() {
                totalCount++;
                currState = 0;
              });
            },
          ),
        )
    );
    return children;
  }

  void handleClick(BuildContext context) async {
    if (currState == 2 || currState == 0) {
      return;
    }

    this.setState(() { currState = 2; });

    try {
      await savePres();
      Navigator.pushReplacement(context, MaterialPageRoute( builder: (context) => Dashboard() ));
    } catch (e) {
      print(e);
      this.setState(() {currState = 1;});
    }

  }

  Future<void> savePres() async {
    final ref  = FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser.phoneNumber).collection('prescriptions');
    
    for (var name in values) {
      await ref.doc(name).set({
        'name': name,
        'restricted' : nameMap[name].restricted,
        'approved' : false,
      });
    }

  }

  bool allFilled() {
    for (var i = 0; i < totalCount; i++) {
      if (values[i] == null) {
        return false;
      }
    }
    return true;
  }

  Widget getDropdown(int i, var dropdownItems, List<String> values) {
    return Padding(
      padding: EdgeInsets.all(20.0),
      child: SearchableDropdown.single(
        items: dropdownItems,
        onChanged: (String val) {
          this.setState(() {
            values[i] = val;
            currState = currState == 2 ? 2 : (allFilled() ? 1 : 0);
          });
        },
        value: values[i],
//        style: TextStyle( color: Colors.blue ),
        validator: (v) => v == null ? "Choose a medicine" : null,
        isExpanded: true,
        displayClearIcon: false,
      ),
    );
  }

  Widget getIcon() {
    switch(currState) {
      case 0: return Icon(Icons.error);
      case 1: return null;
      default: return SpinKitChasingDots(color: Colors.white, size: 20.0,);
    }
  }

  Future<List<Prescription>> fetchPrescriptions() async {
    var querySnapShot = await FirebaseFirestore.instance.collection('drugs').get();

    List<Prescription> presc = [];

    for (var i in querySnapShot.docs) {
      presc.add( Prescription(
        name: i.get('name'),
        restricted: i.get('restricted'),
        approved: false,
      ));
    }

    nameMap.clear();
    presc.forEach((element) { nameMap[element.name] = element; });
    dropdownItems = presc.map((e) => DropdownMenuItem( child: Text(e.name), value: e.name, )).toList();
    return presc;
  }

}