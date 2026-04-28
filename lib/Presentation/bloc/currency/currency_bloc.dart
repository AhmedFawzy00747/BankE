import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/usecases/get_exchange_rates.dart';

// Events
abstract class CurrencyEvent extends Equatable {
  const CurrencyEvent();
  @override
  List<Object?> get props => [];
}

class LoadExchangeRatesEvent extends CurrencyEvent {
  final String baseCurrency;
  const LoadExchangeRatesEvent(this.baseCurrency);
  @override
  List<Object?> get props => [baseCurrency];
}

class ChangeCurrencyEvent extends CurrencyEvent {
  final String currencyCode;
  const ChangeCurrencyEvent(this.currencyCode);
  @override
  List<Object?> get props => [currencyCode];
}

// States
class CurrencyState extends Equatable {
  final String currencyCode;
  final String symbol;
  final double rateToUsd;
  final bool isLoading;
  final String? errorMessage;
  final Map<String, double> allRates;

  const CurrencyState({
    required this.currencyCode,
    required this.symbol,
    required this.rateToUsd,
    this.isLoading = false,
    this.errorMessage,
    this.allRates = const {'USD': 1.0},
  });

  @override
  List<Object?> get props => [currencyCode, symbol, rateToUsd, isLoading, errorMessage, allRates];

  CurrencyState copyWith({
    String? currencyCode,
    String? symbol,
    double? rateToUsd,
    bool? isLoading,
    String? errorMessage,
    Map<String, double>? allRates,
  }) {
    return CurrencyState(
      currencyCode: currencyCode ?? this.currencyCode,
      symbol: symbol ?? this.symbol,
      rateToUsd: rateToUsd ?? this.rateToUsd,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      allRates: allRates ?? this.allRates,
    );
  }

  String format(double amount) {
    return '$symbol ${(amount * rateToUsd).toStringAsFixed(2)}';
  }
}

// Bloc
class CurrencyBloc extends Bloc<CurrencyEvent, CurrencyState> {
  final GetExchangeRatesUseCase getExchangeRatesUseCase;

  CurrencyBloc({required this.getExchangeRatesUseCase}) 
    : super(const CurrencyState(currencyCode: 'USD', symbol: '\$', rateToUsd: 1.0)) {
    on<LoadExchangeRatesEvent>(_onLoadRates);
    on<ChangeCurrencyEvent>(_onChangeCurrency);
    
    // Auto-load rates on startup
    add(const LoadExchangeRatesEvent('USD'));
  }

  Future<void> _onLoadRates(LoadExchangeRatesEvent event, Emitter<CurrencyState> emit) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final data = await getExchangeRatesUseCase.execute(event.baseCurrency);
      emit(state.copyWith(
        isLoading: false,
        allRates: data.rates,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  void _onChangeCurrency(ChangeCurrencyEvent event, Emitter<CurrencyState> emit) {
    final newRate = state.allRates[event.currencyCode] ?? 1.0;
    String symbol = event.currencyCode;
    
    // Mapping some common symbols
    final symbols = {'USD': '\$', 'EUR': '€', 'GBP': '£', 'JPY': '¥'};
    symbol = symbols[event.currencyCode] ?? event.currencyCode;

    emit(state.copyWith(
      currencyCode: event.currencyCode,
      symbol: symbol,
      rateToUsd: newRate,
    ));
  }
}
