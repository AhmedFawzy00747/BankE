import 'package:flutter_bloc/flutter_bloc.dart';
import 'security_event.dart';
import 'security_state.dart';
import '../../../domain/entities/security_activity.dart';

class SecurityBloc extends Bloc<SecurityEvent, SecurityState> {
  SecurityBloc() : super(SecurityInitial()) {
    on<LoadSecuritySettingsEvent>(_onLoadSettings);
    on<ToggleBiometricsEvent>(_onToggleBiometrics);
    on<RemoteLogoutEvent>(_onRemoteLogout);
    on<UpdateSecurityQuestionsEvent>(_onUpdateQuestions);
  }

  void _onLoadSettings(LoadSecuritySettingsEvent event, Emitter<SecurityState> emit) {
    emit(SecurityLoading());
    // Simulate loading mock data
    final activities = [
      SecurityActivity(
        id: '1',
        deviceName: 'iPhone 15 Pro',
        location: 'New York, USA',
        ipAddress: '192.168.1.1',
        timestamp: DateTime.now(),
        isCurrentDevice: true,
      ),
      SecurityActivity(
        id: '2',
        deviceName: 'MacBook Pro 16',
        location: 'London, UK',
        ipAddress: '172.16.0.42',
        timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      ),
      SecurityActivity(
        id: '3',
        deviceName: 'Samsung Galaxy S23',
        location: 'Dubai, UAE',
        ipAddress: '10.0.0.15',
        timestamp: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ];

    emit(SecurityLoaded(
      biometricsEnabled: true,
      activities: activities,
      securityQuestions: const {
        'What was your first pet\'s name?': 'Buddy',
        'What city were you born in?': 'Cairo',
      },
    ));
  }

  void _onToggleBiometrics(ToggleBiometricsEvent event, Emitter<SecurityState> emit) {
    if (state is SecurityLoaded) {
      emit((state as SecurityLoaded).copyWith(biometricsEnabled: event.enabled));
    }
  }

  void _onRemoteLogout(RemoteLogoutEvent event, Emitter<SecurityState> emit) {
    if (state is SecurityLoaded) {
      final current = state as SecurityLoaded;
      final updated = current.activities.where((a) => a.id != event.deviceId).toList();
      emit(current.copyWith(activities: updated));
    }
  }

  void _onUpdateQuestions(UpdateSecurityQuestionsEvent event, Emitter<SecurityState> emit) {
    if (state is SecurityLoaded) {
      emit((state as SecurityLoaded).copyWith(securityQuestions: event.questions));
    }
  }
}
