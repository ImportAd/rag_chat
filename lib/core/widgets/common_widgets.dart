/// Общие переиспользуемые виджеты для всего приложения.
///
/// Содержит виджеты, которые не привязаны к конкретной feature,
/// но используются в нескольких местах: лоадеры, пустые состояния и т.д.
library;

import 'package:flutter/material.dart';

// ─────────────────── Индикатор загрузки ───────────────────

/// Полноэкранный индикатор загрузки с опциональным сообщением.
class AppLoader extends StatelessWidget {
  /// Текст под спиннером (например, «Загрузка чатов...»)
  final String? message;

  const AppLoader({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────── Пустое состояние ───────────────────

/// Виджет «пустого состояния» с иконкой, заголовком и описанием.
///
/// Используется когда нет данных: нет чатов, нет файлов и т.д.
class EmptyState extends StatelessWidget {
  /// Иконка сверху
  final IconData icon;

  /// Заголовок (крупный текст)
  final String title;

  /// Описание под заголовком
  final String? subtitle;

  /// Опциональная кнопка действия
  final Widget? action;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: colors.onSurfaceVariant.withOpacity(0.4)),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant.withOpacity(0.7),
                    ),
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: 24),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

// ─────────────────── Виджет ошибки ───────────────────

/// Виджет отображения ошибки с кнопкой «Повторить».
class ErrorDisplay extends StatelessWidget {
  /// Текст ошибки
  final String message;

  /// Callback при нажатии «Повторить»
  final VoidCallback? onRetry;

  const ErrorDisplay({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Повторить'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─────────────────── Статусный индикатор ───────────────────

/// Цветной бейдж статуса обработки.
///
/// Используется в карточках файлов и в чате (статус ответа ИИ).
class StatusBadge extends StatelessWidget {
  final String label;
  final Color color;

  const StatusBadge({
    super.key,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
