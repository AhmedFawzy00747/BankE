import 'package:equatable/equatable.dart';

abstract class QrState extends Equatable {
  const QrState();
  @override
  List<Object?> get props => [];
}

class QrInitial extends QrState {}

class QrLoading extends QrState {}

class QrLoaded extends QrState {
  final String qrData;
  final String accountHolderName;
  final String accountNumber;

  const QrLoaded({
    required this.qrData,
    required this.accountHolderName,
    required this.accountNumber,
  });

  @override
  List<Object?> get props => [qrData, accountHolderName, accountNumber];
}

class QrError extends QrState {
  final String message;
  const QrError(this.message);
  @override
  List<Object?> get props => [message];
}
