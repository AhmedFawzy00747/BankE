import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:contr_project/Presentation/bloc/account_bloc.dart';
import 'package:contr_project/Presentation/bloc/account_event.dart';
import 'package:contr_project/Presentation/bloc/transaction_bloc.dart';
import 'package:contr_project/Presentation/bloc/transaction_event.dart';
import 'package:contr_project/Presentation/bloc/transfer_bloc.dart';
import 'package:contr_project/Presentation/bloc/auth_bloc.dart';
import 'package:contr_project/Presentation/Views/auth/splash_screen.dart';
import 'package:contr_project/data/datasources/mock_account_data_source.dart';
import 'package:contr_project/data/repositories/account_repository_impl.dart';
import 'package:contr_project/domain/usecases/get_balance.dart';
import 'package:contr_project/domain/usecases/get_transactions.dart';
import 'package:contr_project/domain/usecases/perform_transfer.dart';
import 'package:contr_project/domain/usecases/pay_bill.dart';
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final dataSource = MockAccountDataSourceImpl();
  await dataSource.init();
  
  final accountRepository = AccountRepositoryImpl(dataSource: dataSource);
  final otpRepository = MockOtpRepositoryImpl();
  final cardRepository = CardRepositoryImpl();
  final supportRepository = MockSupportRepositoryImpl();
  final locationService = MockLocationServiceImpl();

  runApp(MyApp(
    accountRepository: accountRepository, 
    otpRepository: otpRepository,
    cardRepository: cardRepository,
    supportRepository: supportRepository,
    locationService: locationService,
    dataSource: dataSource,
  ));
}

class MyApp extends StatelessWidget {
  final AccountRepositoryImpl accountRepository;
  final OtpRepository otpRepository;
  final CardRepository cardRepository;
  final MockSupportRepositoryImpl supportRepository;
  final MockLocationServiceImpl locationService;
  final MockAccountDataSourceImpl dataSource;

  const MyApp({
    super.key, 
    required this.accountRepository, 
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
            getBalanceUseCase: GetBalanceUseCase(accountRepository),
          )..add(const FetchAccountBalance(AppConstants.currentAccountId)),
        ),
        BlocProvider(
          create: (context) => TransactionBloc(
            getTransactionsUseCase: GetTransactionsUseCase(accountRepository),
          )..add(const FetchTransactions(AppConstants.currentAccountId)),
        ),
        BlocProvider(
          create: (context) => TransferBloc(
            performTransferUseCase: PerformTransferUseCase(accountRepository),
            payBillUseCase: PayBillUseCase(accountRepository),
            getBillersUseCase: GetBillersUseCase(accountRepository),
            detectFraudUseCase: DetectFraudUseCase(accountRepository, locationService),
            transactionBloc: context.read<TransactionBloc>(),
            accountBloc: context.read<AccountBloc>(),
          ),
        ),
        BlocProvider(
          create: (context) => AuthBloc(
            dataSource: dataSource, 
            locationService: locationService,
            logoutUseCase: LogoutUseCase(dataSource),
          ),
        ),
        BlocProvider(
          create: (context) => OtpBloc(otpRepository: otpRepository),
        ),
        BlocProvider(
          create: (context) => AdminBloc(dataSource: dataSource),
        ),
        BlocProvider(
          create: (context) => LoanBloc(dataSource: dataSource),
        ),
        BlocProvider(
          create: (context) => CardBloc(
            getCardsUseCase: GetCardsUseCase(cardRepository),
            addCardUseCase: AddCardUseCase(cardRepository),
            freezeCardUseCase: FreezeCardUseCase(cardRepository),
            deleteCardUseCase: DeleteCardUseCase(cardRepository),
          ),
        ),
        BlocProvider(
          create: (context) => LanguageBloc()..add(LoadLanguageEvent()),
        ),
        BlocProvider(
          create: (context) => ThemeBloc()..add(LoadThemeEvent()),
        ),
        BlocProvider(
          create: (context) => SupportBloc(
            sendMessageUseCase: SendMessageUseCase(supportRepository),
          ),
        ),
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          return BlocBuilder<LanguageBloc, LanguageState>(
            builder: (context, languageState) {
              return MaterialApp(
                title: 'Internet Banking',
                debugShowCheckedModeBanner: false,
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                themeMode: themeState.themeMode,
                locale: languageState.locale,
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
