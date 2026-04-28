import '../entities/loan_entity.dart';
import '../repositories/loan_repository.dart';

class SubmitLoanRequestUseCase {
  final LoanRepository repository;

  SubmitLoanRequestUseCase(this.repository);

  Future<LoanEntity> execute({
    required String userId,
    required String userName,
    required double amount,
    required String purpose,
    required int duration,
    required String pdfName,
    required String pdfPath,
  }) async {
    return await repository.submitLoanRequest(
      userId: userId,
      userName: userName,
      amount: amount,
      purpose: purpose,
      duration: duration,
      pdfName: pdfName,
      pdfPath: pdfPath,
    );
  }
}
