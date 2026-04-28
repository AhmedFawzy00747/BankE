import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_balance.dart';
import '../../domain/usecases/get_user_accounts.dart';
import 'account_event.dart';
import 'account_state.dart';

class AccountBloc extends Bloc<AccountEvent, AccountState> {
  final GetBalanceUseCase getBalanceUseCase;
  final GetUserAccountsUseCase getUserAccountsUseCase;

  AccountBloc({
    required this.getBalanceUseCase,
    required this.getUserAccountsUseCase,
  }) : super(AccountInitial()) {
    on<FetchAccountBalance>(_onFetchAccountBalance);
    on<LoadUserAccounts>(_onLoadUserAccounts);
    on<SwitchAccount>(_onSwitchAccount);
  }

  Future<void> _onFetchAccountBalance(FetchAccountBalance event, Emitter<AccountState> emit) async {
    emit(AccountLoading());
    try {
      final account = await getBalanceUseCase.execute(event.accountId);
      emit(AccountLoaded(account, allAccounts: [account]));
    } catch (e) {
      emit(AccountError(e.toString()));
    }
  }

  Future<void> _onLoadUserAccounts(LoadUserAccounts event, Emitter<AccountState> emit) async {
    emit(AccountLoading());
    try {
      final accounts = await getUserAccountsUseCase.execute(event.userId);
      if (accounts.isNotEmpty) {
        emit(AccountLoaded(accounts.first, allAccounts: accounts));
      } else {
        emit(const AccountError('No accounts found'));
      }
    } catch (e) {
      emit(AccountError(e.toString()));
    }
  }

  void _onSwitchAccount(SwitchAccount event, Emitter<AccountState> emit) {
    if (state is AccountLoaded) {
      final currentState = state as AccountLoaded;
      final selected = currentState.allAccounts.firstWhere(
        (acc) => acc.id == event.accountId, 
        orElse: () => currentState.account,
      );
      emit(AccountLoaded(selected, allAccounts: currentState.allAccounts));
    }
  }
}
