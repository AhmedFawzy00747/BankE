import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class AuthSuccess extends AuthState {
  final bool hasLocationWarning;
  final String role;
  const AuthSuccess({this.hasLocationWarning = false, this.role = 'user'});
  @override
  List<Object?> get props => [hasLocationWarning, role];
}
class OtpSentSuccess extends AuthState {}
class Unauthenticated extends AuthState {}
class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
  @override
  List<Object?> get props => [message];
}
