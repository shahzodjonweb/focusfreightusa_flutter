import 'package:flutter/material.dart';
import '../widgets/report_widget.dart';
import '../widgets/myaccount_widget.dart';
import 'main_screen.dart';
import 'loadlist_screen.dart';

class ReportScreen extends StatelessWidget {
  final id;
  ReportScreen(this.id);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text("My Account"),
        backgroundColor: Color(0xFF1A4314),
      ),
      body: SingleChildScrollView(
        child: Report(this.id),
      ),
      backgroundColor: Colors.green[50],
    );
  }
}
