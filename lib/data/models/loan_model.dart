enum LoanStatus { pending, approved, rejected }

class LoanModel {
  final String id;
  final String userId;
  final String userName;
  final double amount;
  final String purpose;
  final int durationMonths;
  final String pdfFileName;
  final LoanStatus status;

  const LoanModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.amount,
    required this.purpose,
    required this.durationMonths,
    required this.pdfFileName,
    this.status = LoanStatus.pending,
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
      status: status ?? this.status,
    );
  }
}
