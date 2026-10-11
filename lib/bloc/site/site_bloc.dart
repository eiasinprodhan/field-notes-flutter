import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/field_repository.dart';
import '../../models/site.dart';

abstract class SiteEvent extends Equatable {
  const SiteEvent();
  @override
  List<Object?> get props => [];
}

class LoadSites extends SiteEvent {
  final String? customerUuid;
  const LoadSites({this.customerUuid});
  @override
  List<Object?> get props => [customerUuid];
}

class CreateSite extends SiteEvent {
  final String customerUuid;
  final String siteName;
  final String? address;
  const CreateSite({required this.customerUuid, required this.siteName, this.address});
  @override
  List<Object?> get props => [customerUuid, siteName, address];
}

class UpdateSite extends SiteEvent {
  final Site site;
  const UpdateSite(this.site);
  @override
  List<Object?> get props => [site];
}

class DeleteSite extends SiteEvent {
  final String uuid;
  final String? customerUuid;
  const DeleteSite(this.uuid, {this.customerUuid});
  @override
  List<Object?> get props => [uuid, customerUuid];
}

abstract class SiteState extends Equatable {
  const SiteState();
  @override
  List<Object?> get props => [];
}

class SiteInitial extends SiteState {}

class SiteLoading extends SiteState {}

class SiteLoaded extends SiteState {
  final List<Site> sites;
  const SiteLoaded(this.sites);
  @override
  List<Object?> get props => [sites];
}

class SiteError extends SiteState {
  final String message;
  const SiteError(this.message);
  @override
  List<Object?> get props => [message];
}

class SiteBloc extends Bloc<SiteEvent, SiteState> {
  final FieldRepository _repo;

  SiteBloc(this._repo) : super(SiteInitial()) {
    on<LoadSites>((event, emit) async {
      emit(SiteLoading());
      try {
        final sites = await _repo.getSites(customerUuid: event.customerUuid);
        emit(SiteLoaded(sites));
      } catch (e) {
        emit(SiteError(e.toString()));
      }
    });

    on<CreateSite>((event, emit) async {
      try {
        await _repo.createSite(
          customerUuid: event.customerUuid,
          siteName: event.siteName,
          address: event.address,
        );
        final sites = await _repo.getSites(customerUuid: event.customerUuid);
        emit(SiteLoaded(sites));
      } catch (e) {
        emit(SiteError(e.toString()));
      }
    });

    on<UpdateSite>((event, emit) async {
      try {
        await _repo.updateSite(event.site);
        final sites = await _repo.getSites(customerUuid: event.site.customerUuid);
        emit(SiteLoaded(sites));
      } catch (e) {
        emit(SiteError(e.toString()));
      }
    });

    on<DeleteSite>((event, emit) async {
      try {
        await _repo.deleteSite(event.uuid);
        final sites = await _repo.getSites(customerUuid: event.customerUuid);
        emit(SiteLoaded(sites));
      } catch (e) {
        emit(SiteError(e.toString()));
      }
    });
  }
}
