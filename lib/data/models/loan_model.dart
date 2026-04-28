import '../../domain/entities/loan_entity.dart';

export '../../domain/entities/loan_entity.dart' show LoanStatus;

class LoanModel extends LoanEntity {
  const LoanModel({
    required super.id,
    required super.userId,
    required super.userName,
    required super.amount,
    required super.purpose,
    required super.durationMonths,
    required super.pdfFileName,
    super.pdfFilePath,
    super.status = LoanStatus.pending,
  });

  LoanModel copyWith({LoanStatus? status}) {
    return LoanModel(
      id: id,
      userId: userId,
      userName: userName,
      amount: amount,
      purpose: purpose,
      durationMonths: durationMonths,
      pdfFileName: pdfFileName,
      pdfFilePath: pdfFilePath,
      status: status ?? this.status,
    );
  }
}
