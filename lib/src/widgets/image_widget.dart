import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:connectivity/connectivity.dart';
import 'package:http/http.dart';
import '../screens/login_screen.dart';
import '../screens/main_screen.dart';

class ImageUpload extends StatefulWidget {
  final id;
  ImageUpload(this.id);

  @override
  _ImageUploadState createState() => _ImageUploadState();
}

class _ImageUploadState extends State<ImageUpload> {
  @override
  XFile _image;
  bool isUpload = false;
  var status = '';
  var key;
  Widget buttonInfo = Text('Upload BOL');

  Future<String> getInfo() async {
    await Hive.initFlutter();
    var box = await Hive.openBox('UserInfo');
    key = box.get('key');
    return key;
  }

  void uploadImageFile() async {
    await getInfo();
    List<int> imageBytes = File(_image.path).readAsBytesSync();
    String baseImage = base64Encode(imageBytes);
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
                buttonInfo = Text('Upload BOL');
                isUpload = true;
                setState(() {});
              },
              color: Color.fromRGBO(0, 179, 134, 1.0),
              radius: BorderRadius.circular(0.0),
            ),
          ],
        ).show();
      }
    }

    // spinner
    isUpload = false;
    buttonInfo = SizedBox(
      child: CircularProgressIndicator(
        strokeWidth: 5,
        valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
      ),
      height: 20.0,
      width: 20.0,
    );
    setState(() {});

    var token = key;
    final result = await post(Uri.parse('http://sbuy.uz/api/load/send_bol'),
        body: json.encode({
          'loadid': widget.id,
          'bol': 'data:image/jpeg;base64,$baseImage',
        }),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        });

    if (json.decode(result.body)['error'] == 'Unauthenticated.') {
      Navigator.pop(context);
      await Navigator.push(
          context, MaterialPageRoute(builder: (context) => LoginScreen()));
    }

    if (json.decode(result.body)['success'] == 1) {
      buttonInfo = Text('Upload BOL');
      setState(() {});
      Alert(
        context: context,
        type: AlertType.success,
        title: "Successfully Sent!",
        style: AlertStyle(
          isOverlayTapDismiss: false,
          isCloseButton: false,
        ),
        buttons: [
          DialogButton(
            child: Text(
              "OK",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            onPressed: () => Navigator.pop(context),
            color: Color.fromRGBO(0, 179, 134, 1.0),
            radius: BorderRadius.circular(0.0),
          ),
        ],
      ).show();

      Future.delayed(Duration(milliseconds: 1000), () {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => MainScreen()));
      });
    }
  }

  _imgFromCamera() async {
    XFile image = await ImagePicker()
        .pickImage(source: ImageSource.camera, imageQuality: 50);
    isUpload = true;
    setState(() {
      _image = image;
    });
  }

  _imgFromGallery() async {
    XFile image = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 50);
    isUpload = true;
    setState(() {
      _image = image;
    });
  }

  void _showPicker(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Container(
              child: new Wrap(
                children: <Widget>[
                  new ListTile(
                      leading: new Icon(Icons.photo_library),
                      title: new Text('Photo Library'),
                      onTap: () {
                        _imgFromGallery();
                        Navigator.of(context).pop();
                      }),
                  new ListTile(
                    leading: new Icon(Icons.photo_camera),
                    title: new Text('Camera'),
                    onTap: () {
                      _imgFromCamera();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  Widget showImage() {
    if (_image != null) {
      return ClipRRect(
        child: Image.file(
          File(_image.path),
          fit: BoxFit.fill,
        ),
      );
    }
    return Row(
      children: [
        Flexible(
          child: Container(
            width: double.infinity,
            child: Text(
              'No BOL choosen!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF5B7290),
              ),
            ),
          ),
          flex: 1,
        )
      ],
    );
  }

  uploadImage() {
    if (isUpload) {
      return _showPicker(context);
    } else {
      return null;
    }
  }

  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      margin: EdgeInsets.fromLTRB(15, 20, 15, 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Row(
            children: [
              Flexible(
                flex: 1,
                child: Container(
                  padding: EdgeInsets.all(20),
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      _showPicker(context);
                    },
                    child: Text('Choose BOL'),
                  ),
                ),
              ),
              Flexible(
                flex: 1,
                child: Container(
                    padding: EdgeInsets.all(20),
                    width: double.infinity,
                    child: isUpload
                        ?
                        // When image picked
                        ElevatedButton(
                            onPressed: () {
                              if (isUpload) {
                                uploadImageFile();
                              }
                            },
                            child: buttonInfo,
                            style: ElevatedButton.styleFrom(
                              primary: Colors.green, // background
                              onPrimary: Colors.white, // foreground
                            ),
                          )
                        :
                        // When image not picked
                        ElevatedButton(
                            onPressed: null,
                            child: buttonInfo,
                          )),
              ),
            ],
          ),
          Divider(),
          Container(
            margin: EdgeInsets.all(20),
            color: Color(0xFFE7EBF0),
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.65,
            child: showImage(),
          ),

          //   showImage(),
        ],
      ),
    );
  }
}
