import 'package:flutter/material.dart';
import '../widgets/report_widget.dart';
import '../widgets/myaccount_widget.dart';
import 'main_screen.dart';
import 'loadlist_screen.dart';
import '../widgets/image_widget.dart';



class ImageScreen extends StatelessWidget {
      final id;
  ImageScreen(this.id);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text("My Account"),
          backgroundColor: Color(0xFF003366),
        ),
        body:SingleChildScrollView(child:  ImageUpload(this.id),),
        backgroundColor: Color(0xFFB1BDCD),
       
      );
  }
}