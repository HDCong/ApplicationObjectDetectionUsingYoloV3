import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:progress_dialog/progress_dialog.dart';
import 'package:async/async.dart';
import 'package:photo_view/photo_view.dart';

class HomePageScreen extends StatefulWidget {
  @override
  _HomePageScreenState createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageScreen> {
  File _imageFile;
  ProgressDialog pr;
  Uint8List _base64;
  static String _mIP = "http://192.168.1.12:8558/";

//  Uri apiUrl = Uri.parse("http://10.0.2.2:8558/detection");
//  Uri apiUrlCustom = Uri.parse(_mIP + "custom");
  Uri apiUrl = Uri.parse(_mIP + "detection");

  void _openGallery(BuildContext context) async {
    var pickedImage = await ImagePicker.pickImage(source: ImageSource.gallery);
    this.setState(() {
      _imageFile = pickedImage;
      _base64=null;
    });
    Navigator.of(context).pop();
  }

  void _openCamera(BuildContext context) async {
    var pickedImage = await ImagePicker.pickImage(source: ImageSource.camera);
    this.setState(() {
      _imageFile = pickedImage;
      _base64=null;

    });
    Navigator.of(context).pop();
  }

  _makePostRequest(BuildContext context, File imageFile) async {
    if(imageFile==null) return;
    setState(() {
      pr.show();
    });
    var stream =
    new http.ByteStream(DelegatingStream.typed(imageFile.openRead()));
    final imageUploadRequest = http.MultipartRequest('POST', apiUrl);
    var length = await imageFile.length();
    var multipartFile =
    new http.MultipartFile('image', stream, length, filename: 'image');
    imageUploadRequest.files.add(multipartFile);

    final http.StreamedResponse response = await imageUploadRequest.send();
    print('statusCode => ${response.statusCode}');

//     listen for response
    print(response.headers);
    await response.stream.toBytes().then((value) {
      setState(() {
        _base64 = value;
      });
      pr.hide();
    });
  }

  Future<void> _showChoiceDiaglog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Choose your image'),
            content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    GestureDetector(
                      child: Text("Gallery"),
                      onTap: () {
                        _openGallery(context);
                      },
                    ),
                    Padding(padding: EdgeInsets.all(8)),
                    GestureDetector(
                      child: Text("Camera"),
                      onTap: () {
                        _openCamera(context);
                      },
                    )
                  ],
                )),
          );
        });
  }

  Widget _decideImage({Uint8List base = null}) {
    if(base!=null){
      return Container(
        color: Colors.white,
        width: 400, height: 400,
        child: PhotoView(
          imageProvider: new Image.memory(
            _base64,
            width: 400, height: 400,
          ).image,
        ),
      );
    }
    if (_imageFile == null) {
      return Text("Your image here");
    } else {
      return Image.file(
        _imageFile,
        width: 400,
        height: 400,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    pr = new ProgressDialog(context, type: ProgressDialogType.Normal);

    //Optional
    pr.style(
      message: 'Please wait...',
      borderRadius: 10.0,
      backgroundColor: Colors.white,
      progressWidget: CircularProgressIndicator(),
      elevation: 10.0,
      insetAnimCurve: Curves.easeInOut,
      progressTextStyle: TextStyle(
          color: Colors.black, fontSize: 13.0, fontWeight: FontWeight.w400),
      messageTextStyle: TextStyle(
          color: Colors.black, fontSize: 19.0, fontWeight: FontWeight.w600),
    );
    return Scaffold(
      appBar: AppBar(
        title: Text("Default Model"),
        backgroundColor: Colors.black26,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
//            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              RaisedButton(
                onPressed: () {
                  _showChoiceDiaglog(context);
                },
                child: Text("Select Image"),
              ),
              _decideImage(base:_base64),
              RaisedButton(
                onPressed: () {
                  _makePostRequest(context, _imageFile);
                  setState(() {});
                },
                child: Text("Detect"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
