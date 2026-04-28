import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/usecases/withdraw_money.dart';
import '../../../domain/usecases/deposit_money.dart';

// Events
abstract class AtmEvent extends Equatable {
  const AtmEvent();
  @override
  List<Object?> get props => [];
}

class WithdrawEvent extends AtmEvent {
  final String accountId;
  final double amount;
  final String pin;
  const WithdrawEvent(this.accountId, this.amount, this.pin);
  @override
  List<Object?> get props => [accountId, amount, pin];
}

class DepositEvent extends AtmEvent {
  final String accountId;
  final double amount;
  const DepositEvent(this.accountId, this.amount);
  @override
  List<Object?> get props => [accountId, amount];
}

// State
abstract class AtmState extends Equatable {
  const AtmState();
  @override
  List<Object?> get props => [];
}

class AtmInitial extends AtmState {}
class AtmLoading extends AtmState {}
class AtmSuccess extends AtmState {
  final String message;
  const AtmSuccess(this.message);
  @override
  List<Object?> get props => [message];
}
class AtmError extends AtmState {
  final String message;
  const AtmError(this.message);
  @override
  List<Object?> get props => [message];
}

// Bloc
class AtmBloc extends Bloc<AtmEvent, AtmState> {
  final WithdrawMoneyUseCase withdrawUseCase;
  final DepositMoneyUseCase depositUseCase;

  AtmBloc({
    required this.withdrawUseCase,
    required this.depositUseCase,
  }) : super(AtmInitial()) {
    on<WithdrawEvent>(_onWithdraw);
    on<DepositEvent>(_onDeposit);
  }

  Future<void> _onWithdraw(WithdrawEvent event, Emitter<AtmState> emit) async {
    if (event.pin != "1234") { // Mock PIN validation
      emit(const AtmError('Invalid PIN. Access denied.'));
      return;
    }

    emit(AtmLoading());
    try {
      await withdrawUseCase.execute(event.accountId, event.amount);
      emit(const AtmSuccess('Withdrawal successful! Please take your cash.'));
    } catch (e) {
      emit(AtmError(e.toString()));
    }
  }

  Future<void> _onDeposit(DepositEvent event, Emitter<AtmState> emit) async {
    emit(AtmLoading());
    try {
      await depositUseCase.execute(event.accountId, event.amount);
      emit(const AtmSuccess('Deposit successful! Your balance has been updated.'));
    } catch (e) {
      emit(AtmError(e.toString()));
    }
  }
}
