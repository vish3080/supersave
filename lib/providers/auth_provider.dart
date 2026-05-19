import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';

class AuthProvider extends ChangeNotifier {
  bool _isAuthenticated = false;
  String? _userId;
  bool _isLoading = false;
  String? _errorMessage;

  bool get isAuthenticated => _isAuthenticated;
  String? get userId => _userId;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  AuthProvider() {
    final session = Supabase.instance.client.auth.currentSession;
    _isAuthenticated = session != null;
    _userId = session?.user.id;

    AuthService.shared.authStateChanges.listen((data) {
      switch (data.event) {
        case AuthChangeEvent.signedIn:
        case AuthChangeEvent.tokenRefreshed:
        case AuthChangeEvent.userUpdated:
          _isAuthenticated = true;
          _userId = data.session?.user.id;
          break;
        case AuthChangeEvent.signedOut:
        case AuthChangeEvent.userDeleted:
          _isAuthenticated = false;
          _userId = null;
          break;
        default:
          break;
      }
      notifyListeners();
    });
  }

  Future<void> signUp(String email, String password) async {
    _setLoading(true);
    try {
      await AuthService.shared.signUp(email, password);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    }
    _setLoading(false);
  }

  Future<void> signIn(String email, String password) async {
    _setLoading(true);
    try {
      await AuthService.shared.signIn(email, password);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    }
    _setLoading(false);
  }

  Future<void> signOut() async {
    await AuthService.shared.signOut();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }
}
