import '../../domain/entities/card_entity.dart';

class CardModel extends CardEntity {
  const CardModel({
    required super.id,
    required super.cardNumber,
    required super.cardHolderName,
    required super.expiryDate,
    required super.cvv,
    required super.isFrozen,
    required super.isVirtual,
    required super.cardType,
  });

  factory CardModel.fromJson(Map<String, dynamic> json) {
    return CardModel(
      id: json['id'],
      cardNumber: json['cardNumber'],
      cardHolderName: json['cardHolderName'],
      expiryDate: json['expiryDate'],
      cvv: json['cvv'],
      isFrozen: json['isFrozen'],
      isVirtual: json['isVirtual'],
      cardType: json['cardType'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cardNumber': cardNumber,
      'cardHolderName': cardHolderName,
      'expiryDate': expiryDate,
      'cvv': cvv,
      'isFrozen': isFrozen,
      'isVirtual': isVirtual,
      'cardType': cardType,
    };
  }

  factory CardModel.fromEntity(CardEntity entity) {
    return CardModel(
      id: entity.id,
      cardNumber: entity.cardNumber,
      cardHolderName: entity.cardHolderName,
      expiryDate: entity.expiryDate,
      cvv: entity.cvv,
      isFrozen: entity.isFrozen,
      isVirtual: entity.isVirtual,
      cardType: entity.cardType,
    );
  }
}
