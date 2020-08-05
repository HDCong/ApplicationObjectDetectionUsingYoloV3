import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:progress_dialog/progress_dialog.dart';
import 'package:async/async.dart';
import 'package:photo_view/photo_view.dart';

import 'assets.dart';

//import 'network.dart';

class DefautModelScreen extends StatefulWidget {
  @override
  _DefautModelScreenState createState() => _DefautModelScreenState();
}

class _DefautModelScreenState extends State<DefautModelScreen> {
  File _imageFile;
  ProgressDialog pr;
  Uint8List _base64;
//  static String _mIP = "http://192.168.1.4:8558/";

  final Color color1 = Color.fromRGBO(252, 119, 3, 1);
  final Color color2 = Color.fromRGBO(252, 244, 3, 1);
  TextEditingController _c;
  StringBuffer _urlPicture;
  Uri apiUrl = Uri.parse(mIP + "detection");

  void _openGallery(BuildContext context) async {
    var pickedImage = await ImagePicker.pickImage(source: ImageSource.gallery);
    this.setState(() {
      _imageFile = pickedImage;
      _urlPicture = null;
      _base64 = null;
    });
    Navigator.of(context).pop();
  }

  void _openCamera(BuildContext context) async {
    var pickedImage = await ImagePicker.pickImage(source: ImageSource.camera);
    this.setState(() {
      _imageFile = pickedImage;
      _urlPicture = null;
      _base64 = null;
    });
    Navigator.of(context).pop();
  }

  _makePostRequestURL(BuildContext context, String imgUrl) async {
    if (imgUrl == null) return;
    setState(() {
      pr.show();
    });
    Uri uriUrl = Uri.parse(mIP+'detection/url');
    final imageUploadRequest = http.MultipartRequest('POST', uriUrl);

    Map<String, String> map1 = {'url': imgUrl};
    imageUploadRequest.headers.addAll(map1);
    final http.StreamedResponse response = await imageUploadRequest.send();
    print(response.headers);
    print('statusCode => ${response.statusCode}');
    if(response.statusCode>=400) {
      setState(() {
        pr.hide();
      });
      return;
    };
    print(response.headers['listindex'].length);
    if(response.headers['listindex'].length<1){
      Fluttertoast.showToast(
          msg: "No object detected",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.blueAccent,
          textColor: Colors.white,
          fontSize: 16.0
      );
    }
    await response.stream.toBytes().then((value) {
      setState(() {
        _base64 = value;
      });
      pr.hide();
    });
  }

  _makePostRequest(BuildContext context, File imageFile) async {
    if (imageFile == null) return;
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
    if(response.statusCode>=400) {
      setState(() {
        pr.hide();
      });
      return;
    };
    print('Header: ');
    print('length: '+response.headers['listindex'].length.toString());
    if(response.headers['listindex'].length<1){
      print('hhilllo');
      Fluttertoast.showToast(
          msg: "No object detected",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.blueAccent,
          textColor: Colors.white,
          fontSize: 16.0
      );
    }
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

  Widget _decideImage({Uint8List base = null,BuildContext context}) {
    if (_base64 != null)
      return PhotoView(
        imageProvider: new Image.memory(
          _base64,
          width: 400,
          height: 400,
        ).image,
      );
    if (_urlPicture != null) {
      String url = _urlPicture.toString();
      try {
        return CachedNetworkImage(
          imageUrl: url,
          fit: BoxFit.cover,
          errorWidget: (context, url, error) {
            _urlPicture = null;
            return Image(
              image: AssetImage('assets/no_img.png'),
            );
          },
        );
      } catch (e) {
        return Image(
          image: AssetImage('assets/no_img.png'),
        );
      }
    }

    if (_imageFile == null)
      return Image.asset(
        'assets/no_img.png',
        width: 400,
        height: 400,
      );
    return PhotoView(
        imageProvider: Image.file(_imageFile, fit: BoxFit.cover).image);
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
    _c = new TextEditingController();
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            height: 360,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(50.0),
                    bottomRight: Radius.circular(50.0)),
                gradient: LinearGradient(
                    colors: [color1, color2],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight)),
          ),
          Container(
            margin: const EdgeInsets.only(top: 80),
            child: Column(
              children: <Widget>[
                Text(
                  "Default model detection",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontStyle: FontStyle.italic),
                ),
                SizedBox(height: 20.0),
                Expanded(
                  child: Stack(
                    children: <Widget>[
                      Container(
                          height: double.infinity,
                          margin: const EdgeInsets.only(
                              left: 30.0, right: 30.0, top: 10.0),
                          child: ClipRRect(
                              borderRadius: BorderRadius.circular(30.0),
                              child: _decideImage(base: _base64)))
                    ],
                  ),
                ),
                SizedBox(height: 10.0),
                Container(
                  child: Stack(
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 5.0, horizontal: 16.0),
                        margin: const EdgeInsets.only(
                            top: 30, left: 20.0, right: 20.0, bottom: 20.0),
                        decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [color1, color2],
                            ),
                            borderRadius: BorderRadius.circular(30.0)),
                        child: Row(
                          children: <Widget>[
                            IconButton(
                              color: Colors.white,
                              icon: Icon(FontAwesomeIcons.link),
                              onPressed: () {
                                showDialog(
                                    child: new Dialog(
                                      child: new Column(
                                        children: <Widget>[
                                          new TextField(
                                            decoration: new InputDecoration(
                                                hintText: "Image url"),
                                            controller: _c,
                                          ),
                                          new FlatButton(
                                            child: new Text("Use this link"),
                                            onPressed: () {
                                              setState(() {
                                                if(_c.text.length>10 && Uri.parse(_c.text).isAbsolute)
                                                {
                                                  _urlPicture =
                                                  new StringBuffer(_c.text);
                                                  _base64=null;
                                                  _imageFile=null;
                                                }
                                              });
                                              Navigator.pop(context);
                                            },
                                          )
                                        ],
                                      ),
                                    ),
                                    context: context);
                              },
                            ),
                            Spacer(),
                            IconButton(
                              color: Colors.white,
                              icon: Icon(Icons.image),
                              onPressed: () {
                                _showChoiceDiaglog(context);
                              },
                            ),
                          ],
                        ),
                      ),
                      Center(
                        child: FloatingActionButton(
                          child: Icon(
                            Icons.remove_red_eye,
                            color: Colors.pink,
                          ),
                          backgroundColor: Colors.white,
                          onPressed: () {
                            if(_urlPicture!=null) _makePostRequestURL(context, _urlPicture.toString());
                            else
                              _makePostRequest(context, _imageFile);
                          },
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
