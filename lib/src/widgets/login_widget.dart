import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart';
import 'dart:convert';
import '../models/Driver.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../screens/main_screen.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:connectivity/connectivity.dart';

class LoginScreen2 extends StatefulWidget {
  createState() {
    return LoginScreen2State();
  }
}

class LoginScreen2State extends State<LoginScreen2> {
  Driver user;
  var message;
  final formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';

  Widget build(context) {
    return Container(
      margin: EdgeInsets.all(20.0),
      child: Form(
        key: formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            emailField(),
            passwordField(),
            Container(margin: EdgeInsets.only(top: 25.0)),
            submitButton(),
            bottomText(),
          ],
        ),
      ),
    );
  }

  void downloadData(var email, var password) async {
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
    //String token = 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwOlwvXC9zYnV5LnV6XC9hcGlcL2F1dGhcL2xvZ2luIiwiaWF0IjoxNjE1NTgxNjc5LCJuYmYiOjE2MTU1ODE2NzksImp0aSI6IjNFUWhHS1JsZEtzZXVSTDYiLCJzdWIiOjEwLCJwcnYiOiIzMDViYjc1MmEzZDUwYTUwNjY2ZjI5NzhkMjM4ZTBlYmNmZTU3Zjg3In0.W1g4469mlxlMubcVX9XcvZ5GtI-2vo6Wr0pCizjjJck';
    final result = await post(Uri.parse('http://sbuy.uz/api/auth/login'),
        body: json.encode({'email': email, 'password': password}),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        });
    //      if(result.statusCode==404){
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
    user = Driver.fromJson(json.decode(result.body));

    await Hive.initFlutter();
    var box = await Hive.openBox('UserInfo');

    box.put('key', user.key);
    box.put('name', user.name);
    box.put('email', user.email);
    box.put('phone', user.phone);
    box.put('type', user.type);
    box.put('status', user.status);
    box.put('address', user.address);

    if (json.decode(result.body)['error'] != 'Unauthenticated.') {
      message = 'Login Successful!';
      setState(() {});
      Navigator.pop(context);
      await Navigator.push(
          context, MaterialPageRoute(builder: (context) => MainScreen()));
    } else {
      message = 'Your email or password is wrong!';
      setState(() {});
    }
  }

  Widget emailField() {
    return TextFormField(
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        labelText: 'Email',
        hintText: 'you@site.com',
      ),
      validator: (String value) {
        if (!value.contains('@')) {
          return "Email format is wrong!";
        }
        return null;
      },
      onSaved: (String value) {
        email = value;
      },
    );
  }

  Widget passwordField() {
    return TextFormField(
      obscureText: true,
      decoration: InputDecoration(labelText: 'Password', hintText: '*******'),
      validator: (String value) {
        if (value.length < 4) {
          return "Password must include at least 4 characters!";
        }
        return null;
      },
      onSaved: (String value) {
        password = value;
      },
    );
  }

  Widget submitButton() {
    return ElevatedButton(
      onPressed: () {
        if (formKey.currentState.validate()) {
          formKey.currentState.save();
          downloadData(email, password);

          // print('$email and $password');
        }
      },
      child: Text("Submit"),
    );
  }

  Widget bottomText() {
    if (email != '' && password != '') {
      return Container(
        margin: EdgeInsets.only(top: 25.0),
        child: Text("$message"),
      );
    }
    return Container();
  }
}
