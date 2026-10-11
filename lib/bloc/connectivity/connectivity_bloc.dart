import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class ConnectivityEvent extends Equatable {
  const ConnectivityEvent();
  @override
  List<Object?> get props => [];
}

class ConnectivityStarted extends ConnectivityEvent {}

class ConnectivityChangedEvent extends ConnectivityEvent {
  final List<ConnectivityResult> results;
  const ConnectivityChangedEvent(this.results);
  @override
  List<Object?> get props => [results];
}

class ConnectivityState extends Equatable {
  final bool isOnline;
  const ConnectivityState({required this.isOnline});
  @override
  List<Object?> get props => [isOnline];
}

class ConnectivityBloc extends Bloc<ConnectivityEvent, ConnectivityState> {
  final Connectivity _connectivity;
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  ConnectivityBloc(this._connectivity) : super(const ConnectivityState(isOnline: true)) {
    on<ConnectivityStarted>((event, emit) async {
      await _subscription?.cancel();
      try {
        final initial = await _connectivity.checkConnectivity();
        final online = initial.any((r) => r != ConnectivityResult.none);
        emit(ConnectivityState(isOnline: online));
      } catch (_) {
        emit(const ConnectivityState(isOnline: true));
      }

      _subscription = _connectivity.onConnectivityChanged.listen((results) {
        add(ConnectivityChangedEvent(results));
      });
    });

    on<ConnectivityChangedEvent>((event, emit) {
      final online = event.results.any((r) => r != ConnectivityResult.none);
      emit(ConnectivityState(isOnline: online));
    });
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
