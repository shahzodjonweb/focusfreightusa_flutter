import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'dart:convert';
import '../models/Load.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../screens/login_screen.dart';
import '../screens/loadinfo_screen.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:connectivity/connectivity.dart';

class LoadList extends StatefulWidget {
  @override
  LoadListState createState() => LoadListState();
}

class LoadListState extends State<LoadList> {
  int currentPage = 1;
  int lastPage = 7;
  List<Load> loads = [];

  ScrollController _scrollController = ScrollController();
  @override
  void initState() {
    super.initState();
    downloadData(currentPage, context);
    _scrollController.addListener(() {
      if (currentPage != lastPage) {
        if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent) {
          downloadData(currentPage, context);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 15.0, right: 15.0),
      child: ListView.builder(
        controller: _scrollController,
        primary: false,
        itemCount: loads.length,
        shrinkWrap: false,
        itemBuilder: (context, int index) {
          return listItem(
              loads[index].status,
              loads[index].shippers[0].city,
              loads[index].shippers[0].time,
              loads[index].shippers[1].city,
              loads[index].shippers[1].time,
              loads[index].id,
              context);
        },
      ),
    );
  }

  Widget listItem(var status, var pickup, var pickuptime, var delivery,
      var deliverytime, id, context) {
    if (status == 'canceled') {
      return Text('');
    }
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LoadInfoScreen('$id')),
        );
      },
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.all(7.0),
        color: Color(0xFFE7EBF0),
        child: Column(
          children: [
            checkStatus(status),
            Container(
              padding: EdgeInsets.all(10.0),
              width: double.infinity,
              child: Row(children: [
                Flexible(
                    flex: 1,
                    child: Container(
                      alignment: Alignment.centerLeft,
                      margin: EdgeInsets.only(left: 10.0),
                      width: double.infinity,
                      child: Icon(Icons.room, color: Colors.green),
                    )),
                Flexible(
                    flex: 5,
                    child: Container(
                        margin: EdgeInsets.only(left: 10.0),
                        width: double.infinity,
                        child: Text(
                          pickup,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16.0,
                          ),
                        ))),
                Flexible(
                    flex: 5,
                    child: Container(
                        alignment: Alignment.centerRight,
                        margin: EdgeInsets.only(right: 10.0),
                        width: double.infinity,
                        child: Text(pickuptime))),
              ]),
            ),
            Container(
              padding: EdgeInsets.only(left: 20.0, right: 20.0),
              child: Divider(),
            ),
            Container(
              padding: EdgeInsets.all(10.0),
              width: double.infinity,
              child: Row(children: [
                Flexible(
                    flex: 1,
                    child: Container(
                      alignment: Alignment.centerLeft,
                      margin: EdgeInsets.only(left: 10.0),
                      width: double.infinity,
                      child: Icon(Icons.room, color: Colors.red),
                    )),
                Flexible(
                    flex: 5,
                    child: Container(
                        margin: EdgeInsets.only(left: 10.0),
                        width: double.infinity,
                        child: Text(
                          delivery,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16.0,
                          ),
                        ))),
                Flexible(
                    flex: 5,
                    child: Container(
                        alignment: Alignment.centerRight,
                        margin: EdgeInsets.only(right: 10.0),
                        width: double.infinity,
                        child: Text(deliverytime))),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  // Sending and fetching HTTP Json data
  void downloadData(var page, context) async {
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
    var api_key = box.get('key');
    String token = api_key;
    final result = await post('http://sbuy.uz/api/load/loadlist',
        body: json.encode({'page': page}),
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
    if (json.decode(result.body)['error'] == 'Unauthenticated.') {
      Navigator.pop(context);
      await Navigator.push(
          context, MaterialPageRoute(builder: (context) => LoginScreen()));
    }

    var jsonloads = json.decode(result.body)['data'];
    for (var load in jsonloads) {
      Load eachload = Load.fromJsonForList(load);
      loads.add(eachload);
    }
    currentPage++;
    lastPage = json.decode(result.body)['total_pages'] + 1;

    setState(() {}); // return your response
  }

  Widget checkStatus(var status) {
    if (status == 'finished' || status == 'invoiced') {
      return Container(
        width: double.infinity,
        alignment: Alignment.centerRight,
        padding: EdgeInsets.fromLTRB(10, 5, 20, 5),
        color: Color(0xFF5B7290),
        child: Text('Finished',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16.0,
              color: Colors.white,
            )),
      );
    }
    if (status == 'active') {
      return Container(
        width: double.infinity,
        alignment: Alignment.centerRight,
        padding: EdgeInsets.fromLTRB(10, 5, 20, 5),
        color: Color(0xFF71C42B),
        child: Text('Active',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16.0,
              color: Colors.white,
            )),
      );
    }
    if (status == 'inactive') {
      return Container(
        width: double.infinity,
        alignment: Alignment.centerRight,
        padding: EdgeInsets.fromLTRB(10, 5, 20, 5),
        color: Color(0xFFfffb00),
        child: Text('New Load',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16.0,
              color: Colors.red,
            )),
      );
    }

    return Text('');
  }
}
