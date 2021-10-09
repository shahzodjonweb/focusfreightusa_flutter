import 'package:flutter/material.dart';
import 'package:focusfreightusa/src/screens/report_screen.dart';
import 'package:focusfreightusa/src/widgets/mainpage_widget.dart';
import 'screens/loadlist_screen.dart';
import 'screens/loadinfo_screen.dart';
import 'screens/login_screen.dart';
import 'screens/main_screen.dart';
import 'screens/test_screen.dart';
import 'screens/myaccount_screen.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'screens/report_screen.dart';

import 'package:http/http.dart';
import 'dart:convert';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:connectivity/connectivity.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart';
import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';

class App extends StatefulWidget {
  App({Key key}) : super(key: key);

  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  var isActive;
  var api_key;
  var loadid;
  LocationData _currentPosition;
  Location location = Location();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  String _message = '';

  void getstatus() async {}
  @override
  void initState() {
    //_registerOnFirebase();
    getMessage();
    Timer timer = Timer.periodic(Duration(seconds: 60), (timer) {
      DateTime timenow = DateTime.now(); //get current date and time
      checkpermission();

      //mytimer.cancel() //to terminate this timer
    });
    // TODO: implement initState
    super.initState();
    getLoc();
  }

  void getMessage() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('received message');
      setState(() => _message = message.notification.body);
    });
  }

  void sendRequest(context, loadid, lat, lon) async {
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

    var token = api_key;

    final dateTime = DateTime.now();
    final result = await post(Uri.parse('http://sbuy.uz/api/load/get_location'),
        body: json.encode({
          'loadid': loadid,
          'lat': '${lat}',
          'lon': '${lon}',
          'time': '${dateTime.toLocal()}',
        }),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $api_key',
        });
    //         if(result.statusCode==404){
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
    print(json.decode(result.body)['error']);
    if (json.decode(result.body)['error'] == 'Unauthenticated.') {
      //  Navigator.pop(context);
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => LoginScreen()));
    }
  }

  Widget build(context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: MainScreen(),
    );
  }

  checkpermission() async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
  }

  getLoc() async {
    await Hive.initFlutter();

    var box = await Hive.openBox('UserInfo');
    api_key = box.get('key');
    isActive = box.get('isActive');
    loadid = box.get('idload');

    await checkpermission();
    location.changeSettings(interval: 15000, distanceFilter: 0);
    _currentPosition = await location.getLocation();
    location.enableBackgroundMode(enable: true);
    location.onLocationChanged.listen((LocationData currentLocation) {
      sendRequest(
          context, loadid, currentLocation.latitude, currentLocation.longitude);
      print('${currentLocation.latitude} : ${currentLocation.longitude}');
    });
  }
}
