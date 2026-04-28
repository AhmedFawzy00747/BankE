import 'package:contr_project/Presentation/bloc/rewards/rewards_bloc.dart';
import 'package:contr_project/domain/repositories/support_repository.dart';
import 'package:contr_project/domain/services/location_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:contr_project/Presentation/bloc/account_bloc.dart';
import 'package:contr_project/Presentation/bloc/account_event.dart';
import 'package:contr_project/Presentation/bloc/transaction_bloc.dart';
import 'package:contr_project/Presentation/bloc/transaction_event.dart';
import 'package:contr_project/Presentation/bloc/transfer_bloc.dart';
import 'package:contr_project/Presentation/bloc/auth_bloc.dart';
import 'package:contr_project/Presentation/bloc/atm/atm_bloc.dart';
import 'package:contr_project/domain/usecases/withdraw_money.dart';
import 'package:contr_project/domain/usecases/deposit_money.dart';
import 'package:contr_project/Presentation/Views/auth/splash_screen.dart';
import 'package:contr_project/data/datasources/account_data_source.dart';
import 'package:contr_project/data/datasources/remote_account_data_source.dart';
import 'package:contr_project/data/repositories/account_repository_impl.dart';
import 'package:contr_project/domain/usecases/get_balance.dart';
import 'package:contr_project/domain/usecases/get_user_accounts.dart';
import 'package:contr_project/domain/usecases/get_transactions.dart';
import 'package:contr_project/domain/usecases/perform_transfer.dart';
import 'package:contr_project/domain/usecases/pay_bill.dart';
import 'package:contr_project/domain/usecases/get_exchange_rates.dart';
import 'package:contr_project/data/repositories/currency_repository_impl.dart';
import 'package:contr_project/core/network/dio_client.dart';
import 'package:contr_project/core/network/dio_interceptor.dart';
import 'package:contr_project/domain/usecases/get_billers.dart';
import 'package:contr_project/core/theme/app_theme.dart';
import 'package:contr_project/core/constants/app_constants.dart';
import 'package:contr_project/domain/repositories/otp_repository.dart';
import 'package:contr_project/data/repositories/mock_otp_repository_impl.dart';
import 'package:contr_project/Presentation/bloc/otp/otp_bloc.dart';
import 'package:contr_project/Presentation/bloc/admin/admin_bloc.dart';
import 'package:contr_project/Presentation/bloc/loan/loan_bloc.dart';
import 'package:contr_project/domain/repositories/card_repository.dart';
import 'package:contr_project/data/repositories/card_repository_impl.dart';
import 'package:contr_project/domain/usecases/add_card.dart';
import 'package:contr_project/domain/usecases/get_cards.dart';
import 'package:contr_project/domain/usecases/freeze_card.dart';
import 'package:contr_project/domain/usecases/delete_card.dart';
import 'package:contr_project/domain/usecases/update_card_limit.dart';
import 'package:contr_project/domain/usecases/change_card_pin.dart';
import 'package:contr_project/domain/usecases/generate_virtual_card.dart';
import 'package:contr_project/Presentation/bloc/card/card_bloc.dart';
import 'package:contr_project/domain/usecases/detect_fraud.dart';
import 'package:contr_project/Presentation/bloc/language/language_bloc.dart';
import 'package:contr_project/Presentation/bloc/theme/theme_bloc.dart';
import 'package:contr_project/Presentation/bloc/support/support_bloc.dart';
import 'package:contr_project/data/repositories/mock_support_repository_impl.dart';
import 'package:contr_project/domain/usecases/send_message.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:contr_project/l10n/app_localizations.dart';
import 'package:contr_project/data/services/mock_location_service_impl.dart';
import 'package:contr_project/domain/usecases/logout_usecase.dart';
import 'package:contr_project/domain/repositories/loan_repository.dart';
import 'package:contr_project/data/repositories/loan_repository_impl.dart';
import 'package:contr_project/domain/usecases/submit_loan_request.dart';
import 'package:contr_project/domain/usecases/get_loans.dart';
import 'package:contr_project/Presentation/bloc/locator/locator_bloc.dart';
import 'package:contr_project/Presentation/bloc/locator/locator_event.dart';
import 'package:contr_project/Presentation/bloc/security/security_bloc.dart';
import 'package:contr_project/Presentation/bloc/security/security_event.dart';
import 'package:contr_project/Presentation/bloc/notification/notification_bloc.dart';
import 'package:contr_project/Presentation/bloc/notification/notification_event.dart';
import 'package:contr_project/Presentation/bloc/currency/currency_bloc.dart';
import 'package:contr_project/Presentation/bloc/settings/settings_bloc.dart';
import 'package:contr_project/Presentation/bloc/rewards/rewards_event.dart';
import 'package:contr_project/Presentation/bloc/qr/qr_bloc.dart';
import 'package:contr_project/Presentation/bloc/qr/qr_event.dart';
import 'package:contr_project/Presentation/bloc/savings_goal/savings_goal_bloc.dart';
import 'package:contr_project/domain/usecases/update_loan_status.dart';
import 'package:contr_project/domain/usecases/calculate_loan_emi.dart';
import 'dart:developer' as dev;

class GlobalBlocObserver extends BlocObserver {
  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    dev.log('Bloc Transition: ${bloc.runtimeType} | ${transition.currentState.runtimeType} -> ${transition.nextState.runtimeType}', name: 'BlocObserver');
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    dev.log('Bloc Error: ${bloc.runtimeType} | $error', name: 'BlocObserver', error: error, stackTrace: stackTrace);
    super.onError(bloc, error, stackTrace);
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Bloc.observer = GlobalBlocObserver();

  // Global Error Handler for UI Crashes
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color(0xFF0F172A),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.warning_amber_rounded, color: Colors.amber, size: 64),
                const SizedBox(height: 16),
                const Text(
                  'Something went wrong',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'A rendering error occurred in the UI. Please try restarting the application.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    // Logic to restart or go back could be added here
                  },
                  child: const Text('Return to Safety'),
                )
              ],
            ),
          ),
        ),
      ),
    );
  };

  final dio = DioClient.instance;
  final RemoteAccountDataSourceImpl dataSource =
      RemoteAccountDataSourceImpl(dio: dio);

  final accountRepository = AccountRepositoryImpl(dataSource: dataSource);
  final loanRepository = LoanRepositoryImpl(dataSource);
  final otpRepository = MockOtpRepositoryImpl();
  final cardRepository = CardRepositoryImpl();
  final supportRepository = MockSupportRepositoryImpl();
  final locationService = MockLocationServiceImpl();

  runApp(MyApp(
    accountRepository: accountRepository,
    loanRepository: loanRepository,
    otpRepository: otpRepository,
    cardRepository: cardRepository,
    supportRepository: supportRepository,
    locationService: locationService,
    dataSource: dataSource,
  ));
}

class MyApp extends StatelessWidget {
  final AccountRepositoryImpl accountRepository;
  final LoanRepository loanRepository;
  final OtpRepository otpRepository;
  final CardRepository cardRepository;
  final SupportRepository supportRepository;
  final LocationService locationService;
  final RemoteAccountDataSourceImpl dataSource;

  const MyApp({
    super.key,
    required this.accountRepository,
    required this.loanRepository,
    required this.otpRepository,
    required this.cardRepository,
    required this.supportRepository,
    required this.locationService,
    required this.dataSource,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AccountBloc(
            getBalanceUseCase: GetBalanceUseCase(this.accountRepository),
            getUserAccountsUseCase:
                GetUserAccountsUseCase(this.accountRepository),
          )..add(const LoadUserAccounts('acc_123')), // Using mock user ID
        ),
        BlocProvider(
          create: (context) => TransactionBloc(
            getTransactionsUseCase:
                GetTransactionsUseCase(this.accountRepository),
          )..add(const FetchTransactions(AppConstants.currentAccountId)),
        ),
        BlocProvider(
          create: (context) => TransferBloc(
            performTransferUseCase:
                PerformTransferUseCase(this.accountRepository),
            payBillUseCase: PayBillUseCase(this.accountRepository),
            getBillersUseCase: GetBillersUseCase(this.accountRepository),
            detectFraudUseCase: DetectFraudUseCase(
                this.accountRepository, this.locationService),
            transactionBloc: context.read<TransactionBloc>(),
            accountBloc: context.read<AccountBloc>(),
          ),
        ),
        BlocProvider(
          create: (context) => AuthBloc(
            dataSource: this.dataSource,
            locationService: this.locationService,
            logoutUseCase: LogoutUseCase(this.dataSource),
          ),
        ),
        BlocProvider(
          create: (context) => OtpBloc(otpRepository: this.otpRepository),
        ),
        BlocProvider(
          create: (context) => AdminBloc(dataSource: this.dataSource),
        ),
        BlocProvider(
          create: (context) => LoanBloc(
            submitLoanRequestUseCase:
                SubmitLoanRequestUseCase(this.loanRepository),
            getLoansUseCase: GetLoansUseCase(this.loanRepository),
            updateLoanStatusUseCase:
                UpdateLoanStatusUseCase(this.loanRepository),
            calculateLoanEMI: CalculateLoanEMI(),
          ),
        ),
        BlocProvider(
          create: (context) => CardBloc(
            getCardsUseCase: GetCardsUseCase(this.cardRepository),
            addCardUseCase: AddCardUseCase(this.cardRepository),
            freezeCardUseCase: FreezeCardUseCase(this.cardRepository),
            deleteCardUseCase: DeleteCardUseCase(this.cardRepository),
            updateCardLimitUseCase: UpdateCardLimitUseCase(this.cardRepository),
            changeCardPinUseCase: ChangeCardPinUseCase(this.cardRepository),
            generateVirtualCardUseCase:
                GenerateVirtualCardUseCase(this.cardRepository),
          ),
        ),
        BlocProvider(
          create: (context) => LanguageBloc()..add(LoadLanguageEvent()),
        ),
        BlocProvider(
          create: (context) =>
              LocatorBloc(locationService: this.locationService)
                ..add(FetchBankLocationsEvent()),
        ),
        BlocProvider(
          create: (context) => SecurityBloc()..add(LoadSecuritySettingsEvent()),
        ),
        BlocProvider(
          create: (context) =>
              NotificationBloc()..add(LoadNotificationsEvent()),
        ),
        BlocProvider(
          create: (context) => CurrencyBloc(
            getExchangeRatesUseCase: GetExchangeRatesUseCase(
              CurrencyRepositoryImpl(dio: DioClient.instance),
            ),
          ),
        ),
        BlocProvider(
          create: (context) => SettingsBloc()..add(LoadSettingsEvent()),
        ),
        BlocProvider(
          create: (context) => RewardsBloc()..add(LoadRewardsEvent()),
        ),
        BlocProvider(
          create: (context) => QrBloc(),
        ),
        BlocProvider(
          create: (context) => SavingsGoalBloc()..add(LoadSavingsGoalsEvent()),
        ),
        BlocProvider(
          create: (context) => ThemeBloc()..add(LoadThemeEvent()),
        ),
        BlocProvider(
          create: (context) => SupportBloc(
            sendMessageUseCase: SendMessageUseCase(this.supportRepository),
          ),
        ),
        BlocProvider(
          create: (context) => AtmBloc(
            withdrawUseCase: WithdrawMoneyUseCase(this.accountRepository),
            depositUseCase: DepositMoneyUseCase(this.accountRepository),
          ),
        ),
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          return BlocBuilder<LanguageBloc, LanguageState>(
            builder: (context, languageState) {
              return MaterialApp(
                title: 'Contro Bank',
                debugShowCheckedModeBanner: false,
                themeMode: themeState.themeMode,
                locale: languageState.locale,
                theme: ThemeData(
                  useMaterial3: true,
                  primaryColor: themeState.primaryColor,
                  colorScheme: ColorScheme.fromSeed(
                    seedColor: themeState.primaryColor,
                    primary: themeState.primaryColor,
                    brightness: Brightness.light,
                  ),
                  textTheme: const TextTheme().apply(
                    fontSizeFactor: themeState.fontScale,
                  ),
                ),
                darkTheme: ThemeData(
                  useMaterial3: true,
                  primaryColor: themeState.primaryColor,
                  colorScheme: ColorScheme.fromSeed(
                    seedColor: themeState.primaryColor,
                    primary: themeState.primaryColor,
                    brightness: Brightness.dark,
                  ),
                  textTheme: const TextTheme().apply(
                    fontSizeFactor: themeState.fontScale,
                    bodyColor: Colors.white,
                    displayColor: Colors.white,
                  ),
                ),
                localizationsDelegates: const [
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                supportedLocales: const [
                  Locale('en'),
                  Locale('ar'),
                ],
                home: const SplashScreen(),
              );
            },
          );
        },
      ),
    );
  }
}
