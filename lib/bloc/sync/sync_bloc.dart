import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/field_repository.dart';

abstract class SyncEvent extends Equatable {
  const SyncEvent();
  @override
  List<Object?> get props => [];
}

class SyncRequested extends SyncEvent {}

abstract class SyncState extends Equatable {
  const SyncState();
  @override
  List<Object?> get props => [];
}

class SyncInitial extends SyncState {}

class SyncInProgress extends SyncState {}

class SyncSuccess extends SyncState {
  final DateTime timestamp;
  const SyncSuccess(this.timestamp);
  @override
  List<Object?> get props => [timestamp];
}

class SyncFailure extends SyncState {
  final String message;
  const SyncFailure(this.message);
  @override
  List<Object?> get props => [message];
}

class SyncBloc extends Bloc<SyncEvent, SyncState> {
  final FieldRepository _repo;

  SyncBloc(this._repo) : super(SyncInitial()) {
    on<SyncRequested>((event, emit) async {
      emit(SyncInProgress());
      try {
        await _repo.sync();
        emit(SyncSuccess(DateTime.now()));
      } catch (e) {
        emit(SyncFailure(e.toString()));
      }
    });
  }
}
