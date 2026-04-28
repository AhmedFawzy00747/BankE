import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/account_model.dart';
import '../models/transaction_model.dart';
import '../models/admin_user_model.dart';
import '../models/loan_model.dart';
import 'account_data_source.dart';

class MockAccountDataSourceImpl implements AccountDataSource {
  static const String _balanceKey = 'wallet_balances';
  static const String _transactionsKey = 'wallet_transactions';

  static Map<String, double> _balances = {
    'acc_checking': 1450.75,
    'acc_savings': 8500.00,
  };
  static String? _registeredName;
  static String? _registeredEmail;
  static String? _registeredPhone;
  static String? _registeredId;

  static final List<AdminUserModel> _adminUsers = [
    const AdminUserModel(
        id: 'acc_123',
        name: 'John Doe',
        email: 'john@example.com',
        phone: '+1234567890',
        balance: 1450.75,
        isBlocked: false),
    const AdminUserModel(
        id: 'acc_456',
        name: 'Alice Smith',
        email: 'alice@example.com',
        phone: '+1987654321',
        balance: 8500.00,
        isBlocked: false),
    const AdminUserModel(
        id: 'acc_789',
        name: 'Bob Johnson',
        email: 'bob@example.com',
        phone: '+1555666777',
        balance: 320.50,
        isBlocked: true),
  ];

  static List<TransactionModel> _transactions = [
    // ... same transactions
    TransactionModel(
      id: 'tx_101',
      amount: 250.0,
      date: DateTime.now().subtract(const Duration(days: 1)),
      description: 'Grocery Store',
      isCredit: false,
    ),
    TransactionModel(
      id: 'tx_102',
      amount: 1500.0,
      date: DateTime.now().subtract(const Duration(days: 3)),
      description: 'Salary Deposit',
      isCredit: true,
    ),
    TransactionModel(
      id: 'tx_103',
      amount: 50.0,
      date: DateTime.now().subtract(const Duration(days: 5)),
      description: 'Coffee Shop',
      isCredit: false,
    ),
  ];

  static final List<LoanModel> _loans = [
    const LoanModel(
        id: 'loan_01',
        userId: 'acc_789',
        userName: 'Bob Johnson',
        amount: 5000,
        purpose: 'Home Renovation',
        durationMonths: 12,
        pdfFileName: 'Bob_documents.pdf',
        pdfFilePath: ''),
  ];

  @override
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();

    // Load balances
    if (prefs.containsKey(_balanceKey)) {
      final String? balJson = prefs.getString(_balanceKey);
      if (balJson != null) {
        _balances = Map<String, double>.from(json.decode(balJson));
      }
    }

    // Load transactions
    if (prefs.containsKey(_transactionsKey)) {
      final String? txJson = prefs.getString(_transactionsKey);
      if (txJson != null) {
        final List<dynamic> decoded = json.decode(txJson);
        _transactions =
            decoded.map((item) => TransactionModel.fromJson(item)).toList();
      }
    }
  }

  Future<void> _saveToDisk() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_balanceKey, json.encode(_balances));

    final String encoded =
        json.encode(_transactions.map((tx) => tx.toJson()).toList());
    await prefs.setString(_transactionsKey, encoded);
  }

  @override
  Future<AccountModel> fetchAccountDetails(String accountId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    String name = _registeredName ?? 'John Doe';
    double balance = _balances[accountId] ?? 0.0;
    String type = accountId == 'acc_savings' ? 'Savings' : 'Checking';
    String number = accountId == 'acc_savings' ? '**** 5678' : '**** 1234';

    return AccountModel(
      id: accountId,
      accountHolderName: name,
      balance: balance,
      accountType: type,
      accountNumber: number,
    );
  }

  @override
  Future<List<AccountModel>> fetchUserAccounts(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    String name = _registeredName ?? 'John Doe';
    return [
      AccountModel(
        id: 'acc_checking',
        accountHolderName: name,
        balance: _balances['acc_checking'] ?? 0.0,
        accountType: 'Checking',
        accountNumber: '**** 1234',
      ),
      AccountModel(
        id: 'acc_savings',
        accountHolderName: name,
        balance: _balances['acc_savings'] ?? 0.0,
        accountType: 'Savings',
        accountNumber: '**** 5678',
      ),
    ];
  }

  @override
  void registerUser(String name, String email, String phone) {
    _registeredName = name;
    _registeredEmail = email;
    _registeredPhone = phone;
    _registeredId = 'acc_${DateTime.now().millisecondsSinceEpoch}';

    // Add to admin list
    _adminUsers.add(AdminUserModel(
        id: _registeredId!,
        name: name,
        email: email,
        phone: phone,
        balance: _balances['acc_checking'] ?? 0.0,
        isBlocked: false));
  }

  @override
  Future<List<AdminUserModel>> fetchAllUsers() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return List.from(_adminUsers);
  }

  @override
  Future<void> blockUser(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _adminUsers.indexWhere((u) => u.id == userId);
    if (index != -1) {
      _adminUsers[index] = _adminUsers[index].copyWith(isBlocked: true);
    }
  }

  @override
  Future<void> unblockUser(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _adminUsers.indexWhere((u) => u.id == userId);
    if (index != -1) {
      _adminUsers[index] = _adminUsers[index].copyWith(isBlocked: false);
    }
  }

  @override
  Future<void> adjustBalance(String userId, double amount) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _adminUsers.indexWhere((u) => u.id == userId);
    if (index != -1) {
      _adminUsers[index] = _adminUsers[index]
          .copyWith(balance: _adminUsers[index].balance + amount);
      if (userId == 'acc_123' || userId == _registeredId) {
        _balances['acc_checking'] = (_balances['acc_checking'] ?? 0.0) + amount;
        await _saveToDisk();
      }
    }
  }

  @override
  Future<List<TransactionModel>> fetchTransactions(String accountId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(_transactions.reversed);
  }

  @override
  Future<void> performTransfer(
      String senderId, String recipient, double amount, String notes) async {
    await Future.delayed(const Duration(seconds: 1));

    double currentBalance = _balances[senderId] ?? 0.0;
    if (amount > currentBalance) {
      throw Exception('Insufficient balance in $senderId');
    }

    _balances[senderId] = currentBalance - amount;

    // If transferring to own savings
    if (_balances.containsKey(recipient)) {
      _balances[recipient] = (_balances[recipient] ?? 0.0) + amount;
    }
    _transactions.add(TransactionModel(
      id: 'tx_${DateTime.now().millisecondsSinceEpoch}',
      amount: amount,
      date: DateTime.now(),
      description: 'Transfer to $recipient',
      isCredit: false,
    ));

    await _saveToDisk();
  }

  @override
  Future<void> payBill(String senderId, String billerId, String consumerId,
      double amount) async {
    await Future.delayed(const Duration(seconds: 1));

    double currentBalance = _balances[senderId] ?? 0.0;
    if (amount > currentBalance) {
      throw Exception('Insufficient balance for this payment');
    }

    _balances[senderId] = currentBalance - amount;
    _transactions.add(TransactionModel(
      id: 'bill_${DateTime.now().millisecondsSinceEpoch}',
      amount: amount,
      date: DateTime.now(),
      description: 'Bill Payment: $billerId (ID: $consumerId)',
      isCredit: false,
    ));

    await _saveToDisk();
  }

  @override
  Future<List<Map<String, dynamic>>> fetchBillers() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return [
      {
        'id': 'b1',
        'name': 'City Electricity',
        'category': 'Utilities',
        'icon': 'bolt'
      },
      {
        'id': 'b2',
        'name': 'Regional Water Corp',
        'category': 'Utilities',
        'icon': 'water_drop'
      },
      {
        'id': 'b3',
        'name': 'Gas Services',
        'category': 'Utilities',
        'icon': 'local_fire_department'
      },
      {'id': 'b4', 'name': 'Fiber Net', 'category': 'Telecom', 'icon': 'wifi'},
      {
        'id': 'b5',
        'name': 'Sky Cable',
        'category': 'Entertainment',
        'icon': 'tv'
      },
      {
        'id': 'b6',
        'name': 'Mobile Connect',
        'category': 'Telecom',
        'icon': 'smartphone'
      },
      {
        'id': 'b7',
        'name': 'Global SIM',
        'category': 'Telecom',
        'icon': 'sim_card'
      },
      {
        'id': 'b8',
        'name': 'Central University',
        'category': 'Education',
        'icon': 'school'
      },
      {
        'id': 'b9',
        'name': 'St. Mary\'s Hospital',
        'category': 'Health',
        'icon': 'medical_services'
      },
      {
        'id': 'b10',
        'name': 'Safe Insurance',
        'category': 'Finance',
        'icon': 'security'
      },
    ];
  }

  @override
  Future<LoanModel> submitLoanRequest(String userId, String userName, double amount,
      String purpose, int duration, String pdfName, String pdfPath) async {
    await Future.delayed(const Duration(seconds: 1));
    final newLoan = LoanModel(
      id: 'loan_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      userName: userName,
      amount: amount,
      purpose: purpose,
      durationMonths: duration,
      pdfFileName: pdfName,
      pdfFilePath: pdfPath,
    );
    _loans.add(newLoan);
    return newLoan;
  }

  @override
  Future<List<LoanModel>> fetchAllLoans() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(_loans);
  }

  @override
  Future<void> updateLoanStatus(String loanId, LoanStatus status) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _loans.indexWhere((L) => L.id == loanId);
    if (index != -1) {
      _loans[index] = _loans[index].copyWith(status: status);

      // If approved, mock adding balance to that user realistically
      if (status == LoanStatus.approved) {
        final loan = _loans[index];
        await adjustBalance(loan.userId, loan.amount);
      }
    }
  }

  @override
  void reset() {
    _balances = {
      'acc_checking': 1450.75,
      'acc_savings': 8500.00,
    };
    _registeredName = null;
    _registeredEmail = null;
    _registeredPhone = null;
    _registeredId = null;
    _transactions = [
      TransactionModel(
        id: 'tx_101',
        amount: 250.0,
        date: DateTime.now().subtract(const Duration(days: 1)),
        description: 'Grocery Store',
        isCredit: false,
      ),
      TransactionModel(
        id: 'tx_102',
        amount: 1500.0,
        date: DateTime.now().subtract(const Duration(days: 3)),
        description: 'Salary Deposit',
        isCredit: true,
      ),
      TransactionModel(
        id: 'tx_103',
        amount: 50.0,
        date: DateTime.now().subtract(const Duration(days: 5)),
        description: 'Coffee Shop',
        isCredit: false,
      ),
    ];
  }

  @override
  Future<void> withdraw(String accountId, double amount) async {
    await Future.delayed(const Duration(seconds: 1));
    final currentBalance = _balances[accountId] ?? 0.0;
    if (currentBalance < amount) {
      throw Exception('Insufficient funds');
    }
    _balances[accountId] = currentBalance - amount;

    _transactions.insert(
        0,
        TransactionModel(
          id: 'tx_${DateTime.now().millisecondsSinceEpoch}',
          amount: amount,
          date: DateTime.now(),
          description: 'ATM Withdrawal',
          isCredit: false,
        ));
    await _saveToDisk();
  }

  @override
  Future<void> deposit(String accountId, double amount) async {
    await Future.delayed(const Duration(seconds: 1));
    final currentBalance = _balances[accountId] ?? 0.0;
    _balances[accountId] = currentBalance + amount;

    _transactions.insert(
        0,
        TransactionModel(
          id: 'tx_${DateTime.now().millisecondsSinceEpoch}',
          amount: amount,
          date: DateTime.now(),
          description: 'ATM Deposit',
          isCredit: true,
        ));
    await _saveToDisk();
  }
}
