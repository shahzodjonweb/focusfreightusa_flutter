import 'package:flutter/material.dart';
import 'package:focusfreightusa/src/screens/login_screen.dart';
import 'package:http/http.dart';
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import '../models/Driver.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../screens/login_screen.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import '../screens/main_screen.dart';
import '../screens/loadlist_screen.dart';
import 'package:connectivity/connectivity.dart';

class Report extends StatefulWidget {
  final id;
  Report(this.id);
  @override
  _ReportState createState() => _ReportState();
}

class _ReportState extends State<Report> {
  final formKey = GlobalKey<FormState>();
  Driver user;
  var pressedNumber = 0;
  var pressed = false;
  var key;
  var message;
  Color _colorContainer1 = Color(0xFFE7EBF0);
  Color _colorContainer2 = Color(0xFFE7EBF0);
  Color _colorContainer3 = Color(0xFFE7EBF0);
  Color _colorContainer4 = Color(0xFFE7EBF0);
  @override
  void initState() {
    super.initState();

    /// content
  }

  Future<String> getInfo() async {
    await Hive.initFlutter();
    var box = await Hive.openBox('UserInfo');
    key = box.get('key');
    return key;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
        key: formKey,
        child: Container(
          color: Color(0xFFE7EBF0),
          margin: EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              showTitle(),
              showReportData('Engine not starting.', _colorContainer1, 1),
              showReportData('Tires are cracked!', _colorContainer2, 2),
              showReportData('Shipper not Responding!', _colorContainer3, 3),
              showReportData('I am so tired!', _colorContainer4, 4),
              showReportData2('Another reason(describe below):'),
              showButton()
            ],
          ),
        ));
  }

  Widget showTitle() {
    return Container(
      padding: EdgeInsets.fromLTRB(0, 10.0, 0, 10.0),
      color: Color(0xFF5B7290),
      //  padding:EdgeInsets.only(top:10.0,bottom:10.0),
      child: Row(
        children: [
          Flexible(
            flex: 1,
            child: Container(
              width: double.infinity,
              child: Icon(Icons.announcement, color: Colors.white, size: 25.0),
            ),
          ),
          Flexible(
            flex: 7,
            child: Container(
              width: double.infinity,
              child: Text(
                "Select The Report Type",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget showReportData(var name, Color color, int number) {
    return new Material(
      color: color,
      child: new InkWell(
          onTap: () {
            // player.play('sound1.mp3');
            _colorContainer1 = Color(0xFFE7EBF0);
            _colorContainer2 = Color(0xFFE7EBF0);
            _colorContainer3 = Color(0xFFE7EBF0);
            _colorContainer4 = Color(0xFFE7EBF0);
            switch (number) {
              case 1:
                _colorContainer1 = Color(0xFFcfd3d8);
                message = name;
                pressed = true;
                if (pressedNumber == number) {
                  _colorContainer1 = Color(0xFFE7EBF0);
                  pressedNumber = 0;
                  pressed = false;
                } else {
                  pressedNumber = number;
                }
                break;

              case 2:
                _colorContainer2 = Color(0xFFcfd3d8);
                message = name;
                pressed = true;
                if (pressedNumber == number) {
                  _colorContainer2 = Color(0xFFE7EBF0);
                  pressedNumber = 0;
                  pressed = false;
                } else {
                  pressedNumber = number;
                }
                break;

              case 3:
                _colorContainer3 = Color(0xFFcfd3d8);
                message = name;
                pressed = true;
                if (pressedNumber == number) {
                  _colorContainer3 = Color(0xFFE7EBF0);
                  pressedNumber = 0;
                  pressed = false;
                } else {
                  pressedNumber = number;
                }
                break;

              case 4:
                _colorContainer4 = Color(0xFFcfd3d8);
                message = name;
                pressed = true;
                if (pressedNumber == number) {
                  _colorContainer4 = Color(0xFFE7EBF0);
                  pressedNumber = 0;
                  pressed = false;
                } else {
                  pressedNumber = number;
                }
                break;
              default:
            }
            setState(() {});
          },
          child: Container(
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey)),
              ),
              padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
              child: Row(
                children: [
                  Flexible(
                    flex: 1,
                    child: Container(
                      width: double.infinity,
                      child: Icon(Icons.error, color: Color(0xFF003366)),
                    ),
                  ),
                  Flexible(
                    flex: 7,
                    child: Container(
                      width: double.infinity,
                      child: Text(
                        name,
                        style: TextStyle(
                          fontSize: 15.0,
                          color: Color(0xFF003366),
                        ),
                      ),
                    ),
                  ),
                ],
              ))),
    );
  }

  Widget showReportData2(var name) {
    if (!pressed) {
      return Column(
        children: [
          Container(
              padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
              child: Row(
                children: [
                  Flexible(
                    flex: 1,
                    child: Container(
                      width: double.infinity,
                      child: Icon(Icons.add_alert, color: Color(0xFF003366)),
                    ),
                  ),
                  Flexible(
                    flex: 7,
                    child: Container(
                      width: double.infinity,
                      child: Text(
                        name,
                        style: TextStyle(
                          fontSize: 15.0,
                          color: Color(0xFF003366),
                        ),
                      ),
                    ),
                  ),
                ],
              )),
          Container(
              padding: EdgeInsets.only(right: 15.0, left: 15.0, bottom: 10.0),
              child: TextFormField(
                onSaved: (String value) {
                  message = value;
                },
                style: TextStyle(color: Color(0xFF003366)),
                decoration:
                    InputDecoration(fillColor: Colors.white, filled: true),
                minLines:
                    6, // any number you need (It works as the rows for the textarea)
                keyboardType: TextInputType.multiline,
                maxLines: null,
              )),
        ],
      );
    }
    return Text('');
  }

  Widget showButton() {
    return Container(
        margin: EdgeInsets.only(bottom: 20.0),
        child: Center(
            child: ElevatedButton(
                onPressed: () {
                  if (!pressed) {
                    if (formKey.currentState.validate()) {
                      formKey.currentState.save();
                      sendRequestStatus(widget.id);
                    }
                  }

                  sendRequestStatus(widget.id);
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.green, // background
                  onPrimary: Colors.white, // foreground
                ),
                child: Text('Send Report'))));
  }

  void sendRequestStatus(loadid) async {
    await getInfo();

    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult != ConnectivityResult.mobile) {
      if (connectivityResult != ConnectivityResult.wifi) {
        print('notconnected');
        Alert(
          context: context,
          type: AlertType.error,
          title: "Network unavailable!",
          style: AlertStyle(
            isOverlayTapDismiss: false,
            isCloseButton: false,
          ),
          buttons: [
            DialogButton(
              child: Text(
                "Try Again",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
              onPressed: () {
                Navigator.pop(context);
                setState(() {});
              },
              color: Color.fromRGBO(0, 179, 134, 1.0),
              radius: BorderRadius.circular(0.0),
            ),
          ],
        ).show();
      }
    }

    var token = key;
    final result = await post(Uri.parse('http://sbuy.uz/api/load/send_report'),
        body: json.encode({'loadid': loadid, 'message': message}),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        });
    //     if(result.statusCode==404){
    //     Alert(
    //   context: context,
    //   type: AlertType.warning,
    //   title: "Something went wrong!",
    //    style: AlertStyle(
    //      isOverlayTapDismiss: false,
    //     isCloseButton: false,
    //   )
    // ).show();
    // }

    ////
    if (json.decode(result.body)['error'] == 'Unauthenticated.') {
      Navigator.pop(context);
      await Navigator.push(
          context, MaterialPageRoute(builder: (context) => LoginScreen()));
    }

    if (json.decode(result.body)['success'] == 1) {
      Alert(
        context: context,
        type: AlertType.success,
        title: "Successfully Sent!",
        style: AlertStyle(
          isOverlayTapDismiss: false,
          isCloseButton: false,
        ),
        buttons: [
          DialogButton(
            child: Text(
              "OK",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            onPressed: () => Navigator.pop(context),
            color: Color.fromRGBO(0, 179, 134, 1.0),
            radius: BorderRadius.circular(0.0),
          ),
        ],
      ).show();

      Future.delayed(Duration(milliseconds: 1000), () {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => MainScreen()));
      });
    }
  }
}
