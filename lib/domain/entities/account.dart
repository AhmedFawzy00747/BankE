class AccountEntity {
  final String id;
  final String accountHolderName;
  final double balance;
  final String accountType; // e.g. "Checking", "Savings"
  final String accountNumber; // e.g. "**** 1234"

  const AccountEntity({
    required this.id,
    required this.accountHolderName,
    required this.balance,
    this.accountType = 'Checking',
    this.accountNumber = '**** 0000',
  });
}
