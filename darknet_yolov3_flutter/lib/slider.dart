import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:darknetyolov3/slider/assets.dart';
import 'package:darknetyolov3/slider/network.dart';
import 'package:search_widget/search_widget.dart';

class SlidersPage extends StatelessWidget {
//  static final String path = "lib/src/pages/misc/sliders.dart";
  final List<String> images = imgSignLink;

  final List<String> contentImgs = imgSignContent;
  String _getNameSign(String imgLink) {
    return imgLink.substring(48, imgLink.indexOf(".png"));
  }

  Widget _buildItem(BuildContext context, int index) {
    return Column(
      children: <Widget>[
        Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10.0),
                  topRight: Radius.circular(10.0)),
              image: DecorationImage(
                  image: NetworkImage(images[index]),
//                                fit: BoxFit.cover
                  scale: 0.5)),
        ),
        Container(
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(10.0),
                    bottomRight: Radius.circular(10.0))),
            child: ListTile(
              subtitle: Text("awesome image caption"),
              title: Text("Awesome image"),
            ))
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              height: 300,
              color: Colors.grey.shade800,
              padding: EdgeInsets.all(16.0),
              child: Swiper(
                itemBuilder: (BuildContext context, int index) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(10.0),
                    child: PNetworkImage(
                      images[index],
                      fit: BoxFit.cover,
                    ),
                  );
                },
                itemCount: 10,
                viewportFraction: 0.8,
                scale: 0.9,
                pagination: SwiperPagination(),
              ),
            ),
            Container(
              height: 340,
              color: Colors.black12,
              padding: EdgeInsets.all(16.0),
              child: Swiper(
                fade: 0.5,
                itemBuilder: (BuildContext context, int index) {
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
                                image: NetworkImage(images[index]),
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
                              title: Text('Biển số: ' +
                                  _getNameSign(imgSignLink[index])),
                              subtitle: Text(contentImgs[index]),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
                itemCount: imgSignLink.length,
                scale: 0.9,
                layout: SwiperLayout.DEFAULT,
                itemHeight: 300,
                itemWidth: 300,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
