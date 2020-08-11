import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:darknetyolov3/BirdObject.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:progress_dialog/progress_dialog.dart';
import 'package:async/async.dart';
import 'package:photo_view/photo_view.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'assets.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:fluttertoast/fluttertoast.dart';

class MySliderBird extends StatefulWidget {
  @override
  _MySliderBirdState createState() => _MySliderBirdState();
}

class _MySliderBirdState extends State<MySliderBird> {
  final List<String> images = birdImg;
  final List<String> contentImgs = birdInfor;
  final List<String> name = birdName;
  bool _visible = true;
  List<BirdObject> _BirdObject;
  StringBuffer _urlPicture;
  final Color color1 = Color.fromRGBO(252, 119, 3, 1);
  final Color color2 = Color.fromRGBO(252, 244, 3, 1);
  TextEditingController _c;

  SwiperController _controller;
  List<int> _indexObjectDetected;
  File _imageFile;
  ProgressDialog pr;
  Uint8List _base64;
  bool hasSolution;
  Uri apiUrl = Uri.parse(mIP + "custom");

//  Uri apiUrl = Uri.parse(mIP + "detection");
  TextEditingController numberController = new TextEditingController();

  void intiForbirdDetails() {
    _BirdObject = new List<BirdObject>();
    for (int i = 0; i < images.length; i++) {
      _BirdObject.add(new BirdObject(i, name[i], images[i], contentImgs[i]));
    }
  }

  @override
  void initState() {
    _indexObjectDetected = new List<int>();
    _controller = new SwiperController();
    hasSolution = false;
    intiForbirdDetails();
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
                  colors: [color1, color2]),
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
                title: Text(_BirdObject[index].mName),
                subtitle: Text(_BirdObject[index].mContent),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildItem2(BuildContext context, int index) {
    return Column(
      children: <Widget>[
        Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [color1, color2]),
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10.0),
                  topRight: Radius.circular(10.0)),
              image: DecorationImage(
                  image: NetworkImage(images[_indexObjectDetected[index]]),
                  scale: 0.5)),
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
                title: Text(_BirdObject[_indexObjectDetected[index]].mName),
                subtitle:
                    Text(_BirdObject[_indexObjectDetected[index]].mContent),
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
      itemCount: images.length,
      scale: 0.9,
      layout: SwiperLayout.DEFAULT,
      itemHeight: 300,
      itemWidth: 300,
      controller: _controller,
      fade: 0.5,
    );
  }

  Widget _buildSwipe2() {
    if (_indexObjectDetected.length < 1) return Container();
//    return Column(children: <Widget>[
    return Swiper(
      itemBuilder: _buildItem2,
      itemCount: _indexObjectDetected.length,
      scale: 0.9,
      layout: SwiperLayout.DEFAULT,
      itemHeight: 300,
      itemWidth: 300,
//      controller: _controller,
      fade: 0.5,
//      pagination: new SwiperPagination(),
    );
//    ]);
  }

  Widget _customPopupItem(
      BuildContext context, BirdObject item, bool isSelected) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8),
      decoration: !isSelected
          ? null
          : BoxDecoration(
              border: Border.all(color: Theme.of(context).primaryColor),
              borderRadius: BorderRadius.circular(5),
              color: Colors.white,
            ),
      child: ListTile(
        selected: isSelected,
        title: Text(item.mName),
        subtitle: Text(item.mContent),
        leading: CircleAvatar(
          backgroundImage: NetworkImage(item.mLink),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _c = new TextEditingController();
    TextEditingController _cServer = new TextEditingController()..text="192.168.";

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Stack(
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
                Row(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 15),
                      child: FloatingActionButton(
                        foregroundColor: Colors.black54,
                        backgroundColor: Colors.yellow[600],
                        elevation: 2.0,
                        child: Icon(Icons.settings_remote),
                        onPressed: () {
//                          print('Clicked');
                          setState(() {
                            _visible = !_visible;
                          });
                        },
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 15,left:10),
                      child: AnimatedOpacity(
                        // If the widget is visible, animate to 0.0 (invisible).
                        // If the widget is hidden, animate to 1.0 (fully visible).
                        opacity: _visible ? 1.0 : 0.0,
                        duration: Duration(milliseconds: 500),
                        // The green box must be a child of the AnimatedOpacity widget.
                        child: Row(
                          children: [
                            Container(
                              width: 200.0,
                              height: 50.0,
                              color:Colors.white,
                              child:TextField(
                                decoration:
                                new InputDecoration(
                                    hintText:
                                    "API Address"),
                                controller: _cServer,
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.only(left:10),
                              child: FloatingActionButton(
                                foregroundColor: Colors.black54,
                                backgroundColor: Colors.yellow[600],
                                elevation: 2.0,
                                child: Icon(FontAwesomeIcons.arrowRight),
                                onPressed: () {
//                          print('Clicked');
                                  setState(() {
                                    if (_cServer.text.length > 5) {
                                       apiUrl = Uri.parse("http://" + _cServer.text+ ":8558/custom");
                                      _visible = !_visible;
                                    }
                                    print(apiUrl.toString());
                                  });
                                },
                              ),
                            ),

                          ],
                        )
                      ),
                    ),
                  ],
                ),
                Container(
                    margin: const EdgeInsets.only(top: 80),
                    height: 500,
                    child: Column(children: <Widget>[
                      Text(
                        "Bird detection",
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
                                  top: 30,
                                  left: 20.0,
                                  right: 20.0,
                                  bottom: 20.0),
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
                                                  decoration:
                                                      new InputDecoration(
                                                          hintText:
                                                              "Image url"),
                                                  controller: _c,
                                                ),
                                                new FlatButton(
                                                  child:
                                                      new Text("Use this link"),
                                                  onPressed: () {
                                                    if (_c.text.length > 5 && Uri.parse(_c.text).isAbsolute) {
                                                      _urlPicture =
                                                          new StringBuffer(
                                                              _c.text);
                                                      _base64 = null;
                                                      _imageFile = null;
                                                      hasSolution = false;
                                                    }
                                                    setState(() {});
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
                                  if (_urlPicture != null)
                                    _makePostRequestURL(
                                        context, _urlPicture.toString());
                                  else
                                    _makePostRequest(context, _imageFile);
                                },
                              ),
                            ),
                          ],
                        ),
                      )
                    ])),
              ],
            ),
            if (hasSolution && _indexObjectDetected.length > 0)
              Text(
                "${_indexObjectDetected.length} bird(s) detected",
                style: DefaultTextStyle.of(context)
                    .style
                    .apply(fontSizeFactor: 1.5),
              ),
            hasSolution == false
                ? Container()
                : Container(
                    height: 340,
                    color: Colors.white,
                    padding: EdgeInsets.all(16.0),
                    child: _buildSwipe2(),
                  ),
            SizedBox(height: 30.0),
            Text(
              "Discovery or Search",
              style:
                  DefaultTextStyle.of(context).style.apply(fontSizeFactor: 2.0),
            ),
            Container(
              padding: EdgeInsets.all(16.0),
              child: DropdownSearch<BirdObject>(
                mode: Mode.BOTTOM_SHEET,
                maxHeight: 300,
                items: _BirdObject,
                onChanged: (BirdObject d) {
                  _controller.move(d.index);
                },
                showSearchBox: true,
                showSelectedItem: false,
                popupItemBuilder: _customPopupItem,
                searchBoxDecoration: InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.fromLTRB(12, 12, 8, 0),
                  labelText: "Search for bird",
                ),
                popupTitle: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColorDark,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'Search for bird',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                popupShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                compareFn: (BirdObject i, BirdObject s) => i.isEqual(s),
                filterFn: (BirdObject i, String filter) => i.isFiltered(filter),
              ),
            ),
            //Swiper here
            Container(
              height: 340,
              color: Colors.white,
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
      _imageFile = pickedImage;
      _urlPicture = null;
      _base64 = null;
      hasSolution = false;
    });
    Navigator.of(context).pop();
  }

  void _openCamera(BuildContext context) async {
    var pickedImage = await ImagePicker.pickImage(source: ImageSource.camera);
    this.setState(() {
      _imageFile = pickedImage;
      _urlPicture = null;
      _base64 = null;
      hasSolution = false;
    });
    Navigator.of(context).pop();
  }

  _makePostRequestURL(BuildContext context, String imgUrl) async {
    if (imgUrl == null) return;
    hasSolution = false;

    setState(() {
      pr.show();
    });
    Uri uriUrl = Uri.parse(apiUrl.toString() + '/url');

    final imageUploadRequest = http.MultipartRequest('POST', uriUrl);

    Map<String, String> map1 = {'url': imgUrl};
    imageUploadRequest.headers.addAll(map1);
    final http.StreamedResponse response = await imageUploadRequest.send();
    print(response.headers);
    print('statusCode => ${response.statusCode}');
    print('Header: ');

    if (response.statusCode >= 400) {
      setState(() {
        pr.hide();
      });
      return;
    }
    ;

    print(response.headers['listindex']);
    if (response.headers['listindex'].length > 0) {
      List<int> listObject =
          response.headers['listindex'].split(',').map(int.parse).toList();
      _indexObjectDetected = listObject;
      hasSolution = true;
      setState(() {});
    } else {
      _indexObjectDetected = new List<int>();
      Fluttertoast.showToast(
          msg: "No object detected",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.blueAccent,
          textColor: Colors.white,
          fontSize: 16.0);
    }

    await response.stream.toBytes().then((value) {
      setState(() {
        print('Hileo');
        _base64 = value;
      });
      pr.hide();
    });
  }

  _makePostRequest(BuildContext context, File imageFile) async {
    if (imageFile == null) return;
    hasSolution = false;

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
    if (response.statusCode >= 400) {
      setState(() {
        pr.hide();
      });
      return;
    }
    ;
//     listen for response
    List<String> contentHeader = response.headers.values.toList();
    print('Header At new: ');
    print(response.headers['listindex']);
    if (response.headers['listindex'].length > 0) {
      List<int> listObject =
          response.headers['listindex'].split(',').map(int.parse).toList();
      _indexObjectDetected = listObject;
      for (int x in listObject) print(x);
      hasSolution = true;
      setState(() {});
    } else {
      _indexObjectDetected = new List<int>();
      Fluttertoast.showToast(
          msg: "No object detected",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.blueAccent,
          textColor: Colors.white,
          fontSize: 16.0);
    }

    await response.stream.toBytes().then((value) {
      setState(() {
        _base64 = value;
      });
      pr.hide();
    });
  }

//
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

//  Widget _decideImage({Uint8List base = null}) {
//    if (_base64 != null)
//      return Container(
//          padding: EdgeInsets.all(16.0),
//          child: Container(
//            height: 400,
//            width: double.infinity,
//            child: PhotoView(
//              imageProvider: new Image.memory(
//                _base64,
//                width: 400,
//                height: 400,
//              ).image,
//            ),
//          ));
//    if (_imageFile == null) {
//      return Text("Your image here");
//    }
//    return Container(
//        padding: EdgeInsets.all(16.0),
//        child: Container(
//          height: 300,
//          width: double.infinity,
//          decoration: BoxDecoration(
//            gradient: LinearGradient(
//                begin: Alignment.topRight,
//                end: Alignment.bottomLeft,
//                colors: [Colors.grey, Colors.lightBlue]),
//            borderRadius: BorderRadius.circular(10.0),
//            image: DecorationImage(image: FileImage(_imageFile)),
//          ),
//        ));
//  }
  Widget _decideImage({Uint8List base = null, BuildContext context}) {
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

  Future<List<BirdObject>> filterData(String filterz) async {
    print('filter: ' + filterz);
    String filter = filterz.toLowerCase();
    if (filter.length == 0) return _BirdObject;
    List<BirdObject> res = new List<BirdObject>();
    for (BirdObject birdDetail in _BirdObject) {
      if (birdDetail.mName.toLowerCase().contains(filter) ||
          birdDetail.mContent.toLowerCase().contains(filter))
        res.add(birdDetail);
    }
    return res;
  }
}

class Detail extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            ),
            Text("Detail"),
          ],
        ),
      ),
    );
  }
}
