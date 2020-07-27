//import 'package:flutter/material.dart';
//import 'package:flutter_page_indicator/flutter_page_indicator.dart';
//import 'package:flutter_swiper/flutter_swiper.dart';
////import 'config.dart';
////import 'forms/form_widget.dart';
//
//class ExampleCustom extends StatefulWidget {
//  @override
//  State<StatefulWidget> createState() {
//    return new _ExampleCustomState();
//  }
//}
//
//class _ExampleCustomState extends State<ExampleCustom> {
//  //properties want to custom
//  int _itemCount;
//
//  bool _loop;
//
//  bool _autoplay;
//
//  int _autoplayDely;
//
//  double _padding;
//
//  bool _outer;
//
//  double _radius;
//
//  double _viewportFraction;
//
//  SwiperLayout _layout;
//
//  int _currentIndex;
//
//  double _scale;
//
//  Axis _scrollDirection;
//
//  Curve _curve;
//
//  double _fade;
//
//  bool _autoplayDisableOnInteraction;
//
//  CustomLayoutOption customLayoutOption;
//
//  Widget _buildItem(BuildContext context, int index) {
//    return ClipRRect(
//      borderRadius: new BorderRadius.all(new Radius.circular(_radius)),
//      child: new Image.asset(
//        images[index % images.length],
//        fit: BoxFit.fill,
//      ),
//    );
//  }
//
//  @override
//  void didUpdateWidget(ExampleCustom oldWidget) {
//    customLayoutOption = new CustomLayoutOption(startIndex: -1, stateCount: 3)
//        .addRotate([-45.0 / 180, 0.0, 45.0 / 180]).addTranslate([
//      new Offset(-370.0, -40.0),
//      new Offset(0.0, 0.0),
//      new Offset(370.0, -40.0)
//    ]);
//    super.didUpdateWidget(oldWidget);
//  }
//
//  @override
//  void initState() {
//    customLayoutOption = new CustomLayoutOption(startIndex: -1, stateCount: 3)
//        .addRotate([-25.0 / 180, 0.0, 25.0 / 180]).addTranslate([
//      new Offset(-350.0, 0.0),
//      new Offset(0.0, 0.0),
//      new Offset(350.0, 0.0)
//    ]);
//    _fade = 1.0;
//    _currentIndex = 0;
//    _curve = Curves.ease;
//    _scale = 0.8;
//    _controller = new SwiperController();
//    _layout = SwiperLayout.TINDER;
//    _radius = 10.0;
//    _padding = 0.0;
//    _loop = true;
//    _itemCount = 3;
//    _autoplay = false;
//    _autoplayDely = 3000;
//    _viewportFraction = 0.8;
//    _outer = false;
//    _scrollDirection = Axis.horizontal;
//    _autoplayDisableOnInteraction = false;
//    super.initState();
//  }
//
//// maintain the index
//
//  Widget buildSwiper() {
//    return new Swiper(
//      onTap: (int index) {
//        Navigator.of(context)
//            .push(new MaterialPageRoute(builder: (BuildContext context) {
//          return Scaffold(
//            appBar: AppBar(
//              title: Text("New page"),
//            ),
//            body: Container(),
//          );
//        }));
//      },
//      customLayoutOption: customLayoutOption,
//      fade: _fade,
//      index: _currentIndex,
//      onIndexChanged: (int index) {
//        setState(() {
//          _currentIndex = index;
//        });
//      },
//      curve: _curve,
//      scale: _scale,
//      itemWidth: 300.0,
//      controller: _controller,
//      layout: _layout,
//      outer: _outer,
//      itemHeight: 200.0,
//      viewportFraction: _viewportFraction,
//      autoplayDelay: _autoplayDely,
//      loop: _loop,
//      autoplay: _autoplay,
//      itemBuilder: _buildItem,
//      itemCount: _itemCount,
//      scrollDirection: _scrollDirection,
//      indicatorLayout: PageIndicatorLayout.COLOR,
//      autoplayDisableOnInteraction: _autoplayDisableOnInteraction,
//      );
//  }
//
//  SwiperController _controller;
//  TextEditingController numberController = new TextEditingController();
//  @override
//  Widget build(BuildContext context) {
//    return new Column(children: <Widget>[
//      new Container(
//        color: Colors.black87,
//        child: new SizedBox(
//            height: 300.0, width: double.infinity, child: buildSwiper()),
//      ),
//      new Expanded(
//          child: new ListView(
//            children: <Widget>[
//              new Text("Index:$_currentIndex"),
//              new Row(
//                children: <Widget>[
//                  new RaisedButton(
//                    onPressed: () {
//                      _controller.previous(animation: true);
//                    },
//                    child: new Text("Prev"),
//                  ),
//                  new RaisedButton(
//                    onPressed: () {
//                      _controller.next(animation: true);
//                    },
//                    child: new Text("Next"),
//                  ),
//                  new Expanded(
//                      child: new TextField(
//                        controller: numberController,
//                      )),
//                  new RaisedButton(
//                    onPressed: () {
//                      var text = numberController.text;
//                      setState(() {
//                        _currentIndex = int.parse(text);
//                      });
//                    },
//                    child: new Text("Update"),
//                  ),
//                ],
//              ),
//
//            ],
//          ))
//    ]);
//  }
//}