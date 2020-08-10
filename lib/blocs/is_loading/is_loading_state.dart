part of 'is_loading_bloc.dart';

@immutable
abstract class IsLoadingState {}

class IsLoadingLoadedState extends IsLoadingState {}

class IsLoadingLoadingState extends IsLoadingState {}
