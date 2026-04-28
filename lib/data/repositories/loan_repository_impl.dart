import 'dart:io';
import 'package:contr_project/data/datasources/account_data_source.dart';
import '../../domain/entities/loan_entity.dart';
import '../../domain/repositories/loan_repository.dart';

class LoanRepositoryImpl implements LoanRepository {
  final AccountDataSource dataSource;

  LoanRepositoryImpl(this.dataSource);

  @override
  Future<List<LoanEntity>> getAllLoans() async {
    print("[LoanRepo] getAllLoans called");
    try {
      final loans = await dataSource.fetchAllLoans();
      print("[LoanRepo] loans count: ${loans.length}");
      return loans; // Models are already entities
    } catch (e) {
      print("[LoanRepo] Error in getAllLoans: $e");
      return []; // Always return non-null list as requested
    }
  }

  @override
  Future<List<LoanEntity>> getUserLoans(String userId) async {
    print("[LoanRepo] getUserLoans called for $userId");
    try {
      final allLoans = await dataSource.fetchAllLoans();
      final userLoans = allLoans.where((loan) => loan.userId == userId).toList();
      return userLoans;
    } catch (e) {
      print("[LoanRepo] Error in getUserLoans: $e");
      return [];
    }
  }

  @override
  Future<LoanEntity> submitLoanRequest({
    required String userId,
    required String userName,
    required double amount,
    required String purpose,
    required int duration,
    required String pdfName,
    required String pdfPath,
  }) async {
    print("[LoanRepo] submitLoanRequest called for $userName");
    
    try {
      // 1. Safe File Handling
      if (pdfPath.isNotEmpty) {
        final file = File(pdfPath);
        if (!await file.exists()) {
          throw Exception("Supporting document file not found at $pdfPath");
        }
      } else {
        throw Exception("Invalid PDF path provided");
      }

      // 2. Simulate Upload Safely
      await Future.delayed(const Duration(milliseconds: 500));

      final loanModel = await dataSource.submitLoanRequest(
        userId,
        userName,
        amount,
        purpose,
        duration,
        pdfName,
        pdfPath,
      );

      print("[LoanRepo] Loan submitted successfully: ${loanModel.id}");
      return loanModel;
    } catch (e) {
      print("[LoanRepo] Error in submitLoanRequest: $e");
      throw Exception("LoanRepository error: $e");
    }
  }

  @override
  Future<void> updateLoanStatus(String loanId, LoanStatus status) async {
    print("[LoanRepo] updateLoanStatus called for $loanId to $status");
    try {
      final loans = await dataSource.fetchAllLoans();
      
      // Safe check for existence
      final loanExists = loans.any((l) => l.id == loanId);
      if (!loanExists) {
        throw Exception("Loan with ID $loanId not found");
      }

      await dataSource.updateLoanStatus(loanId, status);
      print("[LoanRepo] Loan status updated successfully");
    } catch (e) {
      print("[LoanRepo] Error in updateLoanStatus: $e");
      throw Exception("LoanRepository error: $e");
    }
  }
}
