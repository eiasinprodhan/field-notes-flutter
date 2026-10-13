import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
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

class UpdateThemeMode extends SettingsEvent {
  final ThemeMode themeMode;
  const UpdateThemeMode(this.themeMode);
  @override
  List<Object?> get props => [themeMode];
}

abstract class SettingsState extends Equatable {
  const SettingsState();
  @override
  List<Object?> get props => [];
}

class SettingsLoaded extends SettingsState {
  final String defaultStatus;
  final String? lastSyncTime;
  final ThemeMode themeMode;

  const SettingsLoaded({
    required this.defaultStatus,
    this.lastSyncTime,
    this.themeMode = ThemeMode.system,
  });

  @override
  List<Object?> get props => [defaultStatus, lastSyncTime, themeMode];
}

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SettingsStorage _storage;

  static ThemeMode _parseThemeMode(String val) {
    if (val == 'light') return ThemeMode.light;
    if (val == 'dark') return ThemeMode.dark;
    return ThemeMode.system;
  }

  static String _themeModeToString(ThemeMode mode) {
    if (mode == ThemeMode.light) return 'light';
    if (mode == ThemeMode.dark) return 'dark';
    return 'system';
  }

  SettingsBloc(this._storage)
      : super(SettingsLoaded(
          defaultStatus: _storage.getDefaultNoteStatus(),
          lastSyncTime: _storage.getLastSyncTime(),
          themeMode: _parseThemeMode(_storage.getThemeMode()),
        )) {
    on<LoadSettings>((event, emit) {
      emit(SettingsLoaded(
        defaultStatus: _storage.getDefaultNoteStatus(),
        lastSyncTime: _storage.getLastSyncTime(),
        themeMode: _parseThemeMode(_storage.getThemeMode()),
      ));
    });

    on<UpdateDefaultStatus>((event, emit) async {
      await _storage.setDefaultNoteStatus(event.status);
      emit(SettingsLoaded(
        defaultStatus: event.status,
        lastSyncTime: _storage.getLastSyncTime(),
        themeMode: state is SettingsLoaded
            ? (state as SettingsLoaded).themeMode
            : _parseThemeMode(_storage.getThemeMode()),
      ));
    });

    on<UpdateThemeMode>((event, emit) async {
      await _storage.setThemeMode(_themeModeToString(event.themeMode));
      emit(SettingsLoaded(
        defaultStatus: _storage.getDefaultNoteStatus(),
        lastSyncTime: _storage.getLastSyncTime(),
        themeMode: event.themeMode,
      ));
    });
  }
}
