import 'package:equatable/equatable.dart';
import '../../../domain/entities/notification_entity.dart';

abstract class NotificationState extends Equatable {
  const NotificationState();

  @override
  List<Object?> get props => [];
}

class NotificationInitial extends NotificationState {}

class NotificationLoading extends NotificationState {}

class NotificationLoaded extends NotificationState {
  final List<NotificationEntity> notifications;
  final Map<String, bool> settings;

  const NotificationLoaded({
    required this.notifications,
    required this.settings,
  });

  @override
  List<Object?> get props => [notifications, settings];

  int get unreadCount => notifications.where((n) => !n.isRead).length;

  NotificationLoaded copyWith({
    List<NotificationEntity>? notifications,
    Map<String, bool>? settings,
  }) {
    return NotificationLoaded(
      notifications: notifications ?? this.notifications,
      settings: settings ?? this.settings,
    );
  }
}

class NotificationError extends NotificationState {
  final String message;
  const NotificationError(this.message);

  @override
  List<Object?> get props => [message];
}
