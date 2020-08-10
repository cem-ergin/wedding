part of 'images_bloc.dart';

@immutable
abstract class ImagesState {}

class ImagesInitialState extends ImagesState {}

class ImagesLoadingState extends ImagesState {}

class ImagesLoadedState extends ImagesState {
  final QuerySnapshot querySnapshot;
  ImagesLoadedState({@required this.querySnapshot});
}

class ImagesErrorState extends ImagesState {
  final String error;
  ImagesErrorState({@required this.error});
}
