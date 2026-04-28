import 'package:equatable/equatable.dart';
import '../../../../domain/entities/loan_entity.dart';

abstract class LoanEvent extends Equatable {
  const LoanEvent();
  @override
  List<Object?> get props => [];
}

class CalculateEMIEvent extends LoanEvent {
  final double amount;
  final int durationMonths;
  final double annualRate;

  const CalculateEMIEvent({
    required this.amount,
    required this.durationMonths,
    this.annualRate = 5.0,
  });

  @override
  List<Object?> get props => [amount, durationMonths, annualRate];
}

class SubmitLoanRequestEvent extends LoanEvent {
  final double amount;
  final String purpose;
  final int durationMonths;
  final String pdfFileName;
  final String pdfFilePath;
  final String userId;
  final String userName;

  const SubmitLoanRequestEvent({
    required this.amount,
    required this.purpose,
    required this.durationMonths,
    required this.pdfFileName,
    required this.pdfFilePath,
    required this.userId,
    required this.userName,
  });

  @override
  List<Object?> get props => [
        amount,
        purpose,
        durationMonths,
        pdfFileName,
        pdfFilePath,
        userId,
        userName,
      ];
}

class FetchLoansEvent extends LoanEvent {
  const FetchLoansEvent();
}

class UpdateLoanStatusEvent extends LoanEvent {
  final String loanId;
  final LoanStatus status;

  const UpdateLoanStatusEvent(this.loanId, this.status);

  @override
  List<Object?> get props => [loanId, status];
}
