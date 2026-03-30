/// Иерархия ошибок (Failure) для всего приложения.
///
/// Используется вместе с [dartz.Either] — левая часть (Left) содержит
/// конкретный [Failure], правая (Right) — успешный результат.
/// Это позволяет обрабатывать ошибки без исключений (exception-free).
library;

import 'package:equatable/equatable.dart';

/// Базовый класс ошибки. Все конкретные ошибки наследуются от него.
abstract class Failure extends Equatable {
  /// Человекочитаемое сообщение для UI (на русском)
  final String message;

  /// Технический код ошибки (для логов и отладки)
  final String? code;

  const Failure({required this.message, this.code});

  @override
  List<Object?> get props => [message, code];
}

// ──────────────────── Серверные ошибки ────────────────────

/// Ошибка при обращении к backend API (4xx, 5xx, таймаут и т.д.)
class ServerFailure extends Failure {
  /// HTTP-статус код ответа, если есть
  final int? statusCode;

  const ServerFailure({
    required super.message,
    super.code,
    this.statusCode,
  });

  @override
  List<Object?> get props => [message, code, statusCode];
}

/// Нет подключения к интернету или серверу
class NetworkFailure extends Failure {
  const NetworkFailure({
    super.message = 'Нет подключения к серверу. Проверьте сеть.',
    super.code = 'NETWORK_ERROR',
  });
}

/// Таймаут обработки запроса (60 секунд на полный цикл)
class TimeoutFailure extends Failure {
  const TimeoutFailure({
    super.message = 'Сервер не ответил вовремя. Попробуйте позже.',
    super.code = 'TIMEOUT',
  });
}

// ──────────────────── Авторизация ────────────────────

/// Неверные учётные данные
class AuthFailure extends Failure {
  const AuthFailure({
    required super.message,
    super.code = 'AUTH_ERROR',
  });
}

/// Токен истёк и не удалось обновить
class SessionExpiredFailure extends Failure {
  const SessionExpiredFailure({
    super.message = 'Сессия истекла. Войдите заново.',
    super.code = 'SESSION_EXPIRED',
  });
}

// ──────────────────── Rate limiting ────────────────────

/// Превышен лимит запросов
class RateLimitFailure extends Failure {
  /// Через сколько секунд можно повторить запрос
  final int? retryAfterSec;

  const RateLimitFailure({
    super.message = 'Слишком много запросов. Подождите немного.',
    super.code = 'RATE_LIMIT',
    this.retryAfterSec,
  });

  @override
  List<Object?> get props => [message, code, retryAfterSec];
}

/// Система занята — очередь запросов переполнена
class SystemBusyFailure extends Failure {
  const SystemBusyFailure({
    super.message = 'Система сейчас занята, попробуйте через несколько секунд.',
    super.code = 'SYSTEM_BUSY',
  });
}

// ──────────────────── Валидация ────────────────────

/// Ошибка валидации пользовательского ввода на клиенте
class ValidationFailure extends Failure {
  const ValidationFailure({
    required super.message,
    super.code = 'VALIDATION_ERROR',
  });
}

// ──────────────────── Кэш / локальное хранение ────────────────────

/// Ошибка при работе с локальным хранилищем
class CacheFailure extends Failure {
  const CacheFailure({
    super.message = 'Ошибка локального хранилища.',
    super.code = 'CACHE_ERROR',
  });
}

// ──────────────────── Неизвестная ────────────────────

/// Неопознанная ошибка (fallback)
class UnknownFailure extends Failure {
  const UnknownFailure({
    super.message = 'Произошла непредвиденная ошибка.',
    super.code = 'UNKNOWN',
  });
}
