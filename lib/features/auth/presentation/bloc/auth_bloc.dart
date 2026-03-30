/// BLoC авторизации: события, состояния и бизнес-логика.
///
/// Управляет полным циклом: вход, регистрация, проверка сессии, выход.
library;

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/user.dart';
import '../../domain/usecases/auth_usecases.dart';

// ═══════════════════════ СОБЫТИЯ ═══════════════════════

/// Базовый класс событий авторизации.
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Проверка текущей сессии при запуске приложения.
class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

/// Запрос на вход по логину и паролю.
class AuthLoginRequested extends AuthEvent {
  final String username;
  final String password;

  const AuthLoginRequested({
    required this.username,
    required this.password,
  });

  @override
  List<Object?> get props => [username, password];
}

/// Запрос на регистрацию нового студента.
class AuthRegisterRequested extends AuthEvent {
  final String username;
  final String password;
  final String fullName;
  final String department;

  const AuthRegisterRequested({
    required this.username,
    required this.password,
    required this.fullName,
    required this.department,
  });

  @override
  List<Object?> get props => [username, password, fullName, department];
}

/// Запрос на выход из системы.
class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

// ═══════════════════════ СОСТОЯНИЯ ═══════════════════════

/// Базовый класс состояний авторизации.
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Начальное состояние (приложение запускается)
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Идёт проверка / загрузка
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// Пользователь успешно авторизован
class AuthAuthenticated extends AuthState {
  /// Данные текущего пользователя
  final User user;

  const AuthAuthenticated(this.user);

  @override
  List<Object?> get props => [user];
}

/// Пользователь не авторизован (нет токена или токен протух)
class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// Ошибка при авторизации
class AuthError extends AuthState {
  /// Текст ошибки для отображения пользователю
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

// ═══════════════════════ BLOC ═══════════════════════

/// BLoC управления авторизацией.
///
/// Реагирует на события [AuthEvent], меняет состояние [AuthState].
/// Используется глобально на уровне всего приложения.
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase _loginUseCase;
  final RegisterUseCase _registerUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  final LogoutUseCase _logoutUseCase;

  AuthBloc({
    required LoginUseCase loginUseCase,
    required RegisterUseCase registerUseCase,
    required GetCurrentUserUseCase getCurrentUserUseCase,
    required LogoutUseCase logoutUseCase,
  })  : _loginUseCase = loginUseCase,
        _registerUseCase = registerUseCase,
        _getCurrentUserUseCase = getCurrentUserUseCase,
        _logoutUseCase = logoutUseCase,
        super(const AuthInitial()) {
    // Регистрируем обработчики событий
    on<AuthCheckRequested>(_onCheckRequested);
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthRegisterRequested>(_onRegisterRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
  }

  /// Обработка: проверка текущей сессии
  Future<void> _onCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await _getCurrentUserUseCase();

    result.fold(
      // Токена нет или он протух — пользователь не авторизован
      (failure) => emit(const AuthUnauthenticated()),
      // Токен валидный — пользователь авторизован
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  /// Обработка: вход по логину и паролю
  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await _loginUseCase(
      username: event.username,
      password: event.password,
    );

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  /// Обработка: регистрация нового студента
  Future<void> _onRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await _registerUseCase(
      username: event.username,
      password: event.password,
      fullName: event.fullName,
      department: event.department,
    );

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  /// Обработка: выход из системы
  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _logoutUseCase();
    emit(const AuthUnauthenticated());
  }
}
