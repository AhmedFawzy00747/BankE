import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../data/datasources/remote_account_data_source.dart';
import '../../../../data/models/loan_model.dart';
import 'admin_event.dart';
import 'admin_state.dart';

class AdminBloc extends Bloc<AdminEvent, AdminState> {
  final RemoteAccountDataSourceImpl dataSource;

  AdminBloc({required this.dataSource}) : super(AdminInitial()) {
    on<FetchAllUsersEvent>(_onFetchAllUsers);
    on<BlockUserEvent>(_onBlockUser);
    on<UnblockUserEvent>(_onUnblockUser);
    on<AdjustBalanceEvent>(_onAdjustBalance);
    on<UpdateLoanStatusEvent>(_onUpdateLoanStatus);
    on<LogoutAdminEvent>((event, emit) => emit(AdminInitial()));
  }

  Future<void> _onFetchAllUsers(FetchAllUsersEvent event, Emitter<AdminState> emit) async {
    emit(AdminLoading());
    try {
      final users = await dataSource.fetchAllUsers();
      final transactions = await dataSource.fetchTransactions('acc_123'); 
      final loans = await dataSource.fetchAllLoans();
      final double totalLiquidity = users.fold(0.0, (sum, item) => sum + item.balance);
      emit(AdminLoaded(users, transactions, loans, totalLiquidity));
    } catch (e) {
      emit(AdminError(e.toString()));
    }
  }

  Future<void> _onBlockUser(BlockUserEvent event, Emitter<AdminState> emit) async {
    try {
      await dataSource.blockUser(event.userId);
      emit(const AdminActionSuccess('User blocked successfully'));
      add(FetchAllUsersEvent());
    } catch (e) {
      emit(AdminError(e.toString()));
    }
  }

  Future<void> _onUnblockUser(UnblockUserEvent event, Emitter<AdminState> emit) async {
    try {
      await dataSource.unblockUser(event.userId);
      emit(const AdminActionSuccess('User unblocked successfully'));
      add(FetchAllUsersEvent());
    } catch (e) {
      emit(AdminError(e.toString()));
    }
  }

  Future<void> _onAdjustBalance(AdjustBalanceEvent event, Emitter<AdminState> emit) async {
    try {
      await dataSource.adjustBalance(event.userId, event.amount);
      emit(const AdminActionSuccess('Balance adjusted successfully'));
      add(FetchAllUsersEvent());
    } catch (e) {
      emit(AdminError(e.toString()));
    }
  }

  Future<void> _onUpdateLoanStatus(UpdateLoanStatusEvent event, Emitter<AdminState> emit) async {
    try {
      await dataSource.updateLoanStatus(
        event.loanId, 
        event.isApproved ? LoanStatus.approved : LoanStatus.rejected
      );
      emit(AdminActionSuccess('Loan ${event.isApproved ? 'approved' : 'rejected'} successfully'));
      add(FetchAllUsersEvent());
    } catch (e) {
      emit(AdminError(e.toString()));
    }
  }
}
