import 'package:flutter_finanzasapp/data/models/user_model.dart';

/// Servicio para manejar la sesión del usuario actual
class SessionService {
  static final SessionService _instance = SessionService._internal();
  factory SessionService() => _instance;
  SessionService._internal();

  UserModel? _currentUser;

  /// Obtiene el usuario actual de la sesión
  UserModel? get currentUser => _currentUser;

  /// Obtiene el ID del usuario actual
  int? get currentUserId => _currentUser?.id;

  /// Verifica si hay un usuario logueado
  bool get isLoggedIn => _currentUser != null;

  /// Inicia sesión con un usuario
  void login(UserModel user) {
    _currentUser = user;
  }

  /// Cierra la sesión actual
  void logout() {
    _currentUser = null;
  }

  /// Verifica si el usuario actual es un emisor
  bool get isEmisor => _currentUser?.rol == 'emisor';

  /// Verifica si el usuario actual es un inversor
  bool get isInversor => _currentUser?.rol == 'inversor';
}
