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
import 'package:image_picker/image_picker.dart';
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
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _isScrollEnd = true;
        print("scroll end");
        setState(() {});
      } else {
        _isScrollEnd = false;
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final ImagesBloc _imagesBloc = BlocProvider.of<ImagesBloc>(context);
    final IsLoadingBloc _isLoadingBloc =
        BlocProvider.of<IsLoadingBloc>(context);
    final Size _size = MediaQuery.of(context).size;
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
          listener: (BuildContext context, state) {
            if (state is IsLoadingLoadingState) {
              return Eralp.showSnackBar(
                snackBar: SnackBar(
                  content: Text("Resim yükleniyor"),
                ),
              );
            }
          },
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

            return GridView.builder(
              controller: _scrollController,
              addAutomaticKeepAlives: true,
              itemCount: _myDocs.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
              ),
              itemBuilder: (context, index) {
                return GridItem(image: _myDocs[index]);
              },
            );
          }
          if (_imagesState is ImagesErrorState) {
            return buildErrorState(_imagesBloc);
          }
        },
      ),
      floatingActionButton: !_isScrollEnd
          ? Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Container(
                  width: _size.width * 0.5,
                  child: FloatingActionButton.extended(
                    key: Key("1"),
                    heroTag: "1",
                    onPressed: () => _getAndUploadImage(
                        source: ImageSource.camera,
                        imagesBloc: _imagesBloc,
                        isLoadingBloc: _isLoadingBloc),
                    label: Text("Kameradan ekle"),
                    icon: Icon(Icons.camera_alt),
                  ),
                ),
                SizedBox(height: 8),
                Container(
                  width: _size.width * 0.5,
                  child: FloatingActionButton.extended(
                    key: Key("2"),
                    heroTag: "2",
                    onPressed: () => _getAndUploadImage(
                        source: ImageSource.gallery,
                        imagesBloc: _imagesBloc,
                        isLoadingBloc: _isLoadingBloc),
                    label: Text("Galeriden ekle"),
                    icon: Icon(Icons.photo_album),
                  ),
                ),
              ],
            )
          : Container(),
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
