part of 'is_loading_bloc.dart';

@immutable
abstract class IsLoadingEvent {}

class LoadingEvent extends IsLoadingEvent {}

class LoadedEvent extends IsLoadingEvent {}
