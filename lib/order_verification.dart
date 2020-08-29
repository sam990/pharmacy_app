import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'dart:async';
import 'package:darwin_camera/darwin_camera.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';

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
    Timer(Duration(seconds: 2), () {
      this.setState(() {
        currentState = 3;
      });
    });
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
