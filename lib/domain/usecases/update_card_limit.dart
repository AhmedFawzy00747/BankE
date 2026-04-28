import '../repositories/card_repository.dart';

class UpdateCardLimitUseCase {
  final CardRepository repository;

  UpdateCardLimitUseCase(this.repository);

  Future<void> execute(String cardId, double newLimit) {
    return repository.updateCardLimit(cardId, newLimit);
  }
}
