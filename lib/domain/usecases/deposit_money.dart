import '../repositories/account_repository.dart';

class DepositMoneyUseCase {
  final AccountRepository repository;
  DepositMoneyUseCase(this.repository);

  Future<void> execute(String accountId, double amount) async {
    if (amount <= 0) throw Exception('Amount must be greater than zero');
    return await repository.deposit(accountId, amount);
  }
}
