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
      spendLimit: 2500.0,
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
      spendLimit: 5000.0,
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

  @override
  Future<void> updateCardLimit(String cardId, double newLimit) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _cards.indexWhere((c) => c.id == cardId);
    if (index != -1) {
      _cards[index] = _cards[index].copyWith(spendLimit: newLimit);
    }
  }

  @override
  Future<void> changeCardPin(String cardId, String newPin) async {
    await Future.delayed(const Duration(seconds: 1));
    // In a real app, this would update the PIN securely
  }

  @override
  Future<void> generateVirtualCard(String accountId, String cardHolderName) async {
    await Future.delayed(const Duration(seconds: 2));
    final newCard = CardEntity(
      id: 'card_v_${DateTime.now().millisecondsSinceEpoch}',
      cardNumber: '4242${(100000000000 + DateTime.now().millisecondsSinceEpoch % 1000000000000).toString()}',
      cardHolderName: cardHolderName,
      expiryDate: '08/29',
      cvv: '999',
      isFrozen: false,
      isVirtual: true,
      cardType: 'Debit',
      spendLimit: 500.0,
    );
    _cards.add(newCard);
  }
}
