import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:darwin_camera/darwin_camera.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';
import 'prescription_input.dart';
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

  @override
  Widget build(BuildContext context) {

    List<Widget> widg = List();

    widg.add(
      Align(
        child: PhotoCompanion( callback: (bool res){
          this.photoUploaded = res;
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

  void handleClick( BuildContext context ) {
    if (currState == 0 || currState == 2) {
      return;
    }
    if (currState == 1) {
      this.setState(() { currState = 2; });
      Timer(Duration(seconds: 3), () {this.setState(() {currState = 3;});});
    }
    else {
      // navigate next
      Navigator.push(context, MaterialPageRoute( builder: (context) => PrescriptionInputs()));
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
  var cameras;

  @override
  void initState() async{
    super.initState();
    var cameras = await availableCameras();
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
    Timer(Duration(seconds: 3), () {this.setState(() {currState = 2;});});
    widget.callback(true);
  }
}