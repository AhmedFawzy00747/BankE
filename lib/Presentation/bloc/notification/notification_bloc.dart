import 'package:flutter_bloc/flutter_bloc.dart';
import 'notification_event.dart';
import 'notification_state.dart';
import '../../../domain/entities/notification_entity.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  NotificationBloc() : super(NotificationInitial()) {
    on<LoadNotificationsEvent>(_onLoadNotifications);
    on<MarkAsReadEvent>(_onMarkAsRead);
    on<MarkAllAsReadEvent>(_onMarkAllAsRead);
    on<UpdateNotificationSettingsEvent>(_onUpdateSettings);
  }

  void _onLoadNotifications(LoadNotificationsEvent event, Emitter<NotificationState> emit) {
    emit(NotificationLoading());
    
    final notifications = [
      NotificationEntity(
        id: '1',
        title: 'Salary Credited',
        message: 'Your account has been credited with \$5,000.00 from Tech Corp.',
        timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
        type: NotificationType.transaction,
      ),
      NotificationEntity(
        id: '2',
        title: 'New Promotion',
        message: 'Get 10% cashback on all utility bill payments this month!',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        type: NotificationType.promotion,
        isRead: true,
      ),
      NotificationEntity(
        id: '3',
        title: 'Security Alert',
        message: 'New login detected from a MacBook Pro in London, UK.',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        type: NotificationType.security,
      ),
      NotificationEntity(
        id: '4',
        title: 'System Update',
        message: 'Scheduled maintenance on Sunday from 02:00 AM to 04:00 AM.',
        timestamp: DateTime.now().subtract(const Duration(days: 2)),
        type: NotificationType.system,
        isRead: true,
      ),
    ];

    emit(NotificationLoaded(
      notifications: notifications,
      settings: const {
        'Transactions': true,
        'Promotions': true,
        'Security': true,
        'System': false,
      },
    ));
  }

  void _onMarkAsRead(MarkAsReadEvent event, Emitter<NotificationState> emit) {
    if (state is NotificationLoaded) {
      final current = state as NotificationLoaded;
      final updated = current.notifications.map((n) {
        if (n.id == event.notificationId) {
          return n.copyWith(isRead: true);
        }
        return n;
      }).toList();
      emit(current.copyWith(notifications: updated));
    }
  }

  void _onMarkAllAsRead(MarkAllAsReadEvent event, Emitter<NotificationState> emit) {
    if (state is NotificationLoaded) {
      final current = state as NotificationLoaded;
      final updated = current.notifications.map((n) => n.copyWith(isRead: true)).toList();
      emit(current.copyWith(notifications: updated));
    }
  }

  void _onUpdateSettings(UpdateNotificationSettingsEvent event, Emitter<NotificationState> emit) {
    if (state is NotificationLoaded) {
      emit((state as NotificationLoaded).copyWith(settings: event.settings));
    }
  }
}
