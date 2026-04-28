import 'package:equatable/equatable.dart';

abstract class QrEvent extends Equatable {
  const QrEvent();
  @override
  List<Object?> get props => [];
}

class GenerateQrEvent extends QrEvent {
  final String? userId;
  final String? accountId;
  const GenerateQrEvent({this.userId, this.accountId});
  @override
  List<Object?> get props => [userId, accountId];
}
