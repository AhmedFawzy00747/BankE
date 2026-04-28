import 'dart:developer' as dev;
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../domain/usecases/submit_loan_request.dart';
import '../../../../domain/usecases/get_loans.dart';
import '../../../../domain/usecases/update_loan_status.dart';
import '../../../../domain/usecases/calculate_loan_emi.dart';
import 'loan_event.dart';
import 'loan_state.dart';

class LoanBloc extends Bloc<LoanEvent, LoanState> {
  final SubmitLoanRequestUseCase submitLoanRequestUseCase;
  final GetLoansUseCase getLoansUseCase;
  final UpdateLoanStatusUseCase updateLoanStatusUseCase;
  final CalculateLoanEMI calculateLoanEMI;

  LoanBloc({
    required this.submitLoanRequestUseCase,
    required this.getLoansUseCase,
    required this.updateLoanStatusUseCase,
    required this.calculateLoanEMI,
  }) : super(const LoanStatusUpdateState()) {
    on<CalculateEMIEvent>(_onCalculateEMI);
    on<SubmitLoanRequestEvent>(_onSubmitLoan);
    on<FetchLoansEvent>(_onFetchLoans);
    on<UpdateLoanStatusEvent>(_onUpdateLoanStatus);
  }

  LoanStatusUpdateState _mapToUpdateState(LoanState state) {
    if (state is LoanStatusUpdateState) return state;
    return LoanStatusUpdateState(
      loans: state.loans,
      estimatedEmi: state.estimatedEmi,
      submissionStatus: state.submissionStatus,
      uploadProgress: state.uploadProgress,
      isLoading: state.isLoading,
      errorMessage: state.errorMessage,
      successMessage: state.successMessage,
    );
  }

  void _onCalculateEMI(CalculateEMIEvent event, Emitter<LoanState> emit) {
    final emi = calculateLoanEMI.execute(
      amount: event.amount,
      durationMonths: event.durationMonths,
      annualRate: event.annualRate,
    );
    
    final current = _mapToUpdateState(state);
    emit(current.copyWith(estimatedEmi: emi));
  }

  Future<void> _onSubmitLoan(SubmitLoanRequestEvent event, Emitter<LoanState> emit) async {
    dev.log('LoanBloc: Submitting loan request for ${event.userName}', name: 'LoanBloc');
    
    final current = _mapToUpdateState(state);

    emit(current.copyWith(
      submissionStatus: LoanSubmissionStatus.submitting,
      uploadProgress: 0.1,
      isLoading: true,
      errorMessage: null,
      successMessage: null,
    ));

    try {
      await Future.delayed(const Duration(milliseconds: 500));
      emit(_mapToUpdateState(state).copyWith(uploadProgress: 0.5));

      await submitLoanRequestUseCase.execute(
        userId: event.userId,
        userName: event.userName,
        amount: event.amount,
        purpose: event.purpose,
        duration: event.durationMonths,
        pdfName: event.pdfFileName,
        pdfPath: event.pdfFilePath,
      );
      
      dev.log('LoanBloc: Loan request submitted successfully', name: 'LoanBloc');
      
      final updatedLoans = await getLoansUseCase.execute();
      
      emit(_mapToUpdateState(state).copyWith(
        submissionStatus: LoanSubmissionStatus.success,
        successMessage: 'Loan request submitted successfully!',
        uploadProgress: 1.0,
        isLoading: false,
        loans: updatedLoans,
      ));
    } catch (e) {
      dev.log('LoanBloc: Error submitting loan: $e', name: 'LoanBloc', error: e);
      emit(_mapToUpdateState(state).copyWith(
        submissionStatus: LoanSubmissionStatus.error,
        errorMessage: 'Failed to submit loan: $e',
        uploadProgress: 0.0,
        isLoading: false,
      ));
    }
  }

  Future<void> _onFetchLoans(FetchLoansEvent event, Emitter<LoanState> emit) async {
    dev.log('LoanBloc: Fetching all loans', name: 'LoanBloc');
    final current = _mapToUpdateState(state);
    emit(current.copyWith(isLoading: true));
    
    try {
      final loans = await getLoansUseCase.execute();
      dev.log('LoanBloc: API response received. Loans count: ${loans.length}', name: 'LoanBloc');
      
      emit(_mapToUpdateState(state).copyWith(
        loans: loans,
        isLoading: false,
      ));
    } catch (e) {
      dev.log('LoanBloc: Error fetching loans: $e', name: 'LoanBloc', error: e);
      emit(_mapToUpdateState(state).copyWith(
        errorMessage: 'Failed to fetch loans: $e',
        isLoading: false,
      ));
    }
  }

  Future<void> _onUpdateLoanStatus(UpdateLoanStatusEvent event, Emitter<LoanState> emit) async {
    final current = _mapToUpdateState(state);
    emit(current.copyWith(isLoading: true));
    
    try {
      await updateLoanStatusUseCase.execute(event.loanId, event.status);
      final updatedLoans = await getLoansUseCase.execute();
      
      emit(_mapToUpdateState(state).copyWith(
        loans: updatedLoans,
        isLoading: false,
      ));
    } catch (e) {
      dev.log('LoanBloc: Error updating loan status: $e', name: 'LoanBloc', error: e);
      emit(_mapToUpdateState(state).copyWith(
        errorMessage: 'Failed to update loan: $e',
        isLoading: false,
      ));
    }
  }

  @override
  void onTransition(Transition<LoanEvent, LoanState> transition) {
    super.onTransition(transition);
    dev.log('LoanBloc Transition: ${transition.currentState.runtimeType} -> ${transition.nextState.runtimeType}', name: 'LoanBloc');
  }
}
