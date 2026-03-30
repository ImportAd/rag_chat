/// Доменная сущность пользователя системы.
///
/// Содержит только те поля, которые нужны бизнес-логике.
/// Не зависит от формата JSON, базы данных или API.
library;

import 'package:equatable/equatable.dart';

/// Роль пользователя в системе.
enum UserRole {
  /// Студент — может пользоваться чатом, видит документы своей группы
  student,

  /// Сотрудник — может загружать файлы в RAG, видит документы своего отдела
  staff,

  /// Администратор — полный доступ ко всей системе
  admin,
}

/// Сущность пользователя.
///
/// Используется во всех feature: auth, chat, profile.
class User extends Equatable {
  /// Уникальный идентификатор пользователя (UUID или int от backend)
  final String id;

  /// Логин для входа в систему
  final String username;

  /// ФИО пользователя
  final String fullName;

  /// Роль в системе
  final UserRole role;

  /// Отдел или группа студентов
  final String department;

  /// Предпочитаемый язык интерфейса (на будущее)
  final String language;

  const User({
    required this.id,
    required this.username,
    required this.fullName,
    required this.role,
    required this.department,
    this.language = 'ru',
  });

  @override
  List<Object?> get props => [id, username, fullName, role, department, language];
}
