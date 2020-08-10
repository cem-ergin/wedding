import 'dart:io';

import 'package:aycacem/blocs/images/images_bloc.dart';
import 'package:aycacem/blocs/is_loading/is_loading_bloc.dart';
import 'package:aycacem/pages/camera_page/camera_page.dart';
import 'package:aycacem/pages/home_page/grid_item/grid_item.dart';
import 'package:aycacem/providers/user_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eralpsoftware/eralpsoftware.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_pagewise/flutter_pagewise.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:image_picker/image_picker.dart';
import 'package:paging/paging.dart';
import 'package:provider/provider.dart';

class GalleryPage extends StatefulWidget {
  GalleryPage({Key key}) : super(key: key);

  @override
  _GalleryPageState createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  UserProvider _userProviderLF;
  ScrollController _scrollController;
  bool _isScrollEnd = false;
  @override
  void initState() {
    super.initState();
    _userProviderLF = Provider.of<UserProvider>(context, listen: false);
    _scrollController = ScrollController();
    // _scrollController.addListener(() {
    //   if (_scrollController.position.pixels ==
    //       _scrollController.position.maxScrollExtent) {
    //     _isScrollEnd = true;
    //     print("scroll end");
    //     setState(() {});
    //   } else {
    //     _isScrollEnd = false;
    //     setState(() {});
    //   }
    // });
  }

  final List<DocumentSnapshot> _ds = [];

  Future<List<DocumentSnapshot>> getDocs(
      int currentIndex, int index, List<DocumentSnapshot> ds) {
    for (var i = currentIndex; i < index; i++) {
      _ds.add(ds[i]);
    }
    return Future.value(_ds);
  }

  static const int _COUNT = 9;

  @override
  Widget build(BuildContext context) {
    final ImagesBloc _imagesBloc = BlocProvider.of<ImagesBloc>(context);
    final IsLoadingBloc _isLoadingBloc =
        BlocProvider.of<IsLoadingBloc>(context);
    final Size _size = MediaQuery.of(context).size;
    int _count = 18;

    return Scaffold(
      appBar: AppBar(
        leading: BlocConsumer(
          cubit: _isLoadingBloc,
          builder: (context, state) {
            if (state is IsLoadingLoadingState) {
              return Center(
                child: CircularProgressIndicator(
                  backgroundColor: Colors.white,
                ),
              );
            }
            return Container();
          },
          listener: (BuildContext context, state) {},
        ),
        title: InkWell(
            onTap: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (_) => CameraPage()));
            },
            child: Text("AycaCem")),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              _imagesBloc.add(GetImagesEvent());
            },
          ),
        ],
      ),
      body: BlocBuilder(
        cubit: _imagesBloc,
        builder: (context, _imagesState) {
          if (_imagesState is ImagesInitialState) {
            _imagesBloc.add(GetImagesEvent());
            return buildCircularProgressIndicator();
          }
          if (_imagesState is ImagesLoadingState) {
            return buildCircularProgressIndicator();
          }
          if (_imagesState is ImagesLoadedState) {
            List<DocumentSnapshot> _myDocs =
                _imagesState.querySnapshot.documents.reversed.toList();
            // return PagewiseGridView.count(
            //   pageSize: _count,
            //   crossAxisCount: 3,
            //   mainAxisSpacing: 8.0,
            //   crossAxisSpacing: 8.0,
            //   childAspectRatio: 0.555,
            //   padding: EdgeInsets.all(15.0),
            //   itemBuilder: (context, b, count) {
            //     return GridView.builder(
            //       // controller: _scrollController,
            //       addAutomaticKeepAlives: true,
            //       // itemCount: _myDocs.length,
            //       itemCount: count,
            //       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            //         crossAxisCount: 3,
            //         mainAxisSpacing: 8,
            //         crossAxisSpacing: 8,
            //       ),
            //       itemBuilder: (context, index) {
            //         return GridItem(
            //             image: _myDocs, index: index, maxIndex: _myDocs.length);
            //       },
            //     );
            //   },
            //   pageFuture: (pageIndex) =>getDocs(pageIndex,)
            //       // BackendService.getImages(pageIndex * PAGE_SIZE, PAGE_SIZE),
            // );
            return GridView.builder(
              // controller: _scrollController,
              addAutomaticKeepAlives: true,
              itemCount: _myDocs.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
              ),
              itemBuilder: (context, index) {
                return GridItem(
                    image: _myDocs, index: index, maxIndex: _myDocs.length);
              },
            );
          }
          if (_imagesState is ImagesErrorState) {
            return buildErrorState(_imagesBloc);
          }
        },
      ),
      // floatingActionButton: !_isScrollEnd
      //     ? Column(
      //         mainAxisAlignment: MainAxisAlignment.end,
      //         children: <Widget>[
      //           Container(
      //             width: _size.width * 0.5,
      //             child: FloatingActionButton.extended(
      //               key: Key("1"),
      //               heroTag: "1",
      //               onPressed: () => Navigator.push(
      //                 context,
      //                 MaterialPageRoute(
      //                   builder: (_) => CameraPage(),
      //                 ),
      //               ),
      //               // _getAndUploadImage(
      //               //     source: ImageSource.camera,
      //               //     imagesBloc: _imagesBloc,
      //               //     isLoadingBloc: _isLoadingBloc),
      //               label: Text("Kameradan ekle"),
      //               icon: Icon(Icons.camera_alt),
      //             ),
      //           ),
      //           SizedBox(height: 8),
      //           Container(
      //             width: _size.width * 0.5,
      //             child: FloatingActionButton.extended(
      //               key: Key("2"),
      //               heroTag: "2",
      //               onPressed: () => _getAndUploadImage(
      //                   source: ImageSource.gallery,
      //                   imagesBloc: _imagesBloc,
      //                   isLoadingBloc: _isLoadingBloc),
      //               label: Text("Galeriden ekle"),
      //               icon: Icon(Icons.photo_album),
      //             ),
      //           ),
      //         ],
      //       )
      //     : Container(),
      floatingActionButton: SpeedDial(
        // both default to 16
        marginRight: 18,
        marginBottom: 20,
        animatedIcon: AnimatedIcons.add_event,
        animatedIconTheme: IconThemeData(size: 22.0, color: Colors.white),
        // this is ignored if animatedIcon is non null
        // child: Icon(Icons.add),
        visible: true,
        // If true user is forced to close dial manually
        // by tapping main button and overlay is not rendered.
        closeManually: false,
        curve: Curves.bounceIn,
        overlayColor: Colors.black,
        overlayOpacity: 0.8,
        tooltip: 'Speed Dial',
        heroTag: 'speed-dial-hero-tag',
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.black,
        elevation: 8.0,
        shape: CircleBorder(),
        children: [
          SpeedDialChild(
            child: Icon(Icons.camera_alt),
            label: 'Kamera ile çek',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CameraPage(),
              ),
            ),
          ),
          SpeedDialChild(
            child: Icon(Icons.photo_library),
            label: 'Galeriden yükle',
            onTap: () => _getAndUploadImage(
                source: ImageSource.gallery,
                imagesBloc: _imagesBloc,
                isLoadingBloc: _isLoadingBloc),
          ),
        ],
      ),
    );
  }

  Container buildErrorState(ImagesBloc _imagesBloc) {
    return Container(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text("Beklenmedik bir hata oluştu"),
            RaisedButton(
              child: Text("Yeniden dene"),
              onPressed: () {
                _imagesBloc.add(GetImagesEvent());
              },
            ),
          ],
        ),
      ),
    );
  }

  Container buildCircularProgressIndicator() {
    return Container(
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Future<void> _getAndUploadImage(
      {ImageSource source,
      ImagesBloc imagesBloc,
      IsLoadingBloc isLoadingBloc}) async {
    final ImagePicker _imagePicker = ImagePicker();
    final PickedFile _pickedFile = await _imagePicker.getImage(
        source: source, maxHeight: 1024, maxWidth: 1024);
    if (_pickedFile != null) {
      imagesBloc.add(
        UploadImageEvent(
          isLoadingBloc: isLoadingBloc,
          context: context,
          file: File(_pickedFile.path),
          uploaderName: _userProviderLF.name,
        ),
      );
    }

    return;
  }
}
