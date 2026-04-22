import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class VerifyOtpEvent extends AuthEvent {
  final String enteredOtp;
  final String expectedOtp;
  
  const VerifyOtpEvent(this.enteredOtp, this.expectedOtp);
  
  @override
  List<Object?> get props => [enteredOtp, expectedOtp];
}

class SendOtpEvent extends AuthEvent {
  final String destination;
  const SendOtpEvent(this.destination);
  @override
  List<Object?> get props => [destination];
}

class LoginSubmittedEvent extends AuthEvent {
  final String identity;
  final String password;
  final bool isPhone;

  const LoginSubmittedEvent({
    required this.identity,
    required this.password,
    required this.isPhone,
  });

  @override
  List<Object?> get props => [identity, password, isPhone];
}

class SignUpSubmittedEvent extends AuthEvent {
  final String name;
  final String email;
  final String phone;
  final String password;
  final String bankName;

  const SignUpSubmittedEvent({
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
    required this.bankName,
  });

  @override
  List<Object?> get props => [name, email, phone, password, bankName];
}

class LogoutEvent extends AuthEvent {}

class CheckAuthStatusEvent extends AuthEvent {}

class AdminLoginEvent extends AuthEvent {
  final String username;
  final String password;

  const AdminLoginEvent({required this.username, required this.password});

  @override
  List<Object?> get props => [username, password];
}
