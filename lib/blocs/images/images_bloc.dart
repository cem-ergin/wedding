import 'dart:async';
import 'dart:io';

import 'package:aycacem/blocs/is_loading/is_loading_bloc.dart';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eralpsoftware/eralpsoftware.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:uuid/uuid.dart';

part 'images_event.dart';
part 'images_state.dart';

class ImagesBloc extends Bloc<ImagesEvent, ImagesState> {
  ImagesBloc() : super(ImagesInitialState());

  @override
  Stream<ImagesState> mapEventToState(
    ImagesEvent event,
  ) async* {
    if (event is GetImagesEvent) {
      yield ImagesLoadingState();
      try {
        final firestoreInstance = Firestore.instance;
        final _querySnapshot = await firestoreInstance
            .collection("images")
            .orderBy("createdAt")
            .getDocuments();
        yield ImagesLoadedState(querySnapshot: _querySnapshot);
      } catch (e) {
        yield ImagesErrorState(error: e.toString());
      }
    }
    if (event is UploadImageEvent) {
      event.isLoadingBloc.add(LoadingEvent());
      try {
        // final String _fileId = Uuid().v4();
        String _imageName = event.file.path.split("/").last;
        print("image name: $_imageName");
        if (_imageName == null && _imageName.length < 5) {
          _imageName = Uuid().v4();
        }
        final StorageReference _firebaseStorageReference =
            FirebaseStorage.instance.ref().child(_imageName);
        final StorageUploadTask _task =
            _firebaseStorageReference.putFile(event.file);
        // _startProgress(10);
        final StorageReference _uploadedRef = (await _task.onComplete).ref;
        var dowurl = await _uploadedRef.getDownloadURL();
        var mimeType = await _uploadedRef.getMetadata();
        print("download url: $dowurl");
        print("mimeType: ${mimeType.contentType}");

        final databaseReference = Firestore.instance;
        await databaseReference.collection("images").add({
          'imageUrl': dowurl,
          'uploaderName': event.uploaderName,
          'createdAt': DateTime.now().millisecondsSinceEpoch.toString(),
          'contentType': mimeType.contentType,
        });
        final firestoreInstance = Firestore.instance;
        final _querySnapshot = await firestoreInstance
            .collection("images")
            .orderBy("createdAt")
            .getDocuments();
        yield ImagesLoadedState(querySnapshot: _querySnapshot);
        _stopProgress();
        event.isLoadingBloc.add(LoadedEvent());
      } on Exception catch (e) {
        print(e);
        _stopProgress();
        event.isLoadingBloc.add(LoadedEvent());
        yield ImagesErrorState(error: e.toString());
        Eralp.showSnackBar(
          snackBar: SnackBar(
            content: Text(
              "Yükleme başarısız oldu",
              style: TextStyle(color: Theme.of(event.context).errorColor),
            ),
          ),
        );
      }
    }
  }

  void _startProgress(int maxSecond) {
    Eralp.startProgress(
      maxSecond: maxSecond,
      child: Stack(
        children: <Widget>[
          // Center(child: Image.asset("assets/images/pp.jpeg")),
          Center(
            child: CircularProgressIndicator(),
          ),
        ],
      ),
    );
  }

  void _stopProgress() {
    Eralp.stopProgress();
  }
}
