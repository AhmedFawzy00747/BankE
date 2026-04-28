import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/datasources/remote_account_data_source.dart';
import '../../domain/services/location_service.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../core/utils/geo_utils.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final RemoteAccountDataSourceImpl dataSource;
  final LocationService locationService;
  final LogoutUseCase logoutUseCase;
  static const String _authKey = 'is_logged_in';

  AuthBloc({
    required this.dataSource, 
    required this.locationService,
    required this.logoutUseCase,
  }) : super(AuthInitial()) {
    on<VerifyOtpEvent>(_onVerifyOtp);
    on<SendOtpEvent>(_onSendOtp);
    on<LogoutEvent>(_onLogout);
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
    on<LoginSubmittedEvent>(_onLoginSubmitted);
    on<SignUpSubmittedEvent>(_onSignUpSubmitted);
    on<AdminLoginEvent>(_onAdminLogin);
  }

  Future<void> _onCheckAuthStatus(CheckAuthStatusEvent event, Emitter<AuthState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool(_authKey) ?? false;
    final role = prefs.getString('user_role') ?? 'user';
    
    if (isLoggedIn) {
      bool isTrusted = await _verifyLocation();
      emit(AuthSuccess(hasLocationWarning: !isTrusted, role: role));
    } else {
      emit(Unauthenticated());
    }
  }

  Future<void> _onVerifyOtp(VerifyOtpEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    await Future.delayed(const Duration(seconds: 1));
    
    if (event.enteredOtp.length < 6) {
      emit(const AuthError('Please enter all 6 digits.'));
    } else if (event.enteredOtp == event.expectedOtp) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_authKey, true);
      await prefs.setString('user_role', 'user');
      bool isTrusted = await _verifyLocation();
      emit(AuthSuccess(hasLocationWarning: !isTrusted, role: 'user'));
    } else {
      emit(const AuthError('Incorrect OTP code. Please try again.'));
    }
  }

  Future<void> _onSendOtp(SendOtpEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    await Future.delayed(const Duration(seconds: 1));
    emit(OtpSentSuccess());
  }

  Future<void> _onLoginSubmitted(LoginSubmittedEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    await Future.delayed(const Duration(seconds: 1));
    
    // Check for Admin from common login panel
    if (event.identity == 'Admin' && event.password == '1234') {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_authKey, true);
      await prefs.setString('user_role', 'admin');
      emit(const AuthSuccess(hasLocationWarning: false, role: 'admin'));
      return;
    }

    if (event.password.length < 6) {
      emit(const AuthError('Password must be at least 6 characters.'));
      return;
    }
    emit(OtpSentSuccess());
  }

  Future<void> _onSignUpSubmitted(SignUpSubmittedEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    await Future.delayed(const Duration(seconds: 1));
    
    // 1. Initial validation
    if (event.password.length < 6) {
      emit(const AuthError('Password must be at least 6 characters.'));
      return;
    }

    // 2. Mock 'Pending' registration
    dataSource.registerUser(event.name, event.email, event.phone);
    
    // 3. Trigger OTP flow start (Email first)
    emit(OtpSentSuccess());
  }

  Future<void> _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await logoutUseCase();
      await Future.delayed(const Duration(milliseconds: 500));
      emit(Unauthenticated());
    } catch (e) {
      emit(AuthError('Logout failed: ${e.toString()}'));
    }
  }

  Future<void> _onAdminLogin(AdminLoginEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    await Future.delayed(const Duration(seconds: 1));
    
    if (event.username == 'Admin' && event.password == '1234') {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_authKey, true);
      await prefs.setString('user_role', 'admin');
      emit(const AuthSuccess(hasLocationWarning: false, role: 'admin'));
    } else {
      emit(const AuthError('Invalid admin credentials'));
    }
  }

  Future<bool> _verifyLocation() async {
    try {
      final currentLoc = await locationService.getCurrentLocation();
      final trustedZones = locationService.getTrustedZones();
      for (var zone in trustedZones) {
        double dist = GeoUtils.calculateDistance(
          currentLoc['lat']!, currentLoc['lng']!, 
          zone['lat']!, zone['lng']!
        );
        if (dist <= 50.0) return true;
      }
    } catch (_) {}
    return false;
  }
}
