import 'package:shared_preferences/shared_preferences.dart';
import '../../data/datasources/mock_account_data_source.dart';

class LogoutUseCase {
  final AccountDataSource dataSource;
  
  LogoutUseCase(this.dataSource);

  static const String _authKey = 'is_logged_in';
  static const String _roleKey = 'user_role';

  Future<void> call() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_authKey, false);
    await prefs.remove(_roleKey);
    dataSource.reset();
  }
}
