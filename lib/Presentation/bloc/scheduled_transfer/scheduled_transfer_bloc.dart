import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/schedule_transfer_usecase.dart';
import '../../../domain/usecases/get_scheduled_transfers_usecase.dart';
import '../../../domain/usecases/cancel_scheduled_transfer_usecase.dart';
import 'scheduled_transfer_event.dart';
import 'scheduled_transfer_state.dart';

class ScheduledTransferBloc extends Bloc<ScheduledTransferEvent, ScheduledTransferState> {
  final ScheduleTransferUseCase scheduleTransferUseCase;
  final GetScheduledTransfersUseCase getScheduledTransfersUseCase;
  final CancelScheduledTransferUseCase cancelScheduledTransferUseCase;

  ScheduledTransferBloc({
    required this.scheduleTransferUseCase,
    required this.getScheduledTransfersUseCase,
    required this.cancelScheduledTransferUseCase,
  }) : super(ScheduledTransferInitial()) {
    on<LoadScheduledTransfers>(_onLoadScheduledTransfers);
    on<ScheduleNewTransfer>(_onScheduleNewTransfer);
    on<CancelTransfer>(_onCancelTransfer);
  }

  Future<void> _onLoadScheduledTransfers(
    LoadScheduledTransfers event,
    Emitter<ScheduledTransferState> emit,
  ) async {
    emit(ScheduledTransferLoading());
    try {
      final transfers = await getScheduledTransfersUseCase.execute(event.accountId);
      emit(ScheduledTransferLoaded(transfers));
    } catch (e) {
      emit(ScheduledTransferError(e.toString()));
    }
  }

  Future<void> _onScheduleNewTransfer(
    ScheduleNewTransfer event,
    Emitter<ScheduledTransferState> emit,
  ) async {
    emit(ScheduledTransferLoading());
    try {
      await scheduleTransferUseCase.execute(event.transfer);
      emit(const ScheduledTransferOperationSuccess("Transfer scheduled successfully"));
      // A caller will typically trigger LoadScheduledTransfers if they need to refresh
    } catch (e) {
      emit(ScheduledTransferError(e.toString()));
    }
  }

  Future<void> _onCancelTransfer(
    CancelTransfer event,
    Emitter<ScheduledTransferState> emit,
  ) async {
    emit(ScheduledTransferLoading());
    try {
      await cancelScheduledTransferUseCase.execute(event.transferId);
      emit(const ScheduledTransferOperationSuccess("Transfer cancelled successfully"));
      add(LoadScheduledTransfers(event.accountId));
    } catch (e) {
      emit(ScheduledTransferError(e.toString()));
    }
  }
}
