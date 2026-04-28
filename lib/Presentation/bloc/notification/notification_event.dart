import 'package:equatable/equatable.dart';

abstract class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object?> get props => [];
}

class LoadNotificationsEvent extends NotificationEvent {}

class MarkAsReadEvent extends NotificationEvent {
  final String notificationId;
  const MarkAsReadEvent(this.notificationId);

  @override
  List<Object?> get props => [notificationId];
}

class MarkAllAsReadEvent extends NotificationEvent {}

class UpdateNotificationSettingsEvent extends NotificationEvent {
  final Map<String, bool> settings;
  const UpdateNotificationSettingsEvent(this.settings);

  @override
  List<Object?> get props => [settings];
}
