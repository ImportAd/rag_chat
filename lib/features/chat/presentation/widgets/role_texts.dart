/// Тексты welcome-экрана и плейсхолдеры по роли (студент / сотрудник / админ).
///
/// Бэкенд тоже умеет вставлять приветствие при первом /send — UI это
/// фильтрует по message_count. Здесь — локальные шаблоны для мгновенного
/// показа welcome-экрана без запроса к серверу.
library;

import '../../../auth/domain/entities/user.dart';

/// Промпт-карточка на welcome-экране.
class WelcomePrompt {
  /// Эмодзи-иконка слева (24×24 в плашке accentBg).
  final String emoji;

  /// Заголовок (13.5 / 500).
  final String title;

  /// Подсказка (12 / muted).
  final String hint;

  const WelcomePrompt({
    required this.emoji,
    required this.title,
    required this.hint,
  });
}

class RoleTexts {
  RoleTexts._();

  // ═══════════════════════ Welcome ═══════════════════════

  /// Главный заголовок welcome-экрана: «Здравствуйте, Иван» / «Добрый день, …».
  ///
  /// Для студента — обращение по имени, для сотрудника — по имени-отчеству,
  /// fallback — первое слово из ФИО или просто «Здравствуйте!».
  static String welcomeTitle(User user) {
    final parts = user.fullName.trim().split(RegExp(r'\s+'));
    switch (user.role) {
      case UserRole.student:
        // Имя у нас — второе слово в ФИО («Фамилия Имя Отчество»).
        final firstName = parts.length >= 2 ? parts[1] : parts.first;
        return 'Здравствуйте, $firstName';
      case UserRole.staff:
      case UserRole.admin:
        if (parts.length >= 3) {
          return 'Добрый день, ${parts[1]} ${parts[2]}';
        }
        if (parts.length == 2) {
          return 'Добрый день, ${parts[1]}';
        }
        return 'Добрый день!';
    }
  }

  /// Подзаголовок welcome-экрана.
  static String welcomeSubtitle(UserRole role) {
    switch (role) {
      case UserRole.student:
        return 'Спросите об учёбе, расписании, документах — '
            'ассистент найдёт ответ во внутренней базе университета.';
      case UserRole.staff:
      case UserRole.admin:
        return 'Задайте вопрос о нормативных актах, процедурах, '
            'регламентах и календаре — ответ опирается на внутренние документы.';
    }
  }

  // ═══════════════════════ Промпт-карточки 2×2 ═══════════════════════

  static const List<WelcomePrompt> _student = [
    WelcomePrompt(
      emoji: '📅',
      title: 'Когда начинается сессия?',
      hint: 'Сроки зимней и летней экзаменационных сессий',
    ),
    WelcomePrompt(
      emoji: '📄',
      title: 'Как получить справку с места учёбы?',
      hint: 'Через личный кабинет или деканат',
    ),
    WelcomePrompt(
      emoji: '🎓',
      title: 'Правила пересдачи экзаменов',
      hint: 'Порядок, сроки, допуски',
    ),
    WelcomePrompt(
      emoji: '📚',
      title: 'Требования к курсовой работе',
      hint: 'Оформление, сроки, научный руководитель',
    ),
  ];

  static const List<WelcomePrompt> _staff = [
    WelcomePrompt(
      emoji: '📄',
      title: 'Регламент рабочего времени',
      hint: 'Графики, учёт, отпуска',
    ),
    WelcomePrompt(
      emoji: '⚖️',
      title: 'Процедура утверждения УМК',
      hint: 'Этапы согласования и сроки',
    ),
    WelcomePrompt(
      emoji: '📚',
      title: 'Положение о научной работе',
      hint: 'Публикации, конференции, отчётность',
    ),
    WelcomePrompt(
      emoji: '📅',
      title: 'Календарь заседаний кафедры',
      hint: 'Ближайшие и регулярные',
    ),
  ];

  static List<WelcomePrompt> prompts(UserRole role) {
    switch (role) {
      case UserRole.student:
        return _student;
      case UserRole.staff:
      case UserRole.admin:
        return _staff;
    }
  }

  // ═══════════════════════ Плейсхолдер input'а ═══════════════════════

  static const String inputHintStudent = 'Спросите у ассистента…';
  static const String inputHintStaff = 'Спросите у ассистента…';

  static String inputHint(UserRole role) {
    switch (role) {
      case UserRole.student:
        return inputHintStudent;
      case UserRole.staff:
      case UserRole.admin:
        return inputHintStaff;
    }
  }
}
