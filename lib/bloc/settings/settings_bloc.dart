import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/storage/settings_storage.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();
  @override
  List<Object?> get props => [];
}

class LoadSettings extends SettingsEvent {}

class UpdateDefaultStatus extends SettingsEvent {
  final String status;
  const UpdateDefaultStatus(this.status);
  @override
  List<Object?> get props => [status];
}

abstract class SettingsState extends Equatable {
  const SettingsState();
  @override
  List<Object?> get props => [];
}

class SettingsLoaded extends SettingsState {
  final String defaultStatus;
  final String? lastSyncTime;

  const SettingsLoaded({
    required this.defaultStatus,
    this.lastSyncTime,
  });

  @override
  List<Object?> get props => [defaultStatus, lastSyncTime];
}

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SettingsStorage _storage;

  SettingsBloc(this._storage)
      : super(SettingsLoaded(
          defaultStatus: _storage.getDefaultNoteStatus(),
          lastSyncTime: _storage.getLastSyncTime(),
        )) {
    on<LoadSettings>((event, emit) {
      emit(SettingsLoaded(
        defaultStatus: _storage.getDefaultNoteStatus(),
        lastSyncTime: _storage.getLastSyncTime(),
      ));
    });

    on<UpdateDefaultStatus>((event, emit) async {
      await _storage.setDefaultNoteStatus(event.status);
      emit(SettingsLoaded(
        defaultStatus: event.status,
        lastSyncTime: _storage.getLastSyncTime(),
      ));
    });
  }
}
