/// Утилиты валидации пользовательского ввода.
///
/// Все проверки — на клиенте. Backend проводит свою валидацию отдельно.
/// Возвращают null если всё ок, или строку с ошибкой на русском.
library;

import '../constants/app_constants.dart';

/// Набор статических методов для валидации форм.
class Validators {
  Validators._();

  /// Проверка логина: не пустой, минимум 3 символа
  static String? login(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Введите логин';
    }
    if (value.trim().length < 3) {
      return 'Логин должен быть не менее 3 символов';
    }
    return null;
  }

  /// Проверка пароля: не пустой, минимум 6 символов
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Введите пароль';
    }
    if (value.length < 6) {
      return 'Пароль должен быть не менее 6 символов';
    }
    return null;
  }

  /// Проверка email: базовый regex
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Введите email';
    }
    final emailRegex = RegExp(r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Некорректный email';
    }
    return null;
  }

  /// Проверка ФИО: не пустое
  static String? fullName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Введите ФИО';
    }
    if (value.trim().length < 2) {
      return 'Слишком короткое значение';
    }
    return null;
  }

  /// Проверка сообщения чата: не пустое, не длиннее лимита
  static String? chatMessage(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Сообщение не может быть пустым';
    }
    if (value.length > AppConstants.maxMessageLength) {
      return 'Сообщение слишком длинное '
          '(максимум ${AppConstants.maxMessageLength} символов)';
    }
    return null;
  }

  /// Проверка обязательного поля (generic)
  static String? required(String? value, [String fieldName = 'Поле']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName обязательно для заполнения';
    }
    return null;
  }
}
