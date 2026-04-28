import 'package:equatable/equatable.dart';
import '../../domain/entities/account.dart';

abstract class AccountState extends Equatable {
  const AccountState();
  
  @override
  List<Object?> get props => [];
}

class AccountInitial extends AccountState {}
class AccountLoading extends AccountState {}
class AccountLoaded extends AccountState {
  final AccountEntity account; // the currently active account
  final List<AccountEntity> allAccounts;

  const AccountLoaded(this.account, {this.allAccounts = const []});

  @override
  List<Object?> get props => [account, allAccounts];
}
class AccountError extends AccountState {
  final String message;

  const AccountError(this.message);

  @override
  List<Object?> get props => [message];
}
