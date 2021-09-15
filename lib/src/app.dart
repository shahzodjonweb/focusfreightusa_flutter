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
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart' as bg;
import 'package:http/http.dart';
import 'dart:convert';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:connectivity/connectivity.dart';
import 'package:geolocator/geolocator.dart';


class App extends StatefulWidget {
  App({Key key}) : super(key: key);

  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  var isActive;
  var api_key;
  var loadid;
  
  void getstatus()async{
  
  }
  @override
void initState() {
    super.initState();

    ////
    // 1.  Listen to events (See docs for all 12 available events).
    //

    // Fired whenever a location is recorded
    bg.BackgroundGeolocation.onLocation((bg.Location location) {
     sendRequest(context,loadid);
     
    });

    // Fired whenever the plugin changes motion-state (stationary->moving and vice-versa)
    bg.BackgroundGeolocation.onMotionChange((bg.Location location) {
      // print('[motionchange] - $location');
    });

    // Fired whenever the state of location-services changes.  Always fired at boot
    bg.BackgroundGeolocation.onProviderChange((bg.ProviderChangeEvent event) {
      // print('[providerchange] - $event');
    });

    ////
    // 2.  Configure the plugin
    //
    bg.BackgroundGeolocation.ready(bg.Config(
        desiredAccuracy: bg.Config.DESIRED_ACCURACY_HIGH,
        distanceFilter: 10.0,
        stopOnTerminate: false,
        startOnBoot: true,
        stationaryRadius: 500,
        locationUpdateInterval: 60000,
        debug: true,
        logLevel: bg.Config.LOG_LEVEL_VERBOSE
    )).then((bg.State state)async{
      
          await Hive.initFlutter();
          
    var box = await Hive.openBox('UserInfo');
    api_key = box.get('key');
     isActive = box.get('isActive');
     loadid = box.get('idload');
     print(isActive);
     if(isActive){
       if (!state.enabled) {
     bg.BackgroundGeolocation.start();}
     }else{
       bg.BackgroundGeolocation.stop();
     }
      // getstatus();
        ///
        // 3.  Start the plugin.
        //
        
      
    });
  }

    void sendRequest(context,loadid) async {
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
           onPressed: ()  {
           Navigator.pop(context);
            setState(() {

            });
          },
          color: Color.fromRGBO(0, 179, 134, 1.0),
          radius: BorderRadius.circular(0.0),
        ),
      ],
    ).show();
        }
        }  
 var position = await _determinePosition();
  var token = api_key;
  final dateTime = DateTime.now();
   final result = await post('http://sbuy.uz/api/load/get_location', 
   body: json.encode({
     'loadid': loadid,
     'lat': '${position.latitude}',
     'lon': '${position.longitude}',
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
     print(result.body);
    if(json.decode(result.body)['error']=='Unauthenticated.'){
      Navigator.pop(context);
     await Navigator.push(context, MaterialPageRoute(builder: (context) => LoginScreen()));
   
    }
    
     
     }

  Widget build(context) {
    return MaterialApp(
      
      title: 'Flutter Demo',
      home: MainScreen(),
           
    );
  }


  // ---------------DON'T TOUCH THERE ------------------
  //     ///For location
     Future<Position> _determinePosition() async {
  bool serviceEnabled;
  LocationPermission permission;

  // Test if location services are enabled.
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    // Location services are not enabled don't continue
    // accessing the position and request users of the 
    // App to enable the location services.
    return Future.error('Location services are disabled.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately. 
      return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
    } 

    if (permission == LocationPermission.denied) {
      // Permissions are denied, next time you could try
      // requesting permissions again (this is also where
      // Android's shouldShowRequestPermissionRationale 
      // returned true. According to Android guidelines
      // your App should show an explanatory UI now.
      return Future.error(
          'Location permissions are denied');
    }
  }

  // When we reach here, permissions are granted and we can
  // continue accessing the position of the device.
  //return await Geolocator.getCurrentPosition();

  Position position = await Geolocator.getCurrentPosition(
    desiredAccuracy: LocationAccuracy.high,
    );
   
   return position;
}
}