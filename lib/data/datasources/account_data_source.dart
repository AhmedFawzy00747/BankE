import '../models/account_model.dart';
import '../models/transaction_model.dart';
import '../models/admin_user_model.dart';
import '../models/loan_model.dart';
import '../../domain/entities/loan_entity.dart';

abstract class AccountDataSource {
  Future<void> init();
  Future<AccountModel> fetchAccountDetails(String accountId);
  Future<List<AccountModel>> fetchUserAccounts(String userId);
  Future<List<TransactionModel>> fetchTransactions(String accountId);
  Future<void> performTransfer(String senderId, String recipient, double amount, String notes);
  Future<void> payBill(String senderId, String billerId, String consumerId, double amount);
  void registerUser(String name, String email, String phone);
  
  // Admin methods
  Future<List<AdminUserModel>> fetchAllUsers();
  Future<void> blockUser(String userId);
  Future<void> unblockUser(String userId);
  Future<void> adjustBalance(String userId, double amount);
  Future<List<Map<String, dynamic>>> fetchBillers();

  // Loan methods
  Future<LoanModel> submitLoanRequest(String userId, String userName, double amount, String purpose, int duration, String pdfName, String pdfPath);
  Future<List<LoanModel>> fetchAllLoans();
  Future<void> updateLoanStatus(String loanId, LoanStatus status);
  
  // ATM methods
  Future<void> withdraw(String accountId, double amount);
  Future<void> deposit(String accountId, double amount);
  
  void reset();
}
