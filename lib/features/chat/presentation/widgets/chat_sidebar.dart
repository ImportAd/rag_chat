/// Боковая панель со списком диалогов.
///
/// Отображает все чаты пользователя, позволяет создавать новые,
/// переименовывать и удалять существующие.
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../../domain/entities/chat_entities.dart';
import '../bloc/conversation_list_bloc.dart';

/// Боковая панель со списком чатов.
class ChatSidebar extends StatelessWidget {
  /// ID текущего открытого чата (для подсветки)
  final String? activeConversationId;

  /// Callback при выборе чата
  final ValueChanged<String> onConversationSelected;

  /// Callback при создании нового чата
  final VoidCallback onNewChat;

  const ChatSidebar({
    super.key,
    this.activeConversationId,
    required this.onConversationSelected,
    required this.onNewChat,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      color: colors.surfaceContainerLow,
      child: Column(
        children: [
          // ─── Шапка: заголовок + кнопка «Новый чат» ───
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Чаты',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                IconButton(
                  onPressed: onNewChat,
                  icon: const Icon(Icons.add_comment_outlined),
                  tooltip: 'Новый чат',
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // ─── Список чатов ───
          Expanded(
            child: BlocBuilder<ConversationListBloc, ConversationListState>(
              builder: (context, state) {
                // Загрузка
                if (state is ConversationListLoading) {
                  return const AppLoader(message: 'Загрузка чатов...');
                }

                // Ошибка
                if (state is ConversationListError) {
                  return ErrorDisplay(
                    message: state.message,
                    onRetry: () {
                      context.read<ConversationListBloc>().add(
                            const ConversationListLoadRequested(),
                          );
                    },
                  );
                }

                // Список загружен
                if (state is ConversationListLoaded) {
                  if (state.conversations.isEmpty) {
                    return const EmptyState(
                      icon: Icons.chat_bubble_outline,
                      title: 'Нет чатов',
                      subtitle: 'Создайте новый чат, чтобы начать',
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    itemCount: state.conversations.length,
                    itemBuilder: (context, index) {
                      final conversation = state.conversations[index];
                      final isActive =
                          conversation.id == activeConversationId;
                      return _ConversationTile(
                        conversation: conversation,
                        isActive: isActive,
                        onTap: () =>
                            onConversationSelected(conversation.id),
                        onRename: (newTitle) {
                          context.read<ConversationListBloc>().add(
                                ConversationRenameRequested(
                                  conversationId: conversation.id,
                                  newTitle: newTitle,
                                ),
                              );
                        },
                        onDelete: () {
                          _confirmDelete(context, conversation);
                        },
                      );
                    },
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Диалог подтверждения удаления чата
  void _confirmDelete(BuildContext context, Conversation conversation) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Удалить чат?'),
        content: Text(
          'Чат "${conversation.title}" и вся его история будут удалены безвозвратно.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () {
              context.read<ConversationListBloc>().add(
                    ConversationDeleteRequested(conversation.id),
                  );
              Navigator.of(dialogContext).pop();
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
  }
}

// ─────────────────── Плитка одного чата ───────────────────

/// Элемент списка: одна строка диалога в боковой панели.
class _ConversationTile extends StatelessWidget {
  final Conversation conversation;
  final bool isActive;
  final VoidCallback onTap;
  final ValueChanged<String> onRename;
  final VoidCallback onDelete;

  const _ConversationTile({
    required this.conversation,
    required this.isActive,
    required this.onTap,
    required this.onRename,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return ListTile(
      selected: isActive,
      selectedTileColor: colors.primaryContainer.withOpacity(0.3),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
      title: Text(
        conversation.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            ),
      ),
      subtitle: Text(
        DateFormatter.smart(conversation.updatedAt),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: colors.onSurfaceVariant,
            ),
      ),
      trailing: PopupMenuButton<String>(
        icon: Icon(Icons.more_vert, size: 18, color: colors.outline),
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: 'rename',
            child: Row(
              children: [
                Icon(Icons.edit_outlined, size: 18),
                SizedBox(width: 8),
                Text('Переименовать'),
              ],
            ),
          ),
          const PopupMenuItem(
            value: 'delete',
            child: Row(
              children: [
                Icon(Icons.delete_outline, size: 18, color: Colors.red),
                SizedBox(width: 8),
                Text('Удалить', style: TextStyle(color: Colors.red)),
              ],
            ),
          ),
        ],
        onSelected: (value) {
          if (value == 'rename') {
            _showRenameDialog(context);
          } else if (value == 'delete') {
            onDelete();
          }
        },
      ),
      onTap: onTap,
    );
  }

  /// Диалог переименования чата
  void _showRenameDialog(BuildContext context) {
    final controller = TextEditingController(text: conversation.title);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Переименовать чат'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Новое название',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (value) {
            if (value.trim().isNotEmpty) {
              onRename(value.trim());
              Navigator.of(dialogContext).pop();
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () {
              final newTitle = controller.text.trim();
              if (newTitle.isNotEmpty) {
                onRename(newTitle);
                Navigator.of(dialogContext).pop();
              }
            },
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }
}
