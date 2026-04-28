import 'package:dio/dio.dart';
import '../../domain/usecases/get_exchange_rates.dart';

class CurrencyRepositoryImpl implements CurrencyRepository {
  final Dio dio;
  static const String baseUrl = 'https://open.er-api.com/v6/latest/';

  CurrencyRepositoryImpl({required this.dio});

  @override
  Future<ExchangeRateEntity> getLatestRates(String baseCurrency) async {
    try {
      final response = await dio.get('$baseUrl$baseCurrency');
      
      if (response.statusCode == 200) {
        final data = response.data;
        final Map<String, dynamic> ratesRaw = data['rates'];
        final Map<String, double> rates = ratesRaw.map((key, value) => MapEntry(key, (value as num).toDouble()));
        
        return ExchangeRateEntity(
          baseCode: data['base_code'],
          rates: rates,
          lastUpdated: DateTime.fromMillisecondsSinceEpoch(data['time_last_update_unix'] * 1000),
        );
      } else {
        throw Exception('Failed to load currency rates');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}
