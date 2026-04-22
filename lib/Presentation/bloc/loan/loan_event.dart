import 'package:equatable/equatable.dart';

abstract class LoanEvent extends Equatable {
  const LoanEvent();
  @override
  List<Object?> get props => [];
}

class SubmitLoanRequestEvent extends LoanEvent {
  final double amount;
  final String purpose;
  final int durationMonths;
  final String pdfFileName;
  final String userId;
  final String userName;

  const SubmitLoanRequestEvent({
    required this.amount,
    required this.purpose,
    required this.durationMonths,
    required this.pdfFileName,
    required this.userId,
    required this.userName,
  });

  @override
  List<Object?> get props => [amount, purpose, durationMonths, pdfFileName, userId, userName];
}
