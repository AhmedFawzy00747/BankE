import '../repositories/card_repository.dart';

class GenerateVirtualCardUseCase {
  final CardRepository repository;

  GenerateVirtualCardUseCase(this.repository);

  Future<void> execute(String accountId, String cardHolderName) {
    return repository.generateVirtualCard(accountId, cardHolderName);
  }
}
