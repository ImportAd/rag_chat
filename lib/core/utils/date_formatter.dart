/// Утилиты форматирования дат для отображения в UI.
///
/// Все даты от backend приходят в ISO 8601 (UTC).
/// Здесь преобразуем их в человекочитаемый вид на русском.
library;

import 'package:intl/intl.dart';

/// Форматирование дат и времени для UI.
class DateFormatter {
  DateFormatter._();

  /// Полный формат: "15 марта 2026, 14:30"
  static String full(DateTime date) {
    return DateFormat('d MMMM yyyy, HH:mm', 'ru').format(date.toLocal());
  }

  /// Короткий формат: "15 мар 2026"
  static String short(DateTime date) {
    return DateFormat('d MMM yyyy', 'ru').format(date.toLocal());
  }

  /// Только время: "14:30"
  static String time(DateTime date) {
    return DateFormat('HH:mm', 'ru').format(date.toLocal());
  }

  /// Умный формат для списка чатов:
  /// - Сегодня: "14:30"
  /// - Вчера: "Вчера"
  /// - На этой неделе: "Пн", "Вт", ...
  /// - Ранее: "15 мар"
  static String smart(DateTime date) {
    final now = DateTime.now();
    final local = date.toLocal();
    final today = DateTime(now.year, now.month, now.day);
    final dateDay = DateTime(local.year, local.month, local.day);

    final difference = today.difference(dateDay).inDays;

    if (difference == 0) {
      return DateFormat('HH:mm').format(local);
    } else if (difference == 1) {
      return 'Вчера';
    } else if (difference < 7) {
      return DateFormat('EEEE', 'ru').format(local);
    } else {
      return DateFormat('d MMM', 'ru').format(local);
    }
  }
}

/// Группа дат для разделения списка чатов в сайдбаре.
enum ChatDateGroup {
  today('Сегодня'),
  yesterday('Вчера'),
  lastWeek('Последние 7 дней'),
  earlier('Ранее');

  final String label;
  const ChatDateGroup(this.label);
}

/// Определить группу для даты обновления чата.
ChatDateGroup chatDateGroup(DateTime date, {DateTime? now}) {
  final n = (now ?? DateTime.now()).toLocal();
  final today = DateTime(n.year, n.month, n.day);
  final local = date.toLocal();
  final day = DateTime(local.year, local.month, local.day);
  final diff = today.difference(day).inDays;

  if (diff <= 0) return ChatDateGroup.today;
  if (diff == 1) return ChatDateGroup.yesterday;
  if (diff < 7) return ChatDateGroup.lastWeek;
  return ChatDateGroup.earlier;
}
