/// Виджет «пузыря» сообщения в чате.
///
/// Визуально различает сообщения пользователя и ИИ-ассистента.
/// Поддерживает Markdown-рендеринг, копирование и отображение источников.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../../domain/entities/chat_entities.dart';

/// Пузырь одного сообщения в чате.
class MessageBubble extends StatelessWidget {
  final Message message;

  const MessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == MessageRole.user;
    final colors = Theme.of(context).colorScheme;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.75,
        ),
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          // Пользователь — primary, ИИ — surfaceVariant
          color: isUser
              ? colors.primary.withOpacity(0.12)
              : colors.surfaceContainerHighest,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Контент сообщения ───
            if (isUser)
              // Обычный текст для сообщений пользователя
              SelectableText(
                message.content,
                style: Theme.of(context).textTheme.bodyLarge,
              )
            else
              // Markdown-рендеринг для ответов ИИ
              MarkdownBody(
                data: message.content,
                selectable: true,
                styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context))
                    .copyWith(
                  // Стили кодовых блоков
                  code: TextStyle(
                    backgroundColor: colors.surfaceContainerHigh,
                    fontFamily: 'monospace',
                    fontSize: 13,
                  ),
                  codeblockDecoration: BoxDecoration(
                    color: colors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),

            // ─── Тип источника ответа (только для ИИ) ───
            if (!isUser && message.sourceType != null) ...[
              const SizedBox(height: 8),
              _SourceTypeIndicator(sourceType: message.sourceType!),
            ],

            // ─── Источники (разворачиваемый список) ───
            if (!isUser &&
                message.sources != null &&
                message.sources!.isNotEmpty) ...[
              const SizedBox(height: 8),
              _SourcesList(sources: message.sources!),
            ],

            // ─── Кнопка копирования (для ответов ИИ) ───
            if (!isUser) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: InkWell(
                  borderRadius: BorderRadius.circular(4),
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: message.content));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Ответ скопирован'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.copy, size: 14, color: colors.outline),
                        const SizedBox(width: 4),
                        Text(
                          'Копировать',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: colors.outline,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─────────────────── Индикатор типа источника ───────────────────

/// Показывает тип источника ответа: RAG найден / не найден / без RAG.
class _SourceTypeIndicator extends StatelessWidget {
  final SourceType sourceType;

  const _SourceTypeIndicator({required this.sourceType});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    late final IconData icon;
    late final String label;
    late final Color color;

    switch (sourceType) {
      case SourceType.ragFound:
        icon = Icons.check_circle_outline;
        label = 'Информация найдена в базе знаний';
        color = Colors.green;
        break;
      case SourceType.ragNotFound:
        icon = Icons.info_outline;
        label = 'Информация не найдена в базе знаний';
        color = Colors.orange;
        break;
      case SourceType.noRag:
        icon = Icons.auto_awesome;
        label = 'Ответ без опоры на внутреннюю базу';
        color = colors.primary;
        break;
      case SourceType.offTopic:
        icon = Icons.explore_off_outlined;
        label = 'Запрос вне тематики базы знаний';
        color = Colors.deepOrange;
        break;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: color,
                  fontStyle: FontStyle.italic,
                ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────── Список источников ───────────────────

/// Разворачиваемый список источников (документов), на которых основан ответ.
class _SourcesList extends StatelessWidget {
  final List<Source> sources;

  const _SourcesList({required this.sources});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Theme(
      // Убираем divider у ExpansionTile
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        childrenPadding: const EdgeInsets.only(left: 8),
        title: Text(
          'Источники (${sources.length})',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: colors.primary,
              ),
        ),
        leading: Icon(Icons.menu_book, size: 16, color: colors.primary),
        children: sources.map((source) {
          return ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading:
                Icon(Icons.description_outlined, size: 16, color: colors.outline),
            title: Text(
              source.documentName,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            subtitle: source.description != null
                ? Text(
                    source.description!,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  )
                : null,
          );
        }).toList(),
      ),
    );
  }
}
