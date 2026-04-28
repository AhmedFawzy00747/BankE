import '../../domain/entities/account.dart';

class AccountModel extends AccountEntity {
  const AccountModel({
    required super.id,
    required super.accountHolderName,
    required super.balance,
    super.accountType = 'Checking',
    super.accountNumber = '**** 0000',
  });

  factory AccountModel.fromJson(Map<String, dynamic> json) {
    return AccountModel(
      id: json['id'],
      accountHolderName: json['accountHolderName'],
      balance: (json['balance'] as num).toDouble(),
      accountType: json['accountType'] ?? 'Checking',
      accountNumber: json['accountNumber'] ?? '**** 0000',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'accountHolderName': accountHolderName,
      'balance': balance,
      'accountType': accountType,
      'accountNumber': accountNumber,
    };
  }
}
