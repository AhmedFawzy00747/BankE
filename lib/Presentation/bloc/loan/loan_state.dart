import 'package:equatable/equatable.dart';

abstract class LoanState extends Equatable {
  const LoanState();
  @override
  List<Object?> get props => [];
}

class LoanInitial extends LoanState {}
class LoanSubmitting extends LoanState {}
class LoanSubmitSuccess extends LoanState {
  final String message;
  const LoanSubmitSuccess(this.message);
  @override
  List<Object?> get props => [message];
}
class LoanSubmitError extends LoanState {
  final String error;
  const LoanSubmitError(this.error);
  @override
  List<Object?> get props => [error];
}
