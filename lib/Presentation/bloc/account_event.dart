import 'package:equatable/equatable.dart';

abstract class AccountEvent extends Equatable {
  const AccountEvent();

  @override
  List<Object?> get props => [];
}

class FetchAccountBalance extends AccountEvent {
  final String accountId;
  const FetchAccountBalance(this.accountId);

  @override
  List<Object?> get props => [accountId];
}

class LoadUserAccounts extends AccountEvent {
  final String userId;
  const LoadUserAccounts(this.userId);

  @override
  List<Object?> get props => [userId];
}

class SwitchAccount extends AccountEvent {
  final String accountId;
  const SwitchAccount(this.accountId);

  @override
  List<Object?> get props => [accountId];
}
