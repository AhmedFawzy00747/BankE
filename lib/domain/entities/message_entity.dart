import 'package:equatable/equatable.dart';

class MessageEntity extends Equatable {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;

  final String? attachmentPath;

  const MessageEntity({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.attachmentPath,
  });

  @override
  List<Object?> get props => [id, text, isUser, timestamp];
}
