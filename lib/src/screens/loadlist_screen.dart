import 'package:flutter/material.dart';
import '../widgets/loadlist_widget.dart';
import 'main_screen.dart';
import 'test_screen.dart';
import 'myaccount_screen.dart';


class LoadListScreen extends StatelessWidget {

 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text("My Loads"),
          backgroundColor: Color(0xFF003366),
        ),
        body:  LoadList(),
        backgroundColor: Color(0xFFB1BDCD),
        bottomNavigationBar: BottomNavigationBar(
            onTap: (i) {
              Navigator.pop(context);
              if(i == 0){
                Navigator.push(
                  context, MaterialPageRoute(builder: (context) => MainScreen()));
              }
              if(i == 1){
                Navigator.push(
                  context, MaterialPageRoute(builder: (context) => LoadListScreen()));
              }
              if(i == 2){
                Navigator.push(
                  context, MaterialPageRoute(builder: (context) => MyAccountScreen()));
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
        currentIndex: 1,
        selectedItemColor: Color(0xFF71C42B),
        unselectedItemColor: Color(0xFFE7EBF0),
      ),
      );
  }
}