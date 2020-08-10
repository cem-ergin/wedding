import 'dart:io';
import 'dart:typed_data';

import 'package:aycacem/pages/home_page/gallery_photo_detail/gallery_share.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eralpsoftware/eralpsoftware.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class GalleryPhotoDetail extends StatefulWidget {
  final List<DocumentSnapshot> image;
  final int index;
  final int maxIndex;
  const GalleryPhotoDetail(
      {Key key,
      @required this.image,
      @required this.index,
      @required this.maxIndex})
      : super(key: key);

  @override
  _GalleryPhotoDetailState createState() => _GalleryPhotoDetailState();
}

class _GalleryPhotoDetailState extends State<GalleryPhotoDetail> {
  int _index;
  int _lastIndex;
  @override
  void initState() {
    super.initState();
    _index = widget.index;
    _lastIndex = widget.index;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Fotoğraf Detayı'),
        actions: <Widget>[
          FlatButton(
            child: Text("${_index + 1}/${widget.maxIndex + 1}",
                style: TextStyle(color: Colors.white)),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (BuildContext context) {
                  return CupertinoPicker(
                    scrollController:
                        FixedExtentScrollController(initialItem: _index),
                    useMagnifier: true,
                    onSelectedItemChanged: (value) {
                      setState(() {
                        _index = value;
                      });
                    },
                    itemExtent: 32.0,
                    children: List.generate(widget.image.length,
                        (index) => Text((index + 1).toString())),
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) =>
                            GalleryShare(image: widget.image[_index])));
              },
              onHorizontalDragEnd: (a) {
                final move = a.velocity.pixelsPerSecond.dx;
                //saga artir
                // print(move.abs());
                if (move.abs() > 500) {
                  print("girdim");
                  if (move < 0) {
                    _lastIndex = _index;
                    print("<0");
                    if (_index + 1 < widget.maxIndex) {
                      setState(() {
                        _index += 1;
                      });
                    }
                  } else {
                    if (_index - 1 > -1) {
                      setState(() {
                        _index -= 1;
                      });
                    }
                  }
                }
              },
              child: AnimatedSwitcher(
                duration: Duration(seconds: 1),
                child: _lastIndex == _index
                    ? Container(
                        key: Key("123"),
                        child: CachedNetworkImage(
                          fit: BoxFit.cover,
                          imageUrl: widget.image[_index]["imageUrl"],
                          placeholder: (context, url) =>
                              Image.asset("assets/gifs/loading.gif"),
                          errorWidget: (context, url, error) =>
                              Icon(Icons.error),
                        ),
                      )
                    : CachedNetworkImage(
                        key: Key(widget.image[_index]["imageUrl"]),
                        fit: BoxFit.cover,
                        imageUrl: widget.image[_index]["imageUrl"],
                        placeholder: (context, url) =>
                            Image.asset("assets/gifs/loading.gif"),
                        errorWidget: (context, url, error) => Icon(Icons.error),
                      ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () async {
              shareFile(widget.image[widget.index]["imageUrl"]);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                FlatButton.icon(
                  label: Text("Paylaş"),
                  icon: Icon(Icons.share),
                  onPressed: () async {
                    shareFile(widget.image[widget.index]["imageUrl"]);
                  },
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Future<void> shareFile(DocumentSnapshot image) async {
    Eralp.startProgress(
      maxSecond: 5,
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
    var request = await HttpClient().getUrl(Uri.parse(
      image["imageUrl"],
    ));
    String imageName = image["imageUrl"].split("/").last;
    try {
      imageName = imageName + "." + image["contentType"].split("/")[1];
    } on Exception catch (e) {
      print(e);
    }

    var response = await request.close();
    Uint8List bytes = await consolidateHttpClientResponseBytes(response);
    Eralp.stopProgress();
    await Share.file(imageName, imageName, bytes, 'image/png');
  }
}
