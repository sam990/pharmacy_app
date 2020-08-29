import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:searchable_dropdown/searchable_dropdown.dart';


class PrescriptionAdd extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => PrescriptionAddState();
}

class PrescriptionAddState extends State<PrescriptionAdd> {

  var names = ['Vicodin', 'Synthroid', 'Delasone', 'Amoxil', 'Neurotin', 'Prinivil', 'Lipitor', 'Glucophage', 'Zofran', 'Motrin'];

  List<String> values = [null];
  var totalCount = 1;
  var currState = 0;

  var colors = [Colors.red, Colors.blue[700], Colors.green];
  var desc = ['Save', 'Save', 'Saving'];

  @override
  Widget build(BuildContext context) {
    var dropdownItems = names.map((e) => DropdownMenuItem( child: Text(e), value: e, )).toList();
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

    return Scaffold(
      appBar: AppBar(
        title: Text('Prescription Input'),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        children: children,
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

  void handleClick(BuildContext context) {
    if (currState == 2 || currState == 0) {
      return;
    }

    this.setState(() { currState = 2; });
    // go to dashboard here

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
}