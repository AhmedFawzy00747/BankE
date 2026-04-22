import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../data/datasources/mock_account_data_source.dart';
import 'loan_event.dart';
import 'loan_state.dart';

class LoanBloc extends Bloc<LoanEvent, LoanState> {
  final MockAccountDataSourceImpl dataSource;

  LoanBloc({required this.dataSource}) : super(LoanInitial()) {
    on<SubmitLoanRequestEvent>(_onSubmitLoan);
  }

  Future<void> _onSubmitLoan(SubmitLoanRequestEvent event, Emitter<LoanState> emit) async {
    emit(LoanSubmitting());
    try {
      await dataSource.submitLoanRequest(
        event.userId,
        event.userName,
        event.amount,
        event.purpose,
        event.durationMonths,
        event.pdfFileName,
      );
      emit(const LoanSubmitSuccess('Loan request submitted successfully!'));
    } catch (e) {
      emit(LoanSubmitError('Failed to submit loan: $e'));
    }
  }
}
