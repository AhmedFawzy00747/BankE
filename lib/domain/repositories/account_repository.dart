import '../entities/account.dart';
import '../entities/transaction.dart';
import '../entities/biller.dart';

abstract class AccountRepository {
  Future<AccountEntity> getAccountDetails(String accountId);
  Future<List<AccountEntity>> getUserAccounts(String userId);
  Future<List<TransactionEntity>> getTransactions(String accountId);
  Future<void> performTransfer({
    required String senderId,
    required String recipientAccount,
    required double amount,
    required String notes,
  });
  Future<void> payBill({
    required String senderId,
    required String billerId,
    required String consumerId,
    required double amount,
  });
  Future<List<BillerEntity>> getBillers();
  Future<void> withdraw(String accountId, double amount);
  Future<void> deposit(String accountId, double amount);
}
