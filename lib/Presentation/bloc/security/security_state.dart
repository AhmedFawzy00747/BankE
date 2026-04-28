import 'package:equatable/equatable.dart';
import '../../../domain/entities/security_activity.dart';

abstract class SecurityState extends Equatable {
  const SecurityState();

  @override
  List<Object?> get props => [];
}

class SecurityInitial extends SecurityState {}

class SecurityLoading extends SecurityState {}

class SecurityLoaded extends SecurityState {
  final bool biometricsEnabled;
  final List<SecurityActivity> activities;
  final Map<String, String> securityQuestions;

  const SecurityLoaded({
    required this.biometricsEnabled,
    required this.activities,
    required this.securityQuestions,
  });

  @override
  List<Object?> get props => [biometricsEnabled, activities, securityQuestions];

  SecurityLoaded copyWith({
    bool? biometricsEnabled,
    List<SecurityActivity>? activities,
    Map<String, String>? securityQuestions,
  }) {
    return SecurityLoaded(
      biometricsEnabled: biometricsEnabled ?? this.biometricsEnabled,
      activities: activities ?? this.activities,
      securityQuestions: securityQuestions ?? this.securityQuestions,
    );
  }
}

class SecurityError extends SecurityState {
  final String message;
  const SecurityError(this.message);

  @override
  List<Object?> get props => [message];
}
