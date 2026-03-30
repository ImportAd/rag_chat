/// Модель пользователя для сериализации/десериализации JSON.
///
/// Расширяет доменную сущность [User] маппингом из/в JSON.
/// Используется только в data layer.
library;

import '../../domain/entities/user.dart';

/// Модель пользователя с поддержкой JSON.
class UserModel extends User {
  const UserModel({
    required super.id,
    required super.username,
    required super.fullName,
    required super.role,
    required super.department,
    super.language,
  });

  /// Создать модель из JSON-ответа backend
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'].toString(),
      username: json['username'] as String,
      fullName: json['full_name'] as String,
      role: _parseRole(json['role'] as String),
      department: json['department'] as String,
      language: json['language'] as String? ?? 'ru',
    );
  }

  /// Преобразовать модель в JSON (для отправки на backend)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'full_name': fullName,
      'role': role.name,
      'department': department,
      'language': language,
    };
  }

  /// Маппинг строковой роли из backend в enum
  static UserRole _parseRole(String role) {
    switch (role.toLowerCase()) {
      case 'student':
        return UserRole.student;
      case 'staff':
        return UserRole.staff;
      case 'admin':
        return UserRole.admin;
      default:
        return UserRole.student;
    }
  }
}
