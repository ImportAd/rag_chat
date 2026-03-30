/// Конфигурация текстов, зависящих от роли пользователя.
///
/// Приветственные сообщения, плейсхолдеры ввода, текст пустых состояний.
/// Определяется ролью из [User.role] (student / staff / admin).
///
/// Два варианта работы приветствия:
/// (а) Бэкенд вставляет greeting при первом /send — фронтенд просто рендерит.
/// (б) Фронтенд показывает локальный шаблон сразу (быстрее, без запроса).
/// Мы используем вариант (б) для мгновенного отклика, но бэкенд тоже
/// вставит приветствие — дубликат фильтруется по message_count.
library;

import '../../../auth/domain/entities/user.dart';

/// Тексты, зависящие от роли пользователя.
class RoleTexts {
  RoleTexts._();

  // ═══════════════════════ Приветствия ═══════════════════════

  /// Приветственное сообщение для студентов.
  ///
  /// Отображается при создании нового чата / открытии пустого диалога.
  /// Дружелюбный тон, фокус на учёбу и право.
  static const String greetingStudent =
      'Привет! Я помощник Университета Правосудия. '
      'Могу помочь с вопросами по учёбе, предметам, расписанию и праву. '
      'Задайте свой вопрос!';

  /// Приветственное сообщение для сотрудников.
  ///
  /// Деловой тон, фокус на рабочие документы.
  static const String greetingStaff =
      'Здравствуйте! Я ИИ-помощник для работы с документами. '
      'Могу найти информацию в загруженных документах вашего отдела. '
      'Чем могу помочь?';

  /// Получить приветствие по роли
  static String greeting(UserRole role) {
    switch (role) {
      case UserRole.student:
        return greetingStudent;
      case UserRole.staff:
      case UserRole.admin:
        return greetingStaff;
    }
  }

  // ═══════════════════════ Плейсхолдеры ввода ═══════════════════════

  /// Плейсхолдер поля ввода для студентов.
  static const String inputHintStudent =
      'Задайте вопрос по учёбе или праву...';

  /// Плейсхолдер поля ввода для сотрудников.
  static const String inputHintStaff =
      'Поиск по рабочим документам...';

  /// Получить плейсхолдер по роли
  static String inputHint(UserRole role) {
    switch (role) {
      case UserRole.student:
        return inputHintStudent;
      case UserRole.staff:
      case UserRole.admin:
        return inputHintStaff;
    }
  }

  // ═══════════════════════ Пустые состояния ═══════════════════════

  /// Текст кнопки / описания при пустом чате — студент
  static const String emptyChatSubtitleStudent =
      'Задайте вопрос по учёбе, предметам или праву';

  /// Текст кнопки / описания при пустом чате — сотрудник
  static const String emptyChatSubtitleStaff =
      'Спросите о содержимом документов вашего отдела';

  /// Получить текст пустого чата по роли
  static String emptyChatSubtitle(UserRole role) {
    switch (role) {
      case UserRole.student:
        return emptyChatSubtitleStudent;
      case UserRole.staff:
      case UserRole.admin:
        return emptyChatSubtitleStaff;
    }
  }
}
