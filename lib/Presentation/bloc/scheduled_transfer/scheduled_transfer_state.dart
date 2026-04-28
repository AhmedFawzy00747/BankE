import 'package:equatable/equatable.dart';
import '../../../domain/entities/scheduled_transfer.dart';

abstract class ScheduledTransferState extends Equatable {
  const ScheduledTransferState();
  
  @override
  List<Object?> get props => [];
}

class ScheduledTransferInitial extends ScheduledTransferState {}

class ScheduledTransferLoading extends ScheduledTransferState {}

class ScheduledTransferLoaded extends ScheduledTransferState {
  final List<ScheduledTransferEntity> transfers;

  const ScheduledTransferLoaded(this.transfers);

  @override
  List<Object?> get props => [transfers];
}

class ScheduledTransferOperationSuccess extends ScheduledTransferState {
  final String message;
  const ScheduledTransferOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class ScheduledTransferError extends ScheduledTransferState {
  final String message;

  const ScheduledTransferError(this.message);

  @override
  List<Object?> get props => [message];
}
