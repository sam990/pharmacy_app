import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pharmacyapp/clinic.dart';
import 'package:searchable_dropdown/searchable_dropdown.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class ClinicPage extends StatefulWidget {
  @override
  _ClinicPageState createState() => _ClinicPageState();
}

class _ClinicPageState extends State<ClinicPage> {
  final allTypes = [
    'LONG TERM CARE',
    'MILITARY',
    'SPECIAL',
    'GENERAL ACUTE CARE',
    'WOMEN',
    'PSYCHIATRIC',
    'CHILDREN',
    'REHABILITATION',
    'CRITICAL ACCESS'
  ];
  var dropDownItems;

  String selectedType = null;

  @override
  void initState() {
    super.initState();
    dropDownItems = allTypes
        .map((e) => DropdownMenuItem(
              child: Text(e),
              value: e,
            ))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    Future<List<Clinic>> clinicFuture = null;

    if (selectedType != null) {
      clinicFuture = getClinics(selectedType);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Check Clinics'),
        automaticallyImplyLeading: false,
      ),
      body: Column(mainAxisSize: MainAxisSize.max, children: <Widget>[
        Padding(
          padding: EdgeInsets.all(8.0),
          child: SearchableDropdown.single(
            items: dropDownItems,
            onChanged: (String val) {
              this.setState(() {
                selectedType = val;
              });
            },
            isExpanded: true,
            value: selectedType,
            hint: 'Select clinic type',
          ),
        ),
        SizedBox(
          height: 10.0,
        ),
        getChild(selectedType != null, clinicFuture),
      ]),
    );
  }

  Widget getChild(bool selected, Future<List<Clinic>> f) {
    if (selected) {
      return FutureBuilder<List<Clinic>>(
        future: f,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Expanded(
              child: ListView(
                children: snapshot.data,
              ),
            );
          }

          return Center(
            child: SpinKitChasingDots(
              color: Colors.black,
              size: 40.0,
            ),
          );
        },
      );
    } else {
      return Container();
    }
  }

  Future<List<Clinic>> getClinics(String type) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('clinics')
        .where('type', isEqualTo: type)
        .get();
    return snapshot.docs
        .map((e) => Clinic(
              name: e.get('name'),
              address: e.get('address'),
              city: e.get('city'),
              telephone: e.get('telephone'),
              type: e.get('type'),
              latitude: e.get('latitude'),
              longitude: e.get('longitude'),
            ))
        .toList();
  }
}
