import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';



class Clinic extends StatelessWidget {
  final String name;
  final String address;
  final String city;
  final String telephone;
  final String type;
  final String latitude;
  final String longitude;

  Clinic({
    this.name,
    this.address,
    this.city,
    this.telephone,
    this.type,
    this.latitude,
    this.longitude,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        color: Colors.green[200],
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(this.name, style: TextStyle(fontWeight: FontWeight.bold),),
            Text(this.city),
            Text(this.type),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(Icons.call),
                SizedBox(width : 5.0),
                Text(this.telephone),
              ],
            )
          ],
        ),
      ),
    );
  }
}
