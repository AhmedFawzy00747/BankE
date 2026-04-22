import 'package:equatable/equatable.dart';

abstract class TransferEvent extends Equatable {
  const TransferEvent();

  @override
  List<Object?> get props => [];
}

class InitiateTransfer extends TransferEvent {
  final String accountId;
  final String recipientAccount;
  final double amount;
  final String notes;

  const InitiateTransfer({
    required this.accountId,
    required this.recipientAccount,
    required this.amount,
    required this.notes,
  });

  @override
  List<Object?> get props => [accountId, recipientAccount, amount, notes];
}

class PayBillEvent extends TransferEvent {
  final String accountId;
  final String billerId;
  final String consumerId;
  final double amount;

  const PayBillEvent({
    required this.accountId,
    required this.billerId,
    required this.consumerId,
    required this.amount,
  });

  @override
  List<Object?> get props => [accountId, billerId, consumerId, amount];
}
class FetchBillers extends TransferEvent {}
