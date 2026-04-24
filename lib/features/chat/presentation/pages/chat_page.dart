/// Главная страница чата с ИИ.
///
/// Desktop: sidebar 270px + main area (header + messages + input).
/// Mobile: AppBar с burger + drawer + main area.
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme.dart';
import '../../../../core/widgets/app_logo.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../bloc/chat_bloc.dart';
import '../bloc/conversation_list_bloc.dart';
import '../widgets/ai_status_indicator.dart';
import '../widgets/chat_sidebar.dart';
import '../widgets/message_bubble.dart';
import '../widgets/message_input.dart';
import '../widgets/role_texts.dart';

/// Ширина сайдбара по handoff РГУП.
const double _kSidebarWidth = 270;

/// Главная страница чата — точка входа после авторизации.
class ChatPage extends StatefulWidget {
  final String? conversationId;
  const ChatPage({super.key, this.conversationId});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context
        .read<ConversationListBloc>()
        .add(const ConversationListLoadRequested());
    if (widget.conversationId != null) {
      context.read<ChatBloc>().add(ChatOpened(widget.conversationId!));
    }
  }

  @override
  void didUpdateWidget(covariant ChatPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.conversationId != oldWidget.conversationId &&
        widget.conversationId != null) {
      context.read<ChatBloc>().add(ChatOpened(widget.conversationId!));
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onNewChat() {
    context
        .read<ConversationListBloc>()
        .add(const ConversationCreateRequested());
  }

  void _onConversationSelected(String id) => context.go('/chat/$id');

  void _onSendMessage(String content) {
    final chatState = context.read<ChatBloc>().state;
    if (chatState is ChatActive) {
      context.read<ChatBloc>().add(ChatMessageSent(content));
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent + 100,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  User? get _user {
    final s = context.read<AuthBloc>().state;
    return s is AuthAuthenticated ? s.user : null;
  }

  UserRole get _userRole => _user?.role ?? UserRole.student;

  String _activeChatTitle(ChatState state) {
    if (state is! ChatActive) return 'Новый чат';

    final convListState = context.read<ConversationListBloc>().state;
    if (convListState is ConversationListLoaded) {
      for (final c in convListState.conversations) {
        if (c.id == state.conversationId) return c.title;
      }
    }
    return 'Чат';
  }

  String? _activeChatMeta(ChatState state) {
    if (state is ChatActive && state.messages.isNotEmpty) {
      final n = state.messages.length;
      return '$n ${_pluralMessage(n)}';
    }
    return null;
  }

  String _pluralMessage(int n) {
    final mod10 = n % 10, mod100 = n % 100;
    if (mod10 == 1 && mod100 != 11) return 'сообщение';
    if ([2, 3, 4].contains(mod10) && ![12, 13, 14].contains(mod100)) {
      return 'сообщения';
    }
    return 'сообщений';
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveLayout.isDesktop(context) ||
        ResponsiveLayout.isTablet(context);

    if (isDesktop) {
      return Scaffold(
        body: Row(
          children: [
            SizedBox(
              width: _kSidebarWidth,
              child: ChatSidebar(
                activeConversationId: widget.conversationId,
                onConversationSelected: _onConversationSelected,
                onNewChat: _onNewChat,
              ),
            ),
            const VerticalDivider(width: 1),
            Expanded(child: _buildMainArea()),
          ],
        ),
      );
    }

    // Mobile
    return Scaffold(
      appBar: AppBar(
        title: BlocBuilder<ChatBloc, ChatState>(
          builder: (context, state) => Text(_activeChatTitle(state)),
        ),
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Профиль',
            icon: const Icon(Icons.person_outline),
            onPressed: () => context.go('/profile'),
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? AppColorsDark.surfaceAlt
            : AppColorsLight.surfaceAlt,
        child: ChatSidebar(
          activeConversationId: widget.conversationId,
          onConversationSelected: (id) {
            Navigator.of(context).pop();
            _onConversationSelected(id);
          },
          onNewChat: () {
            Navigator.of(context).pop();
            _onNewChat();
          },
        ),
      ),
      body: _buildMainArea(showHeader: false),
    );
  }

  Widget _buildMainArea({bool showHeader = true}) {
    return BlocBuilder<ChatBloc, ChatState>(
      builder: (context, state) {
        return Column(
          children: [
            if (showHeader) _ChatHeader(
              title: _activeChatTitle(state),
              meta: _activeChatMeta(state),
              onShare: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Скоро: совместный доступ к чату.'),
                  ),
                );
              },
            ),
            Expanded(child: _buildBody(state)),
          ],
        );
      },
    );
  }

  Widget _buildBody(ChatState state) {
    if (state is ChatEmpty) {
      return _WelcomeView(
        user: _user,
        role: _userRole,
        onPromptSelected: _onSendMessage,
        onNewChat: _onNewChat,
      );
    }

    if (state is ChatLoading) {
      return const AppLoader(message: 'Загрузка сообщений…');
    }

    if (state is ChatError) {
      return ErrorDisplay(
        message: state.message,
        onRetry: () {
          if (widget.conversationId != null) {
            context.read<ChatBloc>().add(ChatOpened(widget.conversationId!));
          }
        },
      );
    }

    if (state is ChatActive) {
      final isEmpty = state.messages.isEmpty;
      return Column(
        children: [
          if (state.errorMessage != null) _InlineError(state.errorMessage!),
          Expanded(
            child: isEmpty
                ? _WelcomeView(
                    user: _user,
                    role: _userRole,
                    onPromptSelected: _onSendMessage,
                    onNewChat: _onNewChat,
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: state.messages.length,
                    itemBuilder: (_, i) =>
                        MessageBubble(message: state.messages[i]),
                  ),
          ),
          if (state.isProcessing && state.aiStatus != null)
            AiStatusIndicator(status: state.aiStatus!),
          MessageInput(
            onSend: _onSendMessage,
            isDisabled: state.isProcessing,
            hintText: RoleTexts.inputHint(_userRole),
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }
}

// ─────────────────────── Header ───────────────────────

class _ChatHeader extends StatelessWidget {
  final String title;
  final String? meta;
  final VoidCallback onShare;
  const _ChatHeader({
    required this.title,
    required this.meta,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final border = isDark ? AppColorsDark.border : AppColorsLight.border;
    final text = isDark ? AppColorsDark.text : AppColorsLight.text;
    final dim = isDark ? AppColorsDark.textDim : AppColorsLight.textDim;

    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: border)),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl, vertical: 12,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: AppFonts.display,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: text,
                  ),
                ),
                if (meta != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    meta!,
                    style: TextStyle(
                      fontFamily: AppFonts.ui,
                      fontSize: 11.5,
                      color: dim,
                    ),
                  ),
                ],
              ],
            ),
          ),
          TextButton.icon(
            onPressed: onShare,
            icon: const Icon(Icons.share_outlined, size: 16),
            label: const Text('Поделиться'),
            style: TextButton.styleFrom(
              foregroundColor: dim,
              textStyle: const TextStyle(
                fontFamily: AppFonts.ui, fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InlineError extends StatelessWidget {
  final String message;
  const _InlineError(this.message);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final danger = isDark ? AppColorsDark.danger : AppColorsLight.danger;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg, vertical: AppSpacing.sm,
      ),
      color: danger.withValues(alpha: 0.08),
      child: Row(
        children: [
          Icon(Icons.warning_amber, size: 16, color: danger),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontFamily: AppFonts.ui, fontSize: 12, color: danger,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────── Welcome view ───────────────────────

class _WelcomeView extends StatelessWidget {
  final User? user;
  final UserRole role;
  final ValueChanged<String> onPromptSelected;
  final VoidCallback onNewChat;
  const _WelcomeView({
    required this.user,
    required this.role,
    required this.onPromptSelected,
    required this.onNewChat,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted = isDark ? AppColorsDark.textMuted : AppColorsLight.textMuted;

    final title = user != null
        ? RoleTexts.welcomeTitle(user!)
        : 'Здравствуйте';
    final subtitle = RoleTexts.welcomeSubtitle(role);
    final prompts = RoleTexts.prompts(role);

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl, vertical: AppSpacing.xxl,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Лого-плашка 64×64 с тенью
              Container(
                width: 64, height: 64,
                decoration: BoxDecoration(
                  color: colors.primary,
                  borderRadius: BorderRadius.circular(AppRadius.md + 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 24, offset: const Offset(0, 6),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: const AppLogo(size: 36, monochrome: true),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Заголовок
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displayLarge,
              ),
              const SizedBox(height: AppSpacing.md),

              // Подзаголовок
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: AppFonts.ui,
                    fontSize: 15, height: 1.6,
                    color: muted,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),

              // Сетка промпт-карточек 2×2 (на узком экране → 1×4)
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth >= 560;
                  if (isWide) {
                    return GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 4.2,
                      children: prompts
                          .map((p) => _PromptCard(
                                prompt: p,
                                onTap: () => onPromptSelected(p.title),
                              ))
                          .toList(),
                    );
                  }
                  return Column(
                    children: prompts
                        .map((p) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: _PromptCard(
                                prompt: p,
                                onTap: () => onPromptSelected(p.title),
                              ),
                            ))
                        .toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PromptCard extends StatefulWidget {
  final WelcomePrompt prompt;
  final VoidCallback onTap;
  const _PromptCard({required this.prompt, required this.onTap});

  @override
  State<_PromptCard> createState() => _PromptCardState();
}

class _PromptCardState extends State<_PromptCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? AppColorsDark.surface : AppColorsLight.surface;
    final surfaceAlt =
        isDark ? AppColorsDark.surfaceAlt : AppColorsLight.surfaceAlt;
    final accentBg =
        isDark ? AppColorsDark.accentBg : AppColorsLight.accentBg;
    final accent = Theme.of(context).colorScheme.primary;
    final border = isDark ? AppColorsDark.border : AppColorsLight.border;
    final text = isDark ? AppColorsDark.text : AppColorsLight.text;
    final muted = isDark ? AppColorsDark.textMuted : AppColorsLight.textMuted;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg, vertical: 14,
          ),
          decoration: BoxDecoration(
            color: _hovered ? surfaceAlt : surface,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: _hovered ? accent : border),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 30, height: 30,
                decoration: BoxDecoration(
                  color: accentBg,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                alignment: Alignment.center,
                child: Text(
                  widget.prompt.emoji,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.prompt.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: AppFonts.ui,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w500,
                        color: text,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.prompt.hint,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: AppFonts.ui,
                        fontSize: 12,
                        color: muted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
