import 'dart:convert';
import 'package:contr_project/data/models/admin_user_model.dart';
import 'package:contr_project/data/models/loan_model.dart';
import 'package:http/http.dart' as http;
import '../models/account_model.dart';
import '../models/transaction_model.dart';
import '../models/loan_model.dart';
import 'mock_account_data_source.dart'; // To get the AccountDataSource interface

class RemoteAccountDataSourceImpl implements AccountDataSource {
  final http.Client client;
  final String baseUrl = 'https://api.contro.com/v1';

  RemoteAccountDataSourceImpl({required this.client});

  @override
  Future<void> init() async {
    // Remote data source doesn't need pre-initialization but satisfies the interface
  }

  @override
  Future<AccountModel> fetchAccountDetails(String accountId) async {
    final response = await client.get(
      Uri.parse('$baseUrl/accounts/$accountId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return AccountModel(
        id: data['id'],
        accountHolderName: data['accountHolderName'],
        balance: (data['balance'] as num).toDouble(),
      );
    } else {
      throw Exception('Failed to load account details');
    }
  }

  @override
  Future<List<TransactionModel>> fetchTransactions(String accountId) async {
    final response = await client.get(
      Uri.parse('$baseUrl/accounts/$accountId/transactions'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data
          .map((json) => TransactionModel(
                id: json['id'],
                amount: (json['amount'] as num).toDouble(),
                date: DateTime.parse(json['date']),
                description: json['description'],
                isCredit: json['isCredit'],
              ))
          .toList();
    } else {
      throw Exception('Failed to load transactions');
    }
  }

  @override
  Future<void> performTransfer(
      String senderId, String recipient, double amount, String notes) async {
    final response = await client.post(
      Uri.parse('$baseUrl/accounts/$senderId/transfer'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'recipient': recipient,
        'amount': amount,
        'notes': notes,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Transfer failed on server');
    }
  }

  @override
  Future<void> payBill(String senderId, String billerId, String consumerId,
      double amount) async {
    final response = await client.post(
      Uri.parse('$baseUrl/accounts/$senderId/pay-bill'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'billerId': billerId,
        'consumerId': consumerId,
        'amount': amount,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Bill payment failed on server');
    }
  }

  @override
  Future<void> adjustBalance(String userId, double amount) {
    // TODO: implement adjustBalance
    throw UnimplementedError();
  }

  @override
  Future<void> blockUser(String userId) {
    // TODO: implement blockUser
    throw UnimplementedError();
  }

  @override
  Future<List<AdminUserModel>> fetchAllUsers() {
    // TODO: implement fetchAllUsers
    throw UnimplementedError();
  }

  @override
  void registerUser(String name, String email, String phone) {
    // TODO: implement registerUser
  }

  @override
  Future<void> unblockUser(String userId) {
    // TODO: implement unblockUser
    throw UnimplementedError();
  }

  @override
  Future<List<Map<String, dynamic>>> fetchBillers() {
    // TODO: implement fetchBillers
    throw UnimplementedError();
  }

  @override
  Future<List<LoanModel>> fetchAllLoans() {
    // TODO: implement fetchAllLoans
    throw UnimplementedError();
  }

  @override
  Future<void> submitLoanRequest(String userId, String userName, double amount,
      String purpose, int duration, String pdfName) {
    // TODO: implement submitLoanRequest
    throw UnimplementedError();
  }

  @override
  Future<void> updateLoanStatus(String loanId, LoanStatus status) {
    // TODO: implement updateLoanStatus
    throw UnimplementedError();
  }

  @override
  void reset() {
    // TODO: implement reset
  }
}
