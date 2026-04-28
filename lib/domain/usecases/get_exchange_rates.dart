class ExchangeRateEntity {
  final String baseCode;
  final Map<String, double> rates;
  final DateTime lastUpdated;

  ExchangeRateEntity({
    required this.baseCode,
    required this.rates,
    required this.lastUpdated,
  });
}

abstract class CurrencyRepository {
  Future<ExchangeRateEntity> getLatestRates(String baseCurrency);
}

class GetExchangeRatesUseCase {
  final CurrencyRepository repository;
  GetExchangeRatesUseCase(this.repository);

  Future<ExchangeRateEntity> execute(String baseCurrency) async {
    return await repository.getLatestRates(baseCurrency);
  }
}
