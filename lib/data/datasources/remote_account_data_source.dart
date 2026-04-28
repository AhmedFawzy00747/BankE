import 'package:dio/dio.dart';
import '../models/account_model.dart';
import '../models/transaction_model.dart';
import '../models/admin_user_model.dart';
import '../models/loan_model.dart';
import 'account_data_source.dart';

class RemoteAccountDataSourceImpl implements AccountDataSource {
  final Dio dio;
  final String baseUrl = 'https://jsonplaceholder.typicode.com';

  RemoteAccountDataSourceImpl({required this.dio});

  @override
  Future<void> init() async {}

  @override
  Future<AccountModel> fetchAccountDetails(String accountId) async {
    try {
      final response = await dio.get('$baseUrl/users/1');
      if (response.statusCode == 200) {
        final data = response.data;
        return AccountModel(
          id: accountId,
          accountHolderName: data['name'],
          balance: 2450.50,
        );
      }
      throw Exception('Server error');
    } catch (e) {
      // Fallback Mock Data
      return AccountModel(
        id: accountId,
        accountHolderName: "Ahmed Fawzy (Mock)",
        balance: 5000.0,
      );
    }
  }

  @override
  Future<List<TransactionModel>> fetchTransactions(String accountId) async {
    try {
      final response = await dio.get('$baseUrl/posts?_limit=10');
      if (response.statusCode == 200) {
        final List data = response.data;
        return data.asMap().entries.map((entry) {
          final i = entry.key;
          final json = entry.value;
          return TransactionModel(
            id: 'remote_${json['id']}',
            amount: (i + 1) * 15.75,
            date: DateTime.now().subtract(Duration(days: i)),
            description: json['title'].toString().substring(0, 15),
            isCredit: i % 3 == 0,
          );
        }).toList();
      }
      throw Exception('Server error');
    } catch (e) {
      // Fallback Mock Transactions for Analytics
      return List.generate(
          8,
          (i) => TransactionModel(
                id: 'mock_tx_$i',
                amount: (i + 1) * 120.0,
                date: DateTime.now().subtract(Duration(days: i)),
                description: i % 2 == 0 ? 'Salary Credit' : 'Online Shopping',
                isCredit: i % 2 == 0,
              ));
    }
  }

  @override
  Future<List<AccountModel>> fetchUserAccounts(String userId) async {
    return [await fetchAccountDetails('acc_checking')];
  }

  @override
  Future<void> performTransfer(
      String senderId, String recipient, double amount, String notes) async {
    try {
      await dio.post('$baseUrl/posts', data: {
        'senderId': senderId,
        'recipient': recipient,
        'amount': amount,
        'notes': notes,
      });
    } catch (e) {
      // Silent fail-safe for demo/mock purposes
    }
  }

  @override
  Future<void> payBill(String senderId, String billerId, String consumerId,
      double amount) async {
    try {
      await dio.post('$baseUrl/posts', data: {
        'senderId': senderId,
        'billerId': billerId,
        'amount': amount,
      });
    } catch (e) {
      // Silent fail-safe
    }
  }

  @override
  Future<void> withdraw(String accountId, double amount) async {
    try {
      await dio.post('$baseUrl/posts',
          data: {'accountId': accountId, 'amount': amount, 'type': 'withdraw'});
    } catch (e) {
      // Silent fail-safe
    }
  }

  @override
  Future<void> deposit(String accountId, double amount) async {
    try {
      await dio.post('$baseUrl/posts',
          data: {'accountId': accountId, 'amount': amount, 'type': 'deposit'});
    } catch (e) {
      // Silent fail-safe
    }
  }

  @override
  Future<List<AdminUserModel>> fetchAllUsers() async {
    try {
      final response = await dio.get('$baseUrl/users');
      final List data = response.data;
      return data
          .map((u) => AdminUserModel(
                id: u['id'].toString(),
                name: u['name'],
                email: u['email'],
                phone: u['phone'],
                balance: 1000.0,
                isBlocked: false,
              ))
          .toList();
    } catch (e) {
      return [
        AdminUserModel(
            id: '1',
            name: 'Mock Admin',
            email: 'admin@mock.com',
            phone: '123',
            balance: 0.0,
            isBlocked: false),
      ];
    }
  }

  @override
  Future<List<Map<String, dynamic>>> fetchBillers() async {
    return [
      {
        'id': 'b1',
        'name': 'Remote Power Co',
        'category': 'Utilities',
        'icon': 'electric_bolt'
      },
      {
        'id': 'b2',
        'name': 'Global Water',
        'category': 'Utilities',
        'icon': 'water_drop'
      },
    ];
  }

  @override
  Future<void> adjustBalance(String userId, double amount) async {}
  @override
  Future<void> blockUser(String userId) async {}
  @override
  Future<void> unblockUser(String userId) async {}
  @override
  void registerUser(String name, String email, String phone) {}
  @override
  Future<List<LoanModel>> fetchAllLoans() async {
    // Simulated API response for defensive coding demonstration
    final mockResponse = {
      'loans': [
        {
          'id': 'L1',
          'userId': 'acc_123',
          'userName': 'Ahmed Fawzy',
          'amount': 5000.0,
          'purpose': 'Home Improvement',
          'durationMonths': 24,
          'status': 'pending',
          'pdfFileName': 'docs.pdf',
          'pdfFilePath': '',
        },
        {
          'id': 'L2',
          'userId': 'acc_123',
          'userName': 'Ahmed Fawzy',
          'amount': 15000.0,
          'purpose': 'Car Loan',
          'durationMonths': 48,
          'status': 'approved',
          'pdfFileName': 'car_docs.pdf',
          'pdfFilePath': '',
        },
      ]
    };

    final List data = mockResponse['loans'] as List? ?? [];
    return data.map((l) => LoanModel(
      id: l['id'],
      userId: l['userId'],
      userName: l['userName'],
      amount: (l['amount'] as num).toDouble(),
      purpose: l['purpose'],
      durationMonths: l['durationMonths'],
      status: l['status'] == 'approved' ? LoanStatus.approved : LoanStatus.pending,
      pdfFileName: l['pdfFileName'],
      pdfFilePath: l['pdfFilePath'],
    )).toList();
  }

  @override
  Future<LoanModel> submitLoanRequest(String userId, String userName, double amount,
      String purpose, int duration, String pdfName, String pdfPath) async {
    await Future.delayed(const Duration(seconds: 1));
    return LoanModel(
      id: 'L${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      userName: userName,
      amount: amount,
      purpose: purpose,
      durationMonths: duration,
      status: LoanStatus.pending,
      pdfFileName: pdfName,
      pdfFilePath: pdfPath,
    );
  }

  @override
  Future<void> updateLoanStatus(String loanId, LoanStatus status) async {}
  @override
  void reset() {}
}
