import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CameraProvider extends ChangeNotifier {
  CameraProvider() {
    getCameras();
  }
  List<CameraDescription> _cameras;
  List<CameraDescription> get cameras => _cameras;

  Future<List<CameraDescription>> getCameras() async {
    _cameras = await availableCameras();
    return _cameras;
  }
}
