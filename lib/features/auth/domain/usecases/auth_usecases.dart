/// Use case'ы авторизации.
///
/// Каждый use case — одно действие. Вызывается из BLoC,
/// делегирует работу в репозиторий.
library;

import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// Use case: вход в систему по логину и паролю.
class LoginUseCase {
  final AuthRepository _repository;

  LoginUseCase(this._repository);

  /// Выполнить вход. Возвращает [User] при успехе или [Failure] при ошибке.
  Future<Either<Failure, User>> call({
    required String username,
    required String password,
  }) {
    return _repository.login(username: username, password: password);
  }
}

/// Use case: регистрация нового студента.
class RegisterUseCase {
  final AuthRepository _repository;

  RegisterUseCase(this._repository);

  /// Зарегистрировать нового пользователя (только студенты).
  Future<Either<Failure, User>> call({
    required String username,
    required String password,
    required String fullName,
    required String department,
  }) {
    return _repository.register(
      username: username,
      password: password,
      fullName: fullName,
      department: department,
    );
  }
}

/// Use case: получить текущего пользователя (проверка сессии).
class GetCurrentUserUseCase {
  final AuthRepository _repository;

  GetCurrentUserUseCase(this._repository);

  /// Получить данные текущего пользователя по сохранённому токену.
  Future<Either<Failure, User>> call() {
    return _repository.getCurrentUser();
  }
}

/// Use case: выход из системы.
class LogoutUseCase {
  final AuthRepository _repository;

  LogoutUseCase(this._repository);

  /// Разлогинить пользователя, очистить токены.
  Future<Either<Failure, void>> call() {
    return _repository.logout();
  }
}
