import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/field_repository.dart';
import '../../models/customer.dart';

abstract class CustomerEvent extends Equatable {
  const CustomerEvent();
  @override
  List<Object?> get props => [];
}

class LoadCustomers extends CustomerEvent {}

class CreateCustomer extends CustomerEvent {
  final String name;
  final String? contactInfo;
  const CreateCustomer({required this.name, this.contactInfo});
  @override
  List<Object?> get props => [name, contactInfo];
}

class UpdateCustomer extends CustomerEvent {
  final Customer customer;
  const UpdateCustomer(this.customer);
  @override
  List<Object?> get props => [customer];
}

class DeleteCustomer extends CustomerEvent {
  final String uuid;
  const DeleteCustomer(this.uuid);
  @override
  List<Object?> get props => [uuid];
}

abstract class CustomerState extends Equatable {
  const CustomerState();
  @override
  List<Object?> get props => [];
}

class CustomerInitial extends CustomerState {}

class CustomerLoading extends CustomerState {}

class CustomerLoaded extends CustomerState {
  final List<Customer> customers;
  const CustomerLoaded(this.customers);
  @override
  List<Object?> get props => [customers];
}

class CustomerError extends CustomerState {
  final String message;
  const CustomerError(this.message);
  @override
  List<Object?> get props => [message];
}

class CustomerBloc extends Bloc<CustomerEvent, CustomerState> {
  final FieldRepository _repo;

  CustomerBloc(this._repo) : super(CustomerInitial()) {
    on<LoadCustomers>((event, emit) async {
      emit(CustomerLoading());
      try {
        final customers = await _repo.getCustomers();
        emit(CustomerLoaded(customers));
      } catch (e) {
        emit(CustomerError(e.toString()));
      }
    });

    on<CreateCustomer>((event, emit) async {
      try {
        await _repo.createCustomer(name: event.name, contactInfo: event.contactInfo);
        final customers = await _repo.getCustomers();
        emit(CustomerLoaded(customers));
      } catch (e) {
        emit(CustomerError(e.toString()));
      }
    });

    on<UpdateCustomer>((event, emit) async {
      try {
        await _repo.updateCustomer(event.customer);
        final customers = await _repo.getCustomers();
        emit(CustomerLoaded(customers));
      } catch (e) {
        emit(CustomerError(e.toString()));
      }
    });

    on<DeleteCustomer>((event, emit) async {
      try {
        await _repo.deleteCustomer(event.uuid);
        final customers = await _repo.getCustomers();
        emit(CustomerLoaded(customers));
      } catch (e) {
        emit(CustomerError(e.toString()));
      }
    });
  }
}
