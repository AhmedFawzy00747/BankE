import '../entities/loan_entity.dart';

abstract class LoanRepository {
  Future<List<LoanEntity>> getAllLoans();
  Future<List<LoanEntity>> getUserLoans(String userId);
  Future<LoanEntity> submitLoanRequest({
    required String userId,
    required String userName,
    required double amount,
    required String purpose,
    required int duration,
    required String pdfName,
    required String pdfPath,
  });
  Future<void> updateLoanStatus(String loanId, LoanStatus status);
}
