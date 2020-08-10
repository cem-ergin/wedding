import 'dart:io';

import 'package:aycacem/blocs/images/images_bloc.dart';
import 'package:aycacem/blocs/is_loading/is_loading_bloc.dart';
import 'package:aycacem/pages/camera_page/camera_page.dart';
import 'package:aycacem/providers/user_provider.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class FrontCamera extends StatefulWidget {
  FrontCamera({Key key}) : super(key: key);

  @override
  _FrontCameraState createState() => _FrontCameraState();
}

class _FrontCameraState extends State<FrontCamera> {
  CameraController _controller;
  Future<void> _initializeControllerFuture;
  bool isCameraReady = false;
  bool showCapturedPhoto = false;
  final List<File> _images = [];
  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _controller != null
          ? _initializeControllerFuture = _controller.initialize()
          : null; //on pause camera is disposed, so we need to call again "issue is only for android"
    }
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.last;
    _controller = CameraController(firstCamera, ResolutionPreset.veryHigh);
    _initializeControllerFuture = _controller.initialize();
    if (!mounted) {
      return;
    }
    setState(() {
      isCameraReady = true;
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final deviceRatio = size.width / size.height;
    final IsLoadingBloc _isLoadingBloc =
        BlocProvider.of<IsLoadingBloc>(context);

    return Scaffold(
      // appBar: AppBar(
      //   actions: <Widget>[],
      // ),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
              children: <Widget>[
                Transform.scale(
                  scale: _controller.value.aspectRatio / deviceRatio,
                  child: Center(
                    child: AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: CameraPreview(_controller), //cameraPreview
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 32.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        BlocConsumer(
                          cubit: _isLoadingBloc,
                          builder: (context, state) {
                            if (state is IsLoadingLoadingState) {
                              return _images.length > 0
                                  ? Padding(
                                      padding: const EdgeInsets.only(left: 8.0),
                                      child: Stack(
                                        children: <Widget>[
                                          Opacity(
                                            opacity: 0.75,
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: <Widget>[
                                                ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          16.0),
                                                  child: Container(
                                                    height: size.height * 0.2,
                                                    width: size.width * 0.3,
                                                    child: Image(
                                                      image: FileImage(
                                                        _images[
                                                            _images.length - 1],
                                                      ),
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: <Widget>[
                                              Center(
                                                  child: Padding(
                                                padding: EdgeInsets.only(
                                                  left: size.width * 0.115,
                                                  bottom: size.height * 0.08,
                                                ),
                                                child:
                                                    CircularProgressIndicator(),
                                              ))
                                            ],
                                          ),
                                        ],
                                      ),
                                    )
                                  : Expanded(
                                      child: Container(child: Text("")),
                                    );
                            }
                            return _images.length > 0
                                ? Expanded(
                                    child: InkWell(
                                      onTap: () {
                                        BlocProvider.of<ImagesBloc>(context)
                                            .add(GetImagesEvent());

                                        Navigator.pop(context);
                                      },
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: <Widget>[
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(16.0),
                                            child: Container(
                                              height: size.height * 0.2,
                                              width: size.width * 0.3,
                                              child: Image(
                                                image: FileImage(
                                                  _images[_images.length - 1],
                                                ),
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                : Expanded(
                                    child: Container(child: Text("")),
                                  );
                          },
                          listener: (BuildContext context, state) {},
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 10.0),
                            child: IconButton(
                              onPressed: () {
                                onCaptureButtonPressed(_isLoadingBloc);
                              },
                              icon: Icon(
                                Icons.camera,
                                color: Colors.white,
                                size: size.width * 0.12,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 10.0),
                            child: IconButton(
                              onPressed: () {
                                _controller?.dispose();

                                Navigator.popUntil(context, (r) => r.isFirst);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => CameraPage(),
                                  ),
                                );
                              },
                              icon: Icon(
                                Icons.camera_front,
                                color: Colors.white,
                                size: size.width * 0.12,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: MediaQuery.of(context).padding.top,
                  right: 16,
                  child: IconButton(
                    icon: Icon(
                      Icons.check,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      BlocProvider.of<ImagesBloc>(context)
                          .add(GetImagesEvent());

                      Navigator.pop(context);
                    },
                  ),
                ),
                Positioned(
                  top: MediaQuery.of(context).padding.top,
                  left: 16,
                  child: IconButton(
                    icon: Icon(
                      Icons.close,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      BlocProvider.of<ImagesBloc>(context)
                          .add(GetImagesEvent());

                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            );
          } else {
            return Center(
                child:
                    CircularProgressIndicator()); // Otherwise, display a loading indicator.
          }
        },
      ),
    );
  }

  void onCaptureButtonPressed(IsLoadingBloc isLoadingBloc) async {
    try {
      final path = "${(await getTemporaryDirectory()).path}+${Uuid().v4()}.png";
      await _controller.takePicture(path); //take photo
      _images.add(File(path));
      GallerySaver.saveImage(path);

      BlocProvider.of<ImagesBloc>(context).add(
        UploadImageEvent(
          file: File(path),
          isLoadingBloc: isLoadingBloc,
          uploaderName: Provider.of<UserProvider>(context, listen: false).name,
          context: context,
        ),
      );

      setState(() {});
      print("images eklendi: $path");
    } catch (e) {
      print(e);
    }
  }
}
