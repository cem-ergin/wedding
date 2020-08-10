import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'is_loading_event.dart';
part 'is_loading_state.dart';

class IsLoadingBloc extends Bloc<IsLoadingEvent, IsLoadingState> {
  IsLoadingBloc() : super(IsLoadingLoadedState());

  @override
  Stream<IsLoadingState> mapEventToState(
    IsLoadingEvent event,
  ) async* {
    if (event is LoadingEvent) {
      yield IsLoadingLoadingState();
    }
    if (event is LoadedEvent) {
      yield IsLoadingLoadedState();
    }
  }
}
