import 'package:flutter/material.dart';
import 'package:focusfreightusa/src/screens/login_screen.dart';
import 'package:http/http.dart';
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import '../models/Driver.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../screens/login_screen.dart';
import '../screens/myaccount_screen.dart';

class MyAccount extends StatefulWidget {

  @override
  _MyAccountState createState() => _MyAccountState();
}

class _MyAccountState extends State<MyAccount> {
  Driver user;
  var key;
  var email;
  var name;
  var phone;
  var address;
  @override 
  void initState(){
    super.initState();

    /// content
  }
  Future<String> getInfo() async {
      await Hive.initFlutter();
    var box = await Hive.openBox('UserInfo');
    key = box.get('key');
    email = box.get('email');
    name = box.get('name');
    phone = box.get('phone');
    address = box.get('address');
    return key;
  }
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: getInfo(), // function where you call your api
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {  // AsyncSnapshot<Your object type>
        if( snapshot.connectionState == ConnectionState.waiting){
            return Center(child: CircularProgressIndicator());
        }else{
            if (snapshot.hasError)
              return Center(child: Text('Error: ${snapshot.error}'));
            else
              return Center(child: new  Container(
           
           color: Color(0xFFE7EBF0),
           margin:EdgeInsets.fromLTRB(20.0, MediaQuery.of(context).size.height*0.15, 20.0, 20.0),
           child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
             children: [
               showTitle(),
             showAccountData(Icon(Icons.face, color: Color(0xFF5B7290),),"Name", name),
             Divider(),
             showAccountData(Icon(Icons.email, color: Color(0xFF5B7290),),"Email", email),
             Divider(),
             showAccountData(Icon(Icons.phone,  color: Color(0xFF5B7290),),"Phone", phone),
             Divider(),
             showAccountData(Icon(Icons.person_pin_circle,  color: Color(0xFF5B7290),),"Address", address),
           ],),
         
       
    ),

    );  // snapshot.data  :- get your object which is pass from your downloadData() function
        }
      },
    );
    
    
    
    
    
  }
  Widget showTitle(){
     return Container(
       padding:EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
       color:Color(0xFF5B7290),
             //  padding:EdgeInsets.only(top:10.0,bottom:10.0),
               child:Row(
                 children: [
                   Flexible(
                     flex:3,
                     child: Container(
                       width: double.infinity,
                       child:Icon(Icons.switch_account,  color: Colors.white,size:25.0),
                     ),
                   ),
                   Flexible(
                     flex:5,
                     child: Container(
                       width: double.infinity,
                       child: Text("My Account",   style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20.0, 
                          color: Colors.white, 
                                  ),),
                     ),
                     
                   ),
                 ],
               )
             );
  }

  Widget showAccountData(Widget icon,var title, var name){
    return Container(
               padding:EdgeInsets.only(top:10.0,bottom:10.0),
               child:Row(
                 children: [
                   Flexible(
                     flex:1,
                     child: Container(
                       width: double.infinity,
                       child:icon,
                     ),
                   ),
                   Flexible(
                     flex:2,
                     child: Container(
                       width: double.infinity,
                       child: Text(title,   style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0,  
                          color: Color(0xFF5B7290),
                                  ),),
                     ),
                     
                   ),
                   Flexible(
                     flex:5,
                     child: Container(
                       width: double.infinity,
                        child: Text(name,
                         style: TextStyle(
                          fontSize: 15.0, 
                          color:Color(0xFF003366), 
                                  ),),
                     ),
                    
                   ),
                 ],
               )
             );
  }
}

