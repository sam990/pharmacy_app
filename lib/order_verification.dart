import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'dart:async';
import 'package:darwin_camera/darwin_camera.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

class OrderVerification extends StatefulWidget {
  final needsVerify;

  OrderVerification({this.needsVerify});

  @override
  _OrderVerificationState createState() => _OrderVerificationState();
}

class _OrderVerificationState extends State<OrderVerification> {
  int currentState = 0;
  double matchConfidence = 0.0;

  @override
  void initState(){
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Confirmation'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: getDesc(),
      ),
      floatingActionButton: (widget.needsVerify && currentState != 3)
          ? FloatingActionButton.extended(
              label: currentState == 1 ? Text('Verifying') : Text('Verify'),
              icon: currentState == 1
                  ? SpinKitChasingDots(
                      color: Colors.white,
                      size: 20.0,
                    )
                  : null,
              onPressed: () { handleClick(context); },
            )
          : null,
    );
  }

  void handleClick(BuildContext context) async {
    if (currentState == 1) {
      return;
    }
    setState(() {
      currentState = 1;
    });

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
      this.setState(() {
        currentState = 2;
      });
      return;
    }

    // await result
    final res = await getMatch(path);
    if (res >= 0.75) {
      this.setState(() {
        matchConfidence = res;
        currentState = 3;
      });
    } else {
      this.setState(() {
        currentState = 2;
      });
    }
  }

  Future<String> getPersonId() async {
    String phone = FirebaseAuth.instance.currentUser.phoneNumber;
    final snapshot = await FirebaseFirestore.instance.collection('users')
    .doc(phone)
    .get();

    if (!snapshot.exists) {
      // error
      return null;
    }
    return snapshot.get('person_id');
  }

  Future<String> detectFace(String filePath) async {
    final url = 'https://pharma.cognitiveservices.azure.com/face/v1.0/detect?returnFaceId=true&returnFaceLandmarks=false&recognitionModel=recognition_03&returnRecognitionModel=false&detectionModel=detection_01';
    File file = File(filePath);
    var bytes = await file.readAsBytes();
    try {
      final response = await http.post(url, headers: {
        HttpHeaders.contentTypeHeader: 'application/octet-stream',
        'Ocp-Apim-Subscription-Key': '9f26b69aed9845d0ab795a5cb51913a2',
      }, body: bytes);
      print(response.statusCode);
      print(response.body);
      final js = json.decode(response.body);
      return js[0]['faceId'];
    } catch (e, stacktrace) {
      print(e);
      print(stacktrace);
      return null;
    }
  }

  Future<double> getMatch( String filePath ) async {
    var orig = await getPersonId();
    var curr = await detectFace(filePath);

    if (orig == null || curr == null) {
      return 0.0;
    }

    print(orig);
    print(curr);

    final url = 'https://pharma.cognitiveservices.azure.com/face/v1.0/verify';
    try {
      final response = await http.post(url, headers: {
        HttpHeaders.contentTypeHeader : "application/json",
        'Ocp-Apim-Subscription-Key': '9f26b69aed9845d0ab795a5cb51913a2',
      }, body: jsonEncode({ 'faceId' : curr, 'personGroupId' : 'users_group', 'personId' : orig }));
      print(response.body);
      final js = json.decode(response.body);
      return js["confidence"] ?? 0.0;
    } catch (e, stacktrace) {
      print(e);
      print(stacktrace);
      return 0.0;
    }

  }


  Text getDesc() {
    if (!widget.needsVerify) {
      return Text(
        'Order placed Succefully',
        style: TextStyle(color: Colors.black, fontSize: 15.0),
      );
    }
    switch (currentState) {
      case 0:
        return Text(
          'Needs Verification',
          style: TextStyle(color: Colors.red[900], fontSize: 15.0),
        );
      case 1:
        return Text(
          'Verification in progress',
          style: TextStyle(color: Colors.blue[900], fontSize: 15.0),
        );
      case 2:
        return Text(
          'Verification Failed. Please Retry',
          style: TextStyle(color: Colors.red[900], fontSize: 15.0),
        );
      default:
        return Text(
          'Verified Successfully with ' +
              (matchConfidence * 100).round().toString() +
              '% match',
          style: TextStyle(color: Colors.black, fontSize: 15.0),
        );
    }
  }
}
