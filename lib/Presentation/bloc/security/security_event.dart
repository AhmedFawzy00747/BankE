import 'package:equatable/equatable.dart';

abstract class SecurityEvent extends Equatable {
  const SecurityEvent();

  @override
  List<Object?> get props => [];
}

class LoadSecuritySettingsEvent extends SecurityEvent {}

class ToggleBiometricsEvent extends SecurityEvent {
  final bool enabled;
  const ToggleBiometricsEvent(this.enabled);

  @override
  List<Object?> get props => [enabled];
}

class RemoteLogoutEvent extends SecurityEvent {
  final String deviceId;
  const RemoteLogoutEvent(this.deviceId);

  @override
  List<Object?> get props => [deviceId];
}

class UpdateSecurityQuestionsEvent extends SecurityEvent {
  final Map<String, String> questions;
  const UpdateSecurityQuestionsEvent(this.questions);

  @override
  List<Object?> get props => [questions];
}
