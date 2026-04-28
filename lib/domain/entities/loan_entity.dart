import 'package:equatable/equatable.dart';

enum LoanStatus { pending, approved, rejected }

class LoanEntity extends Equatable {
  final String id;
  final String userId;
  final String userName;
  final double amount;
  final String purpose;
  final int durationMonths;
  final String pdfFileName;
  final String? pdfFilePath;
  final LoanStatus status;

  const LoanEntity({
    required this.id,
    required this.userId,
    required this.userName,
    required this.amount,
    required this.purpose,
    required this.durationMonths,
    required this.pdfFileName,
    this.pdfFilePath,
    required this.status,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        userName,
        amount,
        purpose,
        durationMonths,
        pdfFileName,
        pdfFilePath,
        status,
      ];
}
