import '../../domain/entities/card_entity.dart';
import '../../domain/repositories/card_repository.dart';

class CardRepositoryImpl implements CardRepository {
  // Mock data in memory
  final List<CardEntity> _cards = [
    CardEntity(
      id: 'card_1',
      cardNumber: '4111111111111111',
      cardHolderName: 'John Doe',
      expiryDate: '12/26',
      cvv: '123',
      isFrozen: false,
      isVirtual: false,
      cardType: 'Debit',
    ),
    CardEntity(
      id: 'card_2',
      cardNumber: '5555555555554444',
      cardHolderName: 'John Doe',
      expiryDate: '10/25',
      cvv: '456',
      isFrozen: true,
      isVirtual: true,
      cardType: 'Credit',
    ),
  ];

  @override
  Future<List<CardEntity>> getCards(String accountId) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return _cards.toList();
  }

  @override
  Future<void> addCard(String accountId, CardEntity card) async {
    await Future.delayed(const Duration(milliseconds: 800));
    _cards.add(card);
  }

  @override
  Future<void> freezeCard(String cardId, bool freeze) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _cards.indexWhere((c) => c.id == cardId);
    if (index != -1) {
      _cards[index] = _cards[index].copyWith(isFrozen: freeze);
    }
  }

  @override
  Future<void> deleteCard(String cardId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _cards.removeWhere((c) => c.id == cardId);
  }
}
