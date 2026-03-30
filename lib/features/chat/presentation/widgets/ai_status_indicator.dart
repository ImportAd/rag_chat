/// Индикатор текущего статуса обработки запроса ИИ.
///
/// Показывает пользователю, что именно сейчас делает система,
/// чтобы не было ощущения «зависания».
library;

import 'package:flutter/material.dart';
import '../../domain/entities/chat_entities.dart';

/// Анимированная строка статуса обработки ИИ.
class AiStatusIndicator extends StatelessWidget {
  /// Текущий статус обработки
  final MessageStatus status;

  const AiStatusIndicator({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Анимированный спиннер
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: colors.primary,
            ),
          ),
          const SizedBox(width: 10),

          // Текст статуса
          Text(
            _statusText,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                ),
          ),
        ],
      ),
    );
  }

  /// Человекочитаемый текст для каждого статуса
  String get _statusText {
    switch (status) {
      case MessageStatus.sent:
        return 'Запрос отправлен...';
      case MessageStatus.searching:
        return 'Идёт поиск по базе знаний...';
      case MessageStatus.refining:
        return 'Уточняю поиск...';
      case MessageStatus.generating:
        return 'Генерация ответа...';
      case MessageStatus.completed:
        return 'Ответ получен';
      case MessageStatus.error:
        return 'Ошибка при обработке';
    }
  }
}
