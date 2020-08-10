import 'package:aycacem/pages/home_page/gallery_photo_detail/gallery_photo_detail.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class GridItem extends StatefulWidget {
  final List<DocumentSnapshot> image;
  final int index;
  final int maxIndex;
  GridItem(
      {Key key,
      @required this.image,
      @required this.index,
      @required this.maxIndex})
      : super(key: key);

  @override
  _GridItemState createState() => _GridItemState();
}

class _GridItemState extends State<GridItem>
    with AutomaticKeepAliveClientMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: InkWell(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => GalleryPhotoDetail(
                        image: widget.image,
                        index: widget.index,
                        maxIndex: widget.maxIndex,
                      )));
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.0),
          child: GridTile(
            child: CachedNetworkImage(
              fit: BoxFit.cover,
              imageUrl: widget.image[widget.index]["imageUrl"],
              placeholder: (context, url) =>
                  Image.asset("assets/gifs/loading.gif"),
              errorWidget: (context, url, error) => Icon(Icons.error),
            ),
          ),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
