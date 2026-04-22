import 'package:equatable/equatable.dart';

abstract class AdminEvent extends Equatable {
  const AdminEvent();

  @override
  List<Object?> get props => [];
}

class FetchAllUsersEvent extends AdminEvent {}

class BlockUserEvent extends AdminEvent {
  final String userId;

  const BlockUserEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}

class UnblockUserEvent extends AdminEvent {
  final String userId;

  const UnblockUserEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}

class AdjustBalanceEvent extends AdminEvent {
  final String userId;
  final double amount;

  const AdjustBalanceEvent(this.userId, this.amount);

  @override
  List<Object?> get props => [userId, amount];
}

class UpdateLoanStatusEvent extends AdminEvent {
  final String loanId;
  final bool isApproved;

  const UpdateLoanStatusEvent(this.loanId, this.isApproved);

  @override
  List<Object?> get props => [loanId, isApproved];
}

class LogoutAdminEvent extends AdminEvent {}
