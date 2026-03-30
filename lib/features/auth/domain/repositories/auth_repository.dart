/// Контракт репозитория авторизации (domain layer).
///
/// Определяет ЧТО нужно делать, но НЕ КАК.
/// Реализация — в data layer [AuthRepositoryImpl].
library;

import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user.dart';

/// Абстрактный репозиторий авторизации.
///
/// Все методы возвращают [Either<Failure, T>]:
/// - Left(Failure) — ошибка с человекочитаемым сообщением
/// - Right(T) — успешный результат
abstract class AuthRepository {
  /// Вход по логину и паролю.
  /// При успехе токены сохраняются автоматически.
  Future<Either<Failure, User>> login({
    required String username,
    required String password,
  });

  /// Регистрация нового студента.
  /// Сотрудники и админы создаются вручную на backend.
  Future<Either<Failure, User>> register({
    required String username,
    required String password,
    required String fullName,
    required String department,
  });

  /// Получить данные текущего пользователя (по сохранённому токену).
  /// Используется при старте приложения для проверки сессии.
  Future<Either<Failure, User>> getCurrentUser();

  /// Выйти из системы: инвалидировать refresh-токен и очистить хранилище.
  Future<Either<Failure, void>> logout();

  /// Проверить, залогинен ли пользователь (есть ли сохранённый токен)
  bool get isLoggedIn;
}
