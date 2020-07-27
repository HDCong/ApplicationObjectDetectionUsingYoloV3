import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:progress_dialog/progress_dialog.dart';
import 'package:async/async.dart';
import 'package:photo_view/photo_view.dart';

import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:darknetyolov3/slider/assets.dart';

import 'package:search_widget/search_widget.dart';

class MySliderSign extends StatefulWidget {
  @override
  _MySliderSignState createState() => _MySliderSignState();
}

class _MySliderSignState extends State<MySliderSign> {
  final List<String> images = imgSignLink;

  final List<String> contentImgs = imgSignContent;

  SwiperController _controller;

  File _imageFile;
  ProgressDialog pr;
  Uint8List _base64;
  bool hasSolution;
  static String _mIP = "http://192.168.1.12:8558/";
  Uri apiUrlCustom = Uri.parse(_mIP + "custom");
  Uri apiUrl = Uri.parse(_mIP + "detection");
  TextEditingController numberController = new TextEditingController();

  @override
  void initState() {
    _controller = new SwiperController();
    hasSolution = false;
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
    super.initState();
  }

  Widget _buildItem(BuildContext context, int index) {
    return Column(
      children: <Widget>[
        Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [Colors.grey, Colors.lightBlue]),
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10.0),
                  topRight: Radius.circular(10.0)),
              image: DecorationImage(
                  image: NetworkImage(images[index]), scale: 0.5)),
        ),
        Expanded(
          flex: 1,
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(10.0),
                      bottomRight: Radius.circular(10.0))),
              child: ListTile(
                title: Text('Biển số: ' + _getNameSign(imgSignLink[index])),
                subtitle: Text(contentImgs[index]),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSwipe() {
    return Swiper(
      itemBuilder: _buildItem,
      itemCount: imgSignLink.length,
      scale: 0.9,
      layout: SwiperLayout.DEFAULT,
      itemHeight: 300,
      itemWidth: 300,
      controller: _controller,
      fade: 0.5,
    );
  }

  Widget _showInformationAfterDetected() {
    if (hasSolution)
      return Container();
    else {
      Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Traffic Sign Detection'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            SizedBox(height: 30.0),
            Column(children: <Widget>[
              RaisedButton(
                onPressed: () {
                  _showChoiceDiaglog(context);
                },
                child: Text("Select Image"),
              ),
              _decideImage(base: _base64),
              RaisedButton(
                onPressed: () {
                  _makePostRequest(context, _imageFile);
                  setState(() {
                    print('helo');
                  });
                },
                child: Text("Detect"),
              ),
            ]),
            SizedBox(height: 30.0),
            // After has solution
            hasSolution == false ? Container() : Container(),
            SizedBox(height: 30.0),
            RaisedButton(
              onPressed: () {
//                var text = numberController.text;
                var text="24";
                int val = int.tryParse(text, radix: 10);
                if (!(val == null || val < 0 || val >= images.length))
                  setState(() {
                    _controller.move(val);
                  });
              },
              child: new Text("Update"),
            ),
            Container(
              height: 340,
              color: Colors.black12,
              padding: EdgeInsets.all(16.0),
              child: _buildSwipe(),
            ),
          ],
        ),
      ),
    );
  }

  void _openGallery(BuildContext context) async {
    var pickedImage = await ImagePicker.pickImage(source: ImageSource.gallery);
    this.setState(() {
      _imageFile = pickedImage as File;
      _base64 = null;
    });
    Navigator.of(context).pop();
  }

  void _openCamera(BuildContext context) async {
    var pickedImage = await ImagePicker.pickImage(source: ImageSource.camera);
    this.setState(() {
      _imageFile = pickedImage as File;
      _base64 = null;
    });
    Navigator.of(context).pop();
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
    if (base != null) {
      return Container(
        color: Colors.white,
        width: 400,
        height: 400,
        child: PhotoView(
          imageProvider: new Image.memory(
            _base64,
            width: 400,
            height: 400,
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

  String _getNameSign(String imgLink) {
    return imgLink.substring(48, imgLink.indexOf(".png"));
  }
}
