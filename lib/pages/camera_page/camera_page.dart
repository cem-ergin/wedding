import 'dart:io';

import 'package:aycacem/pages/home_page/gallery_photo_detail/simple_photo_detail.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class CameraPage extends StatefulWidget {
  CameraPage({Key key}) : super(key: key);

  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  CameraController _controller;
  Future<void> _initializeControllerFuture;
  bool isCameraReady = false;
  bool showCapturedPhoto = false;
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
    final firstCamera = cameras.first;
    _controller = CameraController(firstCamera, ResolutionPreset.high);
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
    return Scaffold(
      appBar: AppBar(
        title: Text("AppBarTitle"),
      ),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // If the Future is complete, display the preview.
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
                  child: IconButton(
                    onPressed: () {
                      onCaptureButtonPressed();
                    },
                    icon: Icon(
                      Icons.camera,
                      color: Colors.white,
                    ),
                  ),
                )
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

  void onCaptureButtonPressed() async {
    try {
      final path = "${(await getTemporaryDirectory()).path}+${Uuid().v4()}";
      await _controller.takePicture(path); //take photo
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => SimplePhotoDetail(image: File(path))));
    } catch (e) {
      print(e);
    }
  }
}
