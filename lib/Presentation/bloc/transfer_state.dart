import 'package:equatable/equatable.dart';

import '../../domain/entities/biller.dart';

abstract class TransferState extends Equatable {
  const TransferState();

  @override
  List<Object?> get props => [];
}

class TransferInitial extends TransferState {}

class TransferLoading extends TransferState {}

class BillersLoaded extends TransferState {
  final List<BillerEntity> billers;
  const BillersLoaded(this.billers);

  @override
  List<Object?> get props => [billers];
}

class TransferSuccess extends TransferState {
  final double amount;
  final String recipientAccount;

  const TransferSuccess({required this.amount, required this.recipientAccount});

  @override
  List<Object?> get props => [amount, recipientAccount];
}

class TransferError extends TransferState {
  final String message;

  const TransferError(this.message);

  @override
  List<Object?> get props => [message];
}
