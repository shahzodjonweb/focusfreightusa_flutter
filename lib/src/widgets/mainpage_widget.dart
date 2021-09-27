import 'package:flutter/material.dart';
import 'package:focusfreightusa/src/screens/login_screen.dart';
import 'package:http/http.dart';
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import '../models/Load.dart';
import '../models/Shipper.dart';
import '../models/Location.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../screens/login_screen.dart';
import '../screens/main_screen.dart';
import '../screens/myaccount_screen.dart';
import '../screens/report_screen.dart';
import '../screens/image_screen.dart';
import '../screens/loadlist_screen.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:connectivity/connectivity.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  bool _hasActive = true;
  var api_key;
  Load load;
  var idOfLoad;
  List<Shipper> shippers;
  bool isNext = true;

  Widget setScreen(context) {
    if (_hasActive) {
      return Center(
        child: new Column(
          children: [
            mainInfo(load.status),
            ListView.builder(
              primary: false,
              itemCount: shippers.length,
              shrinkWrap: true,
              itemBuilder: (context, int index) {
                return shipperInfo(
                    shippers[index].time,
                    shippers[index].city,
                    shippers[index].street,
                    shippers[index].checkin,
                    shippers[index].checkout,
                    (shippers.length - 1),
                    index,
                    context,
                    shippers[index].order,
                    load.id);
              },
            ),
          ],
        ),
      );
    } else {
      return Center(
          child: Container(
        margin: EdgeInsets.fromLTRB(
            20.0, MediaQuery.of(context).size.height * 0.40, 20.0, 20.0),
        child: Text(
          'No active loads available!',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20.0,
            color: Color(0xFF003366),
          ),
        ),
      ));
    }
  }

  Widget reports() {
    if (idOfLoad == 0) {
      return Text('');
    }
    return Padding(
        padding: EdgeInsets.only(right: 20.0),
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ReportScreen('$idOfLoad')),
            );
          },
          child: Icon(
            Icons.error,
            size: 26.0,
          ),
        ));
  }

  Widget bols() {
    if (idOfLoad == 0) {
      return Text('');
    }
    return Padding(
        padding: EdgeInsets.only(right: 20.0),
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ImageScreen('$idOfLoad')),
            );
          },
          child: Icon(
            Icons.image,
            size: 26.0,
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text("Active Load"),
        backgroundColor: Color(0xFF003366),
        actions: [
          bols(),
          reports(),
        ],
      ),
      body: SingleChildScrollView(
          child:

              // mainPage SCREEN
              FutureBuilder<String>(
        future: downloadData(context), // function where you call your api
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          // AsyncSnapshot<Your object type>
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else {
            if (snapshot.hasError)
              return Center(child: Text(''));
            else
              return setScreen(
                  context); // snapshot.data  :- get your object which is pass from your downloadData() function
          }
        },
      )),
      backgroundColor: Color(0xFFB1BDCD),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (i) {
          Navigator.pop(context);
          if (i == 0) {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => MainScreen()));
          }
          if (i == 1) {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => LoadListScreen()));
          }
          if (i == 2) {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => MyAccountScreen()));
          }
        },
        backgroundColor: Color(0xFF5B7290),
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Avctive load',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'My loads',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'My Account',
          ),
        ],
        currentIndex: 0,
        selectedItemColor: Color(0xFF71C42B),
        unselectedItemColor: Color(0xFFE7EBF0),
      ),
    );
  }

  String showStatus(stat) {
    switch (stat) {
      case 'finished':
        return 'Finished';
        break;
      case 'invoiced':
        return 'Finished';
        break;
      case 'active':
        return 'Active';
        break;
      case 'inactive':
        return 'New Load';
        break;
      default:
        return '';
    }
  }

  Widget mainInfo(status) {
    var statusof = showStatus(status);
    return Container(
        width: double.infinity,
        margin: EdgeInsets.all(15.0),
        color: Color(0xFFE7EBF0),
        child: Row(children: [
          Flexible(
              flex: 3,
              child: Container(
                  padding: EdgeInsets.fromLTRB(10.0, 20.0, 10.0, 20.0),
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Price: \$${load.price}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18.0,
                        ),
                      ),
                      Container(margin: EdgeInsets.only(top: 10.0)),
                      Text(
                        'Milage: ${load.milage}',
                        style: TextStyle(
                          color: Color(0xFF71C42B),
                          fontSize: 16.0,
                        ),
                      ),
                    ],
                  ))),
          Flexible(
              flex: 3,
              child: Container(
                  padding: EdgeInsets.fromLTRB(10.0, 20.0, 10.0, 20.0),
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Status: $statusof',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18.0,
                        ),
                      ),
                      Container(margin: EdgeInsets.only(top: 10.0)),
                      Text(
                        'Deadhead: ${load.deadhead}',
                        style: TextStyle(
                          color: Color(0xFF71C42B),
                          fontSize: 16.0,
                        ),
                      ),
                    ],
                  ))),
        ]));
  }

  Widget shipperInfo(var time, var city, var street, var checkin, var checkout,
      var last, var index, context, shipper, loadid) {
    return Container(
        width: double.infinity,
        margin: EdgeInsets.all(15.0),
        color: Color(0xFFE7EBF0),
        child: Column(
          children: [
            Row(
              children: [
                Flexible(
                    flex: 3,
                    child: Container(
                      padding: EdgeInsets.fromLTRB(10.0, 20.0, 10.0, 10.0),
                      width: double.infinity,
                      child: shippercheck(index, last),
                    )),
                Flexible(
                    flex: 3,
                    child: Container(
                      padding: EdgeInsets.fromLTRB(10.0, 20.0, 10.0, 10.0),
                      width: double.infinity,
                      child: Text(
                        time,
                        style: TextStyle(
                          color: Color(0xFF71C42B),
                          fontSize: 16.0,
                        ),
                      ),
                    )),
              ],
            ),
            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(10.0, 0, 10.0, 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    street,
                    style: TextStyle(
                      fontSize: 17.0,
                    ),
                  ),
                  Text(
                    city,
                    style: TextStyle(
                      fontSize: 15.0,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(10.0, 20.0, 10.0, 20.0),
              color: Colors.white,
              child: Column(
                children: [
                  Container(
                    child: checkincheck(checkin, context, shipper, loadid),
                  ),
                  Container(
                    child: checkoutcheck(checkout, context, shipper, loadid),
                  ),
                ],
              ),
            )
          ],
        ));
  }

  // Sending and fetching HTTP Json data
  Future<String> downloadData(context) async {
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
    await Hive.initFlutter();
    var box = await Hive.openBox('UserInfo');
    api_key = box.get('key');
    String token = api_key;
    final result = await get(Uri.parse('http://sbuy.uz/api/load/get_active'),
        // body: json.encode({'loadid': 488}),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        });
    //          if(result.statusCode==404){
    //     Alert(
    //   context: context,
    //   type: AlertType.warning,
    //   title: "Something went wrong!",
    //    style: AlertStyle(
    //      isOverlayTapDismiss: false,
    //     isCloseButton: false,
    //   )
    // ).show();
    //}
    if (json.decode(result.body)['error'] == 'Unauthenticated.') {
      Navigator.pop(context);
      await Navigator.push(
          context, MaterialPageRoute(builder: (context) => LoginScreen()));
    }
    if (json.decode(result.body)['error'] == 'Load not found') {
      _hasActive = false;
      box.put('isActive', false);
      return Future.value(result.body);
    }
    load = Load.fromJson(json.decode(result.body)['load']);
    shippers = load.shippers;
    idOfLoad = load.id;
    if (idOfLoad == 0) {
      setState(() {});
    }

    box.put('isActive', load.id);
    box.put('idload', load.id);
    return Future.value(result.body); // return your response
  }

  Widget checkincheck(var check, context, shipper, loadid) {
    if (check == null) {
      return Row(
        children: [
          Flexible(
            flex: 3,
            child: Container(
              width: double.infinity,
              child: isCheckedCheckin(context, shipper, loadid),
            ),
          ),
          Flexible(
            flex: 5,
            child: Container(
              margin: EdgeInsets.only(left: 10.0),
              width: double.infinity,
              child: Text(
                'Click to check in',
                style: TextStyle(
                  fontSize: 17.0,
                ),
              ),
            ),
          )
        ],
      );
    } else {
      return Row(
        children: [
          Flexible(
            flex: 3,
            child: Container(
                width: double.infinity,
                child: ElevatedButton(
                  child: Text('Checked in'),
                  onPressed: null,
                )),
          ),
          Flexible(
            flex: 5,
            child: Container(
              margin: EdgeInsets.only(left: 10.0),
              width: double.infinity,
              child: Text(
                check,
                style: TextStyle(
                  fontSize: 17.0,
                ),
              ),
            ),
          )
        ],
      );
    }
  }

  Widget checkoutcheck(var check, context, shipper, loadid) {
    if (check == null) {
      return Row(
        children: [
          Flexible(
            flex: 3,
            child: Container(
              width: double.infinity,
              child: isCheckedCheckout(context, shipper, loadid),
            ),
          ),
          Flexible(
            flex: 5,
            child: Container(
              margin: EdgeInsets.only(left: 10.0),
              width: double.infinity,
              child: Text(
                'Click to check out',
                style: TextStyle(
                  fontSize: 17.0,
                ),
              ),
            ),
          )
        ],
      );
    } else {
      return Row(
        children: [
          Flexible(
            flex: 3,
            child: Container(
                width: double.infinity,
                child: ElevatedButton(
                  child: Text('Checked out'),
                  onPressed: null,
                )),
          ),
          Flexible(
            flex: 5,
            child: Container(
              margin: EdgeInsets.only(left: 10.0),
              width: double.infinity,
              child: Text(
                check,
                style: TextStyle(
                  fontSize: 17.0,
                ),
              ),
            ),
          )
        ],
      );
    }
  }

  Widget shippercheck(var index, var last) {
    if (index == 0) {
      return Text(
        'Pickup',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18.0,
        ),
      );
    }
    if (index == last) {
      return Text(
        'Delivery',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18.0,
        ),
      );
    }
    return Text(
      'Stop ${index}',
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 18.0,
      ),
    );
  }

  Widget isCheckedCheckin(context, shipper, loadid) {
    if (isNext) {
      isNext = false;
      return ElevatedButton(
        style: ElevatedButton.styleFrom(
          primary: Colors.green, // background
          onPrimary: Colors.white, // foreground
        ),
        child: Text('Checkin'),
        onPressed: () {
          showModalBottomSheet<void>(
            context: context,
            builder: (BuildContext context) {
              return showModal(context, shipper, 'in', loadid);
              ;
            },
          );
        },
      );
    }
    return ElevatedButton(
      child: Text('Checkin'),
      onPressed: () {},
    );
  }

  Widget isCheckedCheckout(context, shipper, loadid) {
    if (isNext) {
      isNext = false;
      return ElevatedButton(
        style: ElevatedButton.styleFrom(
          primary: Colors.green, // background
          onPrimary: Colors.white, // foreground
        ),
        child: Text('Checkout'),
        onPressed: () {
          showModalBottomSheet<void>(
            context: context,
            builder: (BuildContext context) {
              return showModal(context, shipper, 'out', loadid);
              ;
            },
          );
        },
      );
    }
    return ElevatedButton(
      child: Text('Checkout'),
      onPressed: () {},
    );
  }

  Widget showModal(context, shipper, type, loadid) {
    return Container(
      height: 125,
      color: Color(0xFFB1BDCD),
      child: Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: EdgeInsets.only(bottom: 10.0),
                child: Text(
                  'Do you want to checkin?',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18.0,
                    color: Color(0xFF003366),
                  ),
                ),
              ),
              Row(
                children: [
                  Flexible(
                      flex: 1,
                      child: Container(
                        margin: EdgeInsets.only(left: 25.0, right: 25.0),
                        width: double.infinity,
                        child: ElevatedButton(
                            child: Text("Yes"),
                            style: ElevatedButton.styleFrom(
                              primary: Color(0xFF71C42B), // background
                              onPrimary: Colors.white, // foreground
                            ),
                            onPressed: () {
                              sendRequest(context, shipper, type, loadid);
                            }),
                      )),
                  Flexible(
                      flex: 1,
                      child: Container(
                        margin: EdgeInsets.only(left: 25.0, right: 25.0),
                        width: double.infinity,
                        child: ElevatedButton(
                            child: Text("No"),
                            style: ElevatedButton.styleFrom(
                              primary: Color(0xFF003366), // background
                              onPrimary: Colors.white, // foreground
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                            }),
                      )),
                ],
              ),
            ]),
      ),
    );
  }

  void sendRequest(context, shipper, type, loadid) async {
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
    var position = await _determinePosition();
    var token = api_key;
    final dateTime = DateTime.now();
    final result = await post(Uri.parse('http://sbuy.uz/api/load/get_location'),
        body: json.encode({
          'loadid': loadid,
          'stop': shipper,
          'type': type,
          'lat': '${position.latitude}',
          'lon': '${position.longitude}',
          'time': '${dateTime.toLocal()}',
        }),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
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
    if (json.decode(result.body)['error'] == 'Unauthenticated.') {
      Navigator.pop(context);
      await Navigator.push(
          context, MaterialPageRoute(builder: (context) => LoginScreen()));
    }
    if (json.decode(result.body) != null) {
      if (shippers.last.order == shipper && shippers.last.checkin != null) {
        sendRequestStatus(context, loadid, 'finished');
        await Hive.initFlutter();
        var box = await Hive.openBox('UserInfo');
        box.put('isActive', false);
      } else {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => MainScreen()));
      }
    }
  }

  void sendRequestStatus(context, loadid, status) async {
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
    final result = await post(
        Uri.parse('http://sbuy.uz/api/load/change_status'),
        body: json.encode({'loadid': loadid, 'status': status}),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
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
    if (json.decode(result.body)['error'] == 'Unauthenticated.') {
      Navigator.pop(context);
      await Navigator.push(
          context, MaterialPageRoute(builder: (context) => LoginScreen()));
    }
    if (json.decode(result.body) != null) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => LoadListScreen()));
    }
  }

  ///For location
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
        return Future.error('Location permissions are denied');
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
