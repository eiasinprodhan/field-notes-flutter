import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/field_repository.dart';
import '../../models/field_note.dart';
import '../../models/note_status.dart';

abstract class NoteEvent extends Equatable {
  const NoteEvent();
  @override
  List<Object?> get props => [];
}

class LoadNotes extends NoteEvent {
  final String? search;
  final NoteStatus? status;
  final String? siteUuid;

  const LoadNotes({this.search, this.status, this.siteUuid});

  @override
  List<Object?> get props => [search, status, siteUuid];
}

class CreateNoteEvent extends NoteEvent {
  final String siteUuid;
  final String title;
  final String? description;
  final String? location;
  final DateTime? dateTime;
  final NoteStatus? status;
  final File? photoFile;

  const CreateNoteEvent({
    required this.siteUuid,
    required this.title,
    this.description,
    this.location,
    this.dateTime,
    this.status,
    this.photoFile,
  });

  @override
  List<Object?> get props => [siteUuid, title, description, location, dateTime, status, photoFile];
}

class UpdateNoteEvent extends NoteEvent {
  final FieldNote note;
  final File? newPhotoFile;

  const UpdateNoteEvent(this.note, {this.newPhotoFile});

  @override
  List<Object?> get props => [note, newPhotoFile];
}

class DeleteNoteEvent extends NoteEvent {
  final String uuid;
  const DeleteNoteEvent(this.uuid);
  @override
  List<Object?> get props => [uuid];
}

abstract class NoteState extends Equatable {
  const NoteState();
  @override
  List<Object?> get props => [];
}

class NoteInitial extends NoteState {}

class NoteLoading extends NoteState {}

class NoteLoaded extends NoteState {
  final List<FieldNote> notes;
  final String? search;
  final NoteStatus? status;
  final String? siteUuid;

  const NoteLoaded({
    required this.notes,
    this.search,
    this.status,
    this.siteUuid,
  });

  @override
  List<Object?> get props => [notes, search, status, siteUuid];
}

class NoteError extends NoteState {
  final String message;
  const NoteError(this.message);
  @override
  List<Object?> get props => [message];
}

class NoteBloc extends Bloc<NoteEvent, NoteState> {
  final FieldRepository _repo;

  String? _lastSearch;
  NoteStatus? _lastStatus;
  String? _lastSiteUuid;

  NoteBloc(this._repo) : super(NoteInitial()) {
    on<LoadNotes>((event, emit) async {
      _lastSearch = event.search;
      _lastStatus = event.status;
      _lastSiteUuid = event.siteUuid;

      emit(NoteLoading());
      try {
        final notes = await _repo.getNotes(
          search: event.search,
          status: event.status,
          siteUuid: event.siteUuid,
        );
        emit(NoteLoaded(
          notes: notes,
          search: event.search,
          status: event.status,
          siteUuid: event.siteUuid,
        ));
      } catch (e) {
        emit(NoteError(e.toString()));
      }
    });

    on<CreateNoteEvent>((event, emit) async {
      try {
        String? photoUrl;
        if (event.photoFile != null) {
          try {
            photoUrl = await _repo.uploadPhoto(event.photoFile!);
          } catch (_) {
            
            photoUrl = event.photoFile!.path;
          }
        }

        await _repo.createNote(
          siteUuid: event.siteUuid,
          title: event.title,
          description: event.description,
          location: event.location,
          dateTime: event.dateTime,
          status: event.status,
          photoUrl: photoUrl,
        );

        final notes = await _repo.getNotes(
          search: _lastSearch,
          status: _lastStatus,
          siteUuid: _lastSiteUuid,
        );
        emit(NoteLoaded(
          notes: notes,
          search: _lastSearch,
          status: _lastStatus,
          siteUuid: _lastSiteUuid,
        ));
      } catch (e) {
        emit(NoteError(e.toString()));
      }
    });

    on<UpdateNoteEvent>((event, emit) async {
      try {
        FieldNote noteToSave = event.note;
        if (event.newPhotoFile != null) {
          try {
            final photoUrl = await _repo.uploadPhoto(event.newPhotoFile!);
            noteToSave = noteToSave.copyWith(photoUrl: photoUrl);
          } catch (_) {
            noteToSave = noteToSave.copyWith(photoUrl: event.newPhotoFile!.path);
          }
        }

        await _repo.updateNote(noteToSave);
        final notes = await _repo.getNotes(
          search: _lastSearch,
          status: _lastStatus,
          siteUuid: _lastSiteUuid,
        );
        emit(NoteLoaded(
          notes: notes,
          search: _lastSearch,
          status: _lastStatus,
          siteUuid: _lastSiteUuid,
        ));
      } catch (e) {
        emit(NoteError(e.toString()));
      }
    });

    on<DeleteNoteEvent>((event, emit) async {
      try {
        await _repo.deleteNote(event.uuid);
        final notes = await _repo.getNotes(
          search: _lastSearch,
          status: _lastStatus,
          siteUuid: _lastSiteUuid,
        );
        emit(NoteLoaded(
          notes: notes,
          search: _lastSearch,
          status: _lastStatus,
          siteUuid: _lastSiteUuid,
        ));
      } catch (e) {
        emit(NoteError(e.toString()));
      }
    });
  }
}
