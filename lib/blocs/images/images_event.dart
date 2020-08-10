part of 'images_bloc.dart';

@immutable
abstract class ImagesEvent {}

class UploadImageEvent extends ImagesEvent {
  final IsLoadingBloc isLoadingBloc;
  final BuildContext context;
  final File file;
  final String uploaderName;
  UploadImageEvent({
    @required this.file,
    @required this.context,
    @required this.uploaderName,
    @required this.isLoadingBloc,
  });
}

class GetImagesEvent extends ImagesEvent {}
