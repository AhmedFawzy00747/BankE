import 'package:flutter_bloc/flutter_bloc.dart';
import 'qr_event.dart';
import 'qr_state.dart';

class QrBloc extends Bloc<QrEvent, QrState> {
  QrBloc() : super(QrInitial()) {
    on<GenerateQrEvent>(_onGenerateQr);
  }

  Future<void> _onGenerateQr(GenerateQrEvent event, Emitter<QrState> emit) async {
    emit(QrLoading());
    try {
      // Simulate API delay
      await Future.delayed(const Duration(seconds: 1));
      
      // If data is missing, use mock data as per requirements
      final userId = event.userId ?? "user_mock_123";
      final accountId = event.accountId ?? "ACC-99887766";
      final name = "Mock User"; // Fallback name
      
      final qrData = "$userId|$accountId";
      
      emit(QrLoaded(
        qrData: qrData,
        accountHolderName: name,
        accountNumber: accountId,
      ));
    } catch (e) {
      emit(QrError("Failed to generate QR: ${e.toString()}"));
    }
  }
}
