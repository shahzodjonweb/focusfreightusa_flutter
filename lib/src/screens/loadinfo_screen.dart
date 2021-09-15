import 'package:flutter/material.dart';
import '../widgets/loadinfo_widget.dart';

class LoadInfoScreen extends StatefulWidget {
  
    final id;
  LoadInfoScreen(this.id);

  @override
  _LoadInfoScreenState createState() => _LoadInfoScreenState();
}


class _LoadInfoScreenState extends State<LoadInfoScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text("Load Info"),
          backgroundColor: Color(0xFF003366),
        ),
        body: SingleChildScrollView(child:LoadInfo(widget.id) ,),
        backgroundColor: Color(0xFFB1BDCD),
       
      );
  }
}