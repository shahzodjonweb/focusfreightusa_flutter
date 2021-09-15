import 'package:flutter/material.dart';
import 'package:focusfreightusa/src/screens/loadlist_screen.dart';
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
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:connectivity/connectivity.dart';

class LoadInfo extends StatefulWidget {
  final id;
  LoadInfo(this.id);
   createState() {
    return LoadInfoState();
  }

}

class LoadInfoState extends State<LoadInfo> {
  var api_key;
   Load load;
 List<Shipper> shippers;
  //  final id;
  // LoadInfoState(this.id);

    Future<String> downloadData(context)async{
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
    await Hive.initFlutter();
    var box = await Hive.openBox('UserInfo');
     api_key = box.get('key');
    String token = api_key;
   final result = await post('http://sbuy.uz/api/load/get_load', 
   body: json.encode({'loadid': widget.id}),
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
    if(json.decode(result.body)['error']=='Unauthenticated.'){
      Navigator.pop(context);
     await Navigator.push(context, MaterialPageRoute(builder: (context) => LoginScreen()));
   
    }
   load = Load.fromJson(json.decode(result.body)['load']);
   shippers = load.shippers;
    return  Future.value(result.body); // return your response
  }
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: downloadData(context), // function where you call your api
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {  // AsyncSnapshot<Your object type>
        if( snapshot.connectionState == ConnectionState.waiting){
            return Center(child: CircularProgressIndicator());
        }else{
            if (snapshot.hasError)
              return Center(child: Text(''));
            else
              return    Center(child: new  Column(
      children: [
        confirmation(load.id,load.status,context),
        mainInfo(load.status),
       ListView.builder(
         primary: false,
      itemCount: shippers.length,
      shrinkWrap: true ,
      itemBuilder: (context,int index){
        return shipperInfo(shippers[index].time,shippers[index].location,shippers[index].checkin,shippers[index].checkout,(shippers.length-1),index,context,shippers[index].order,load.id);
      },
      
      ),
      ],
    ),
    );  // snapshot.data  :- get your object which is pass from your downloadData() function
        }
      },
    );
   
  }
Widget confirmation(id,status,context){
   if(status == 'inactive'){
     return Container(
       color: Color(0xFF5B7290),
       margin: EdgeInsets.fromLTRB(15.0,15.0,15.0,0),
       padding: EdgeInsets.all(10.0),
       width: double.infinity,
       child: Row(
         
         children: [
           Flexible(
             flex:1,
             child: Container(
               padding: EdgeInsets.only(right:20.0,left:20.0),
             width: double.infinity,
           child: ElevatedButton(
             
              style: ElevatedButton.styleFrom(
                                            primary: Colors.green, // background
                                            onPrimary: Colors.white, // foreground
                                          ),
             child: Text('Confirm'),
             onPressed: ()async{
               sendRequest(context,id,'active');
               await Hive.initFlutter();
              var box = await Hive.openBox('UserInfo');
               box.put('isActive', true);
               box.put('idload', widget.id);
             },
           )
           )),
           Flexible(
             flex:1,
             child: Container(
               padding: EdgeInsets.only(right:20.0,left:20.0),
             width: double.infinity,
           child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                                            primary: Colors.red, // background
                                            onPrimary: Colors.white, // foreground
                                          ),
             child: Text('Reject',
             ),
             onPressed: (){
               sendRequest(context,id,'canceled');
             },
           )
           ))
         ],
       )
     );
   }else{
     return Text('');
   }
}
       String showStatus(stat){
      switch (stat) {
        case 'finished': return 'Finished';
          break;
          case 'invoiced': return 'Finished';
          break;
                  case 'active': return 'Active';
          break;
                  case 'inactive': return 'New Load';
          break;
        default: return '';
      }
    }
  Widget mainInfo(status){
  var statusof=showStatus(status);
    return Container(
      width: double.infinity,
      margin: EdgeInsets.fromLTRB(15.0,0,15.0,15.0),
      color: Color(0xFFE7EBF0),
      child:
        Row(
          children: [
               Flexible(
        flex: 3,
        child: Container(
          padding: EdgeInsets.fromLTRB(10.0, 20.0, 10.0, 20.0),
          width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Price: \$${load.price}',
                style: TextStyle(fontWeight: FontWeight.bold,
                fontSize: 18.0,  ),),
                Container(margin: EdgeInsets.only(top: 10.0)),
                Text('Milage: ${load.milage}',
                style: TextStyle(color: Color(0xFF71C42B),
                fontSize: 16.0,  ),),
              ],
            )
          )
        
      ),
     
      Flexible(
          flex: 3,
          child: Container(
          padding: EdgeInsets.fromLTRB(10.0, 20.0, 10.0, 20.0),
          width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Status: $statusof',
                  style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18.0,  
                                  ),
                    ),
                Container(
                  margin: EdgeInsets.only(top: 10.0)
                          ),
                Text('Deadhead: ${load.deadhead}',
                style: TextStyle(
                color: Color(0xFF71C42B),
                fontSize: 16.0,  ),),
              ],
            )
          )
      ),
          ]
        )
     
    );
  }
   Widget shipperInfo(var time, Location location, var checkin,var checkout,var last,var index,context,shipper,loadid){
   return Container(
      width: double.infinity,
      margin: EdgeInsets.all(15.0),
      color: Color(0xFFE7EBF0),
      child:Column(children: [
                  Row(
                    children: [
                      Flexible(
                      flex: 3,
                      child: Container(
                      padding: EdgeInsets.fromLTRB(10.0, 20.0, 10.0, 10.0),
                      width: double.infinity,
                     
                        child: shippercheck(index, last),
                      )
                    
                      ),
                      Flexible(
                      flex: 3,
                      child: Container(
                      padding: EdgeInsets.fromLTRB(10.0, 20.0, 10.0, 10.0),
                      width: double.infinity,
                        child: Text(time,
                                  style: TextStyle(
                                    color: Color(0xFF71C42B),
                                    fontSize: 16.0, 
                                                 ),
                                    ),
                        
                      )
                    
                      ),
     
                    ],
                  ),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.fromLTRB(10.0,0, 10.0,10.0),
                    child: Text('${location.city} ${location.county} , ${location.state} ${location.zipcode}',
                                  style: TextStyle(
                                    fontSize: 17.0, 
                                                 ),
                                    ),
                  ),
                  Container(
                    padding: EdgeInsets.fromLTRB(10.0,20.0, 10.0,20.0),
                    color: Colors.white,
                    child: Column(
                      children: [
                        Container(
                          child:checkincheck(checkin,context,shipper,loadid),
                          
                        ),
                       Container(
                          child:checkoutcheck(checkout,context,shipper,loadid),
                        ),

                        
                      ],
                    ),
                  )
      ],)
     
     
    );
  }
  
  Widget checkincheck(var check,context,shipper,loadid){
    if(check==null){
      return Row(
                            children: [
                              Flexible(
                                flex: 3,
                                child:
                               Container(
                                        width: double.infinity,
                                        child: Text('Checkin:'),
                                      ),),
                                Flexible(
                                flex: 5,
                                child:  
                                  Container(
                                          margin: EdgeInsets.only(left: 10.0),
                                          width: double.infinity,
                                          child:Text('Not checked in',
                        style: TextStyle(
                        fontSize: 17.0, 
                        ),
                        ),
                                          
                                      ),
               
                                )
                            ],
                          );
    }else{
      return  Row(
                            children: [
                              Flexible(
                                flex: 3,
                                child:
                               Container(
                                        width: double.infinity,
                                        child: Text('Checkin:'),
                                      ),),
                                Flexible(
                                flex: 5,
                                child:  
                                  Container(
                                          margin: EdgeInsets.only(left: 10.0),
                                          width: double.infinity,
                                          child:Text(check,
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
    Widget checkoutcheck(var check,context,shipper,loadid){
    if(check==null){
       return Row(
                            children: [
                              Flexible(
                                flex: 3,
                                child:
                               Container(
                                        width: double.infinity,
                                        child: Text('Checkout:'),
                                      ),),
                                Flexible(
                                flex: 5,
                                child:  
                                  Container(
                                          margin: EdgeInsets.only(left: 10.0),
                                          width: double.infinity,
                                          child:Text('Not checked out',
                        style: TextStyle(
                        fontSize: 17.0, 
                        ),
                        ),
                                          
                                      ),
               
                                )
                            ],
                          );
    }else{
       return Row(
                            children: [
                              Flexible(
                                flex: 3,
                                child:
                               Container(
                                        width: double.infinity,
                                        child: Text('Checkout:'),
                                      ),),
                                Flexible(
                                flex: 5,
                                child:  
                                  Container(
                                          margin: EdgeInsets.only(left: 10.0),
                                          width: double.infinity,
                                          child:Text(check,
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

  Widget shippercheck(var index, var last){
   
     if(index == 0){
       return Text('Pickup',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18.0,  
                                                ),
                                          );
     }
     if(index == last){
       return Text('Delivery',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18.0,  
                                                ),
                                          );
     }
     return Text('Stop ${index}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18.0,  
                                                ),
                                          );
  }
  

  void sendRequest(context,loadid,status) async {

  var token = api_key;
   final result = await post('http://sbuy.uz/api/load/change_status', 
   body: json.encode({
     'loadid': loadid,
     'status': status
     }),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });    
    if(json.decode(result.body)['error']=='Unauthenticated.'){
      Navigator.pop(context);
     await Navigator.push(context, MaterialPageRoute(builder: (context) => LoginScreen()));
   
    }
    if(json.decode(result.body)!= null){
      if(status=="active"){
         Navigator.push(context, MaterialPageRoute(builder: (context) => MainScreen()));
      }else{
        Navigator.push(context, MaterialPageRoute(builder: (context) => LoadListScreen()));
      }
      
    }
    
     
     }


     ///For location
   
}