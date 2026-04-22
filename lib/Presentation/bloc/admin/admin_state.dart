import 'package:equatable/equatable.dart';
import '../../../../data/models/admin_user_model.dart';
import '../../../../data/models/transaction_model.dart';
import '../../../../data/models/loan_model.dart';

abstract class AdminState extends Equatable {
  const AdminState();
  
  @override
  List<Object?> get props => [];
}

class AdminInitial extends AdminState {}

class AdminLoading extends AdminState {}

class AdminLoaded extends AdminState {
  final List<AdminUserModel> users;
  final List<TransactionModel> transactions;
  final List<LoanModel> loans;
  final double totalLiquidity;
  
  const AdminLoaded(this.users, this.transactions, this.loans, this.totalLiquidity);

  @override
  List<Object?> get props => [users, transactions, loans, totalLiquidity];
}

class AdminActionSuccess extends AdminState {
  final String message;
  
  const AdminActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class AdminError extends AdminState {
  final String message;

  const AdminError(this.message);

  @override
  List<Object?> get props => [message];
}
