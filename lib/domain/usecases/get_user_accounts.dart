import '../entities/account.dart';
import '../repositories/account_repository.dart';

class GetUserAccountsUseCase {
  final AccountRepository repository;

  GetUserAccountsUseCase(this.repository);

  Future<List<AccountEntity>> execute(String userId) async {
    return await repository.getUserAccounts(userId);
  }
}
