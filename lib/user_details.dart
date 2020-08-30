import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:darwin_camera/darwin_camera.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';
import 'prescription_input.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:async';



class UserDetails extends StatefulWidget {
  @override
  UserDetailsState createState() => UserDetailsState();
}


class UserDetailsState extends State<UserDetails> {

  bool photoUploaded = false;
  bool finalCompleted = false;

  int currState = 0;

  var values = ["", "", "", "", "", "", "", ""];
  static const fields = ["Name", "Age", "Gender", "House no./Street", "City", "State", "Country", "Pincode"];

  var colors = [Colors.red, Colors.blue[700], Colors.blueGrey[800], Colors.green];
  var desc = ['Fill Details', 'Save', 'Saving', 'Next'];
  var faceID;
  var personID;

  @override
  Widget build(BuildContext context) {

    List<Widget> widg = List();

    widg.add(
      Align(
        child: PhotoCompanion( callback: (String per, face){
          if (per != null && face != null) {
            this.personID = per;
            this.faceID = face;
            this.photoUploaded = true;
          } else {
            this.photoUploaded = false;
          }
          this.refreshStatus();
        },),
      ),
    );

    for (var i = 0; i < fields.length; i++) {
      widg.add(getTextField(i, fields[i]));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('User Details'),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(12.0),
        children: widg,
      ),

      floatingActionButton: Builder(
        builder: (context) => FloatingActionButton.extended(
          icon: getIcon(),
          label: Text(desc[currState]),
          backgroundColor: colors[currState],
          onPressed: () { handleClick(context); },
        ),
      ),
    );
  }

  void handleClick( BuildContext context ) async {
    if (currState == 0 || currState == 2) {
      return;
    }
    if (currState == 1) {
      this.setState(() { currState = 2; });

      saveData(context);

    }
    else {
      // navigate next
      Navigator.pushReplacement(context, MaterialPageRoute( builder: (context) => PrescriptionInputs()));
    }
  }

  Widget getTextField(int i, String hint) {
    return Padding(
      padding: EdgeInsets.only(top: 15.0),
      child: TextField(
      onChanged: (val) => this.updateValue(i, val),
      enabled: currState < 2,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        contentPadding: const EdgeInsets.only(left: 30.0),
        fillColor: Colors.grey[300],
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: BorderSide.none,
          gapPadding : 20.0,
        ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0),
            borderSide: BorderSide.none,
            gapPadding : 20.0,
          )
      ),
    ),
    );
  }

  bool completedState() {
//    return true; // debug
    if (!photoUploaded) {
      return false;
    }
    for (final i in values) {
      if (i.isEmpty) {
        return false;
      }
    }
    return true;
  }

  void updateValue(int i, String val) {
    values[i] = val;
    refreshStatus();
  }

  void refreshStatus() {
    bool comp = completedState();
    if (comp != finalCompleted && currState < 2) {
      this.setState(() { finalCompleted = comp; currState = comp ? 1 : 0; });
    }
  }

  Widget getIcon() {
    switch(currState) {
      case 0: return Icon(Icons.create);
      case 1: return null;
      case 2: return SpinKitChasingDots(color: Colors.white, size: 20.0,);
      default: return Icon(Icons.arrow_forward);
    }
  }

  void saveData(BuildContext context) async {
    try {
      final auth = FirebaseAuth.instance;
      await auth.currentUser.updateProfile(displayName: fields[0]);

      CollectionReference users = FirebaseFirestore.instance.collection('users');

      await users.doc(auth.currentUser.phoneNumber).set({
        'name': values[0],
        'age' : values[1],
        'gender': values[2],
        'street' : values[3],
        'city' : values[4],
        'state': values[5],
        'country': values[6],
        'pin' : values[7],
        'face_id' : faceID,
        'person_id' : personID,
      });

      this.setState(() {currState = 3;});

    } catch(e) {
      print(e);
      Scaffold.of(context).showSnackBar(SnackBar(content: Text('Some error occurred'),));
      this.setState(() { currState = 1; });
    }
  }
}


class PhotoCompanion extends StatefulWidget {
  final Function callback;
  PhotoCompanion({this.callback});

  PhotoCompanionState createState() => PhotoCompanionState();

}

class PhotoCompanionState extends State<PhotoCompanion> {

  int currState = 0;
  var colors = [Colors.red, Colors.blue[700], Colors.green];
  var desc = ['Take Photo', 'Uploading Photo', 'Photo Uploaded'];

  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18.0),),
      textColor: Colors.white,
      color: colors[currState],
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          getIcon(),
          SizedBox(width: 3.0,),
          Text(desc[currState]),
        ],
      ),
      onPressed: () { handleClick(context); },
    );
  }

  Widget getIcon() {
    switch(currState) {
      case 0: return Icon(Icons.camera_enhance);
      case 1: return SpinKitChasingDots(color: Colors.white, size: 20.0,);
      default: return Icon(Icons.check);
    }
  }

  void handleClick(BuildContext context) async {
    if (currState == 1) {
      return;
    }

    final path = join(
      (await getTemporaryDirectory()).path,
      '${DateTime.now()}.png',
    );
    var cameras = await availableCameras();
    DarwinCameraResult result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DarwinCamera(
          cameraDescription: cameras,
          filePath: path,
          resolution: ResolutionPreset.high,
          defaultToFrontFacing: true,
          quality: 100,
        ),
      ),
    );

    if (result == null || !result.isFileAvailable) {
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text('Error taking photo'),
      ));
      return;
    }

    this.setState(() { currState = 1; });

    final ids = await uploadFace(path);

    if (ids[0] != null && ids[1] != null) {
      this.setState(() {currState = 2;});
      widget.callback(ids[0], ids[1]);
    } else {
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text('Error uploading photo'),
      ));
      this.setState(() { currState = 0; });
    }
  }

  Future<String> createPerson() async {
    final url = 'https://pharma.cognitiveservices.azure.com/face/v1.0/persongroups/users_group/persons';

    try {
      final response = await http.post(url, headers: {
        HttpHeaders.contentTypeHeader : "application/json",
        'Ocp-Apim-Subscription-Key': '9f26b69aed9845d0ab795a5cb51913a2',
      }, body: jsonEncode({ 'name' : FirebaseAuth.instance.currentUser.phoneNumber, }));
      final js = json.decode(response.body);
      return js["personId"] ?? null;
    } catch(e , stacktrace) {
      print(e);
      print(stacktrace);
      return null;
    }
  }

  Future<List<String>> uploadFace(String filePath) async {
    final personId = await createPerson();
    if (personId == null) {
      return [null, null];
    }

    final url = 'https://pharma.cognitiveservices.azure.com/face/v1.0/persongroups/users_group/persons/$personId/persistedFaces?detectionModel=detection_01';

    File file = File(filePath);
    var bytes = await file.readAsBytes();
    try {
      final response = await http.post(url, headers: {
        HttpHeaders.contentTypeHeader: 'application/octet-stream',
        'Ocp-Apim-Subscription-Key': '9f26b69aed9845d0ab795a5cb51913a2',
      }, body: bytes);
      print(response.body);
      final js = json.decode(response.body);
      return [personId, js["persistedFaceId"]];
    } catch (e) {
      print(e);
      return null;
    }
  }

}