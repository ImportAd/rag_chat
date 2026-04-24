/// Боковая панель: лого, новый чат, поиск, список чатов с группировкой
/// по датам, info-блок и футер с пользователем.
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/app_logo.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../domain/entities/chat_entities.dart';
import '../bloc/conversation_list_bloc.dart';

class ChatSidebar extends StatefulWidget {
  final String? activeConversationId;
  final ValueChanged<String> onConversationSelected;
  final VoidCallback onNewChat;

  const ChatSidebar({
    super.key,
    this.activeConversationId,
    required this.onConversationSelected,
    required this.onNewChat,
  });

  @override
  State<ChatSidebar> createState() => _ChatSidebarState();
}

class _ChatSidebarState extends State<ChatSidebar> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceAlt =
        isDark ? AppColorsDark.surfaceAlt : AppColorsLight.surfaceAlt;
    final border = isDark ? AppColorsDark.border : AppColorsLight.border;

    return Container(
      color: surfaceAlt,
      child: Column(
        children: [
          const _SidebarHeader(),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md, 0, AppSpacing.md, AppSpacing.sm,
            ),
            child: _NewChatButton(onTap: widget.onNewChat),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md, 0, AppSpacing.md, AppSpacing.md,
            ),
            child: _SearchField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _query = v.trim()),
            ),
          ),
          Expanded(
            child: BlocBuilder<ConversationListBloc, ConversationListState>(
              builder: (context, state) {
                if (state is ConversationListLoading) {
                  return const AppLoader(message: 'Загрузка чатов…');
                }
                if (state is ConversationListError) {
                  return ErrorDisplay(
                    message: state.message,
                    onRetry: () => context
                        .read<ConversationListBloc>()
                        .add(const ConversationListLoadRequested()),
                  );
                }
                if (state is ConversationListLoaded) {
                  return _ConversationList(
                    conversations: state.conversations,
                    activeId: widget.activeConversationId,
                    query: _query,
                    onSelected: widget.onConversationSelected,
                    onRename: (id, title) {
                      context.read<ConversationListBloc>().add(
                            ConversationRenameRequested(
                              conversationId: id, newTitle: title,
                            ),
                          );
                    },
                    onDelete: _confirmDelete,
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          const _KbInfoBlock(),
          Container(
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: border)),
            ),
            child: const _UserFooter(),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(Conversation conversation) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Удалить чат?'),
        content: Text(
          'Чат «${conversation.title}» и его история будут удалены безвозвратно.',
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

// ─────────────────────── Header ───────────────────────

class _SidebarHeader extends StatelessWidget {
  const _SidebarHeader();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md, AppSpacing.lg, AppSpacing.md, AppSpacing.md,
      ),
      child: Row(
        children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              color: colors.primary,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            alignment: Alignment.center,
            child: const AppLogo(size: 20, monochrome: true),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            'РГУП · Ассистент',
            style: TextStyle(
              fontFamily: AppFonts.display,
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: colors.onSurface,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────── New chat ───────────────────────

class _NewChatButton extends StatelessWidget {
  final VoidCallback onTap;
  const _NewChatButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? AppColorsDark.surface : AppColorsLight.surface;
    final border = isDark ? AppColorsDark.border : AppColorsLight.border;
    final text = isDark ? AppColorsDark.text : AppColorsLight.text;

    return Material(
      color: surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        side: BorderSide(color: border),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: 10,
          ),
          child: Row(
            children: [
              Icon(Icons.add, size: 16, color: text),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Новый чат',
                style: TextStyle(
                  fontFamily: AppFonts.ui,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: text,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────── Search ───────────────────────

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  const _SearchField({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface2 = isDark ? AppColorsDark.surface2 : AppColorsLight.surface2;
    final muted = isDark ? AppColorsDark.textMuted : AppColorsLight.textMuted;
    final text = isDark ? AppColorsDark.text : AppColorsLight.text;

    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: TextStyle(fontFamily: AppFonts.ui, fontSize: 13, color: text),
      decoration: InputDecoration(
        hintText: 'Поиск',
        hintStyle: TextStyle(
          fontFamily: AppFonts.ui, fontSize: 13, color: muted,
        ),
        filled: true,
        fillColor: surface2,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: 10,
        ),
        prefixIcon: Icon(Icons.search, size: 18, color: muted),
        prefixIconConstraints: const BoxConstraints(
          minWidth: 36, minHeight: 36,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
        ),
        isDense: true,
      ),
    );
  }
}

// ─────────────────────── List ───────────────────────

class _ConversationList extends StatelessWidget {
  final List<Conversation> conversations;
  final String? activeId;
  final String query;
  final ValueChanged<String> onSelected;
  final void Function(String id, String title) onRename;
  final void Function(Conversation) onDelete;

  const _ConversationList({
    required this.conversations,
    required this.activeId,
    required this.query,
    required this.onSelected,
    required this.onRename,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final filtered = query.isEmpty
        ? conversations
        : conversations
            .where((c) => c.title.toLowerCase().contains(query.toLowerCase()))
            .toList();

    if (filtered.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Text(
            query.isEmpty ? 'Нет чатов' : 'Ничего не найдено',
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    // Группируем
    final groups = <ChatDateGroup, List<Conversation>>{};
    for (final c in filtered) {
      groups.putIfAbsent(chatDateGroup(c.updatedAt), () => []).add(c);
    }

    final items = <Widget>[];
    for (final group in ChatDateGroup.values) {
      final list = groups[group];
      if (list == null || list.isEmpty) continue;
      items.add(_GroupHeader(label: group.label));
      for (final c in list) {
        items.add(_ConversationTile(
          conversation: c,
          isActive: c.id == activeId,
          onTap: () => onSelected(c.id),
          onRename: (newTitle) => onRename(c.id, newTitle),
          onDelete: () => onDelete(c),
        ));
      }
    }

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      children: items,
    );
  }
}

class _GroupHeader extends StatelessWidget {
  final String label;
  const _GroupHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dim = isDark ? AppColorsDark.textDim : AppColorsLight.textDim;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.xs,
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontFamily: AppFonts.ui,
          fontSize: 10.5,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.08 * 10.5,
          color: dim,
        ),
      ),
    );
  }
}

class _ConversationTile extends StatefulWidget {
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
  State<_ConversationTile> createState() => _ConversationTileState();
}

class _ConversationTileState extends State<_ConversationTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = Theme.of(context).colorScheme.primary;
    final surface2 = isDark ? AppColorsDark.surface2 : AppColorsLight.surface2;
    final text = isDark ? AppColorsDark.text : AppColorsLight.text;
    final muted = isDark ? AppColorsDark.textMuted : AppColorsLight.textMuted;

    final bg = widget.isActive
        ? surface2
        : (_hovered ? surface2.withValues(alpha: 0.5) : Colors.transparent);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: 8,
          ),
          decoration: BoxDecoration(
            color: bg,
            border: Border(
              left: BorderSide(
                color: widget.isActive ? accent : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  widget.conversation.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: AppFonts.ui,
                    fontSize: 13,
                    fontWeight:
                        widget.isActive ? FontWeight.w500 : FontWeight.w400,
                    color: widget.isActive ? text : muted,
                  ),
                ),
              ),
              if (_hovered || widget.isActive)
                _MoreMenu(
                  onRename: () => _showRenameDialog(context),
                  onDelete: widget.onDelete,
                  color: muted,
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showRenameDialog(BuildContext context) {
    final controller =
        TextEditingController(text: widget.conversation.title);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Переименовать чат'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Новое название'),
          onSubmitted: (v) {
            if (v.trim().isNotEmpty) {
              widget.onRename(v.trim());
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
              final t = controller.text.trim();
              if (t.isNotEmpty) {
                widget.onRename(t);
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

class _MoreMenu extends StatelessWidget {
  final VoidCallback onRename;
  final VoidCallback onDelete;
  final Color color;
  const _MoreMenu({
    required this.onRename,
    required this.onDelete,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      padding: EdgeInsets.zero,
      icon: Icon(Icons.more_horiz, size: 16, color: color),
      tooltip: '',
      itemBuilder: (_) => const [
        PopupMenuItem(
          value: 'rename',
          child: Row(children: [
            Icon(Icons.edit_outlined, size: 16),
            SizedBox(width: 8),
            Text('Переименовать'),
          ]),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Row(children: [
            Icon(Icons.delete_outline, size: 16, color: Colors.red),
            SizedBox(width: 8),
            Text('Удалить', style: TextStyle(color: Colors.red)),
          ]),
        ),
      ],
      onSelected: (v) {
        if (v == 'rename') onRename();
        if (v == 'delete') onDelete();
      },
    );
  }
}

// ─────────────────────── KB info-blob ───────────────────────

class _KbInfoBlock extends StatelessWidget {
  const _KbInfoBlock();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentBg =
        isDark ? AppColorsDark.accentBg : AppColorsLight.accentBg;
    final accent = Theme.of(context).colorScheme.primary;
    final muted = isDark ? AppColorsDark.textMuted : AppColorsLight.textMuted;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.md,
      ),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: accentBg,
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.info_outline, size: 14, color: accent),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                'Ответы основаны на внутренней базе знаний университета.',
                style: TextStyle(
                  fontFamily: AppFonts.ui,
                  fontSize: 11.5,
                  height: 1.4,
                  color: muted,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────── User footer ───────────────────────

class _UserFooter extends StatelessWidget {
  const _UserFooter();

  String _initials(String fullName) {
    final parts =
        fullName.trim().split(RegExp(r'\s+')).where((s) => s.isNotEmpty);
    if (parts.isEmpty) return '?';
    final letters = parts.take(2).map((w) => w[0].toUpperCase()).join();
    return letters;
  }

  String _shortName(User user) {
    final parts = user.fullName.trim().split(RegExp(r'\s+'));
    // Студент: «Имя Фамилия» / Сотрудник: «Фамилия И.О.»
    if (user.role == UserRole.student) {
      if (parts.length >= 2) return '${parts[1]} ${parts[0]}';
      return user.fullName;
    }
    if (parts.length >= 3) {
      return '${parts[0]} ${parts[1][0]}.${parts[2][0]}.';
    }
    return user.fullName;
  }

  String _roleLabel(UserRole role) {
    switch (role) {
      case UserRole.student:
        return 'Студент';
      case UserRole.staff:
        return 'Сотрудник';
      case UserRole.admin:
        return 'Администратор';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final userColor =
        isDark ? AppColorsDark.userAvatar : AppColorsLight.userAvatar;
    final text = isDark ? AppColorsDark.text : AppColorsLight.text;
    final dim = isDark ? AppColorsDark.textDim : AppColorsLight.textDim;
    final muted = isDark ? AppColorsDark.textMuted : AppColorsLight.textMuted;

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final user = authState is AuthAuthenticated ? authState.user : null;
        if (user == null) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md, AppSpacing.md, AppSpacing.sm, AppSpacing.md,
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => context.go('/profile'),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: 30, height: 30,
                  decoration: BoxDecoration(
                    color: userColor,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _initials(user.fullName),
                    style: const TextStyle(
                      fontFamily: AppFonts.ui,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: GestureDetector(
                  onTap: () => context.go('/profile'),
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _shortName(user),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: AppFonts.ui,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: text,
                        ),
                      ),
                      Text(
                        _roleLabel(user.role),
                        style: TextStyle(
                          fontFamily: AppFonts.ui,
                          fontSize: 11,
                          color: dim,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Выйти',
                onPressed: () => context
                    .read<AuthBloc>()
                    .add(const AuthLogoutRequested()),
                icon: Icon(Icons.logout, size: 18, color: muted),
                splashRadius: 18,
              ),
            ],
          ),
        );
      },
    );
  }
}
