import 'dart:io';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eralpsoftware/eralpsoftware.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class GalleryShare extends StatelessWidget {
  final DocumentSnapshot image;
  const GalleryShare({Key key, @required this.image}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: PhotoView(
              imageProvider: CachedNetworkImageProvider(image["imageUrl"]),
              maxScale: PhotoViewComputedScale.contained * 3,
              minScale: PhotoViewComputedScale.contained * 1,
            ),
          ),
          GestureDetector(
            onTap: () async {
              shareFile(image);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                FlatButton.icon(
                  label: Text("Paylaş"),
                  icon: Icon(Icons.share),
                  onPressed: () async {
                    shareFile(image);
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
