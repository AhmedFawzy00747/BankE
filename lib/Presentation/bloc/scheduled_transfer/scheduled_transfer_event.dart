import 'package:equatable/equatable.dart';
import '../../../domain/entities/scheduled_transfer.dart';

abstract class ScheduledTransferEvent extends Equatable {
  const ScheduledTransferEvent();

  @override
  List<Object?> get props => [];
}

class LoadScheduledTransfers extends ScheduledTransferEvent {
  final String accountId;
  const LoadScheduledTransfers(this.accountId);

  @override
  List<Object?> get props => [accountId];
}

class ScheduleNewTransfer extends ScheduledTransferEvent {
  final ScheduledTransferEntity transfer;
  const ScheduleNewTransfer(this.transfer);

  @override
  List<Object?> get props => [transfer];
}

class CancelTransfer extends ScheduledTransferEvent {
  final String transferId;
  final String accountId; 
  const CancelTransfer(this.transferId, this.accountId);

  @override
  List<Object?> get props => [transferId, accountId];
}
