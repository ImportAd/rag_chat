/// Главная страница чата с ИИ.
///
/// На десктопе: боковая панель слева + область сообщений справа.
/// На мобильных: либо список чатов, либо область сообщений (по навигации).
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../domain/entities/chat_entities.dart';
import '../bloc/chat_bloc.dart';
import '../bloc/conversation_list_bloc.dart';
import '../widgets/ai_status_indicator.dart';
import '../widgets/chat_sidebar.dart';
import '../widgets/message_bubble.dart';
import '../widgets/message_input.dart';
import '../widgets/role_texts.dart';

/// Главная страница чата — точка входа после авторизации.
class ChatPage extends StatefulWidget {
  /// ID чата из URL (если пользователь открыл конкретный чат)
  final String? conversationId;

  const ChatPage({super.key, this.conversationId});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  /// Контроллер скролла для автопрокрутки к новым сообщениям
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    // Загружаем список чатов при открытии страницы
    context
        .read<ConversationListBloc>()
        .add(const ConversationListLoadRequested());

    // Если передан ID чата — открываем его
    if (widget.conversationId != null) {
      context.read<ChatBloc>().add(ChatOpened(widget.conversationId!));
    }
  }

  @override
  void didUpdateWidget(covariant ChatPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // При смене ID чата в URL — открываем новый чат
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

  /// Создать новый чат
  void _onNewChat() {
    context
        .read<ConversationListBloc>()
        .add(const ConversationCreateRequested());
    // TODO: после создания — перейти в этот чат
  }

  /// Открыть конкретный чат
  void _onConversationSelected(String id) {
    context.go('/chat/$id');
  }

  /// Отправить сообщение
  void _onSendMessage(String content) {
    final chatState = context.read<ChatBloc>().state;
    if (chatState is ChatActive) {
      context.read<ChatBloc>().add(ChatMessageSent(content));
      // Автопрокрутка вниз
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar с информацией о пользователе и кнопкой выхода
      appBar: AppBar(
        title: const Text('Чат с ИИ-ассистентом'),
        leading: ResponsiveLayout.isMobile(context)
            ? Builder(
                builder: (ctx) => IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () => Scaffold.of(ctx).openDrawer(),
                ),
              )
            : null,
        actions: [
          // Кнопка профиля
          IconButton(
            icon: const Icon(Icons.person_outline),
            tooltip: 'Профиль',
            onPressed: () => context.go('/profile'),
          ),
          // Кнопка выхода
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Выйти',
            onPressed: () {
              context.read<AuthBloc>().add(const AuthLogoutRequested());
            },
          ),
        ],
      ),

      // Боковая панель (drawer на мобильных)
      drawer: ResponsiveLayout.isMobile(context)
          ? Drawer(
              child: ChatSidebar(
                activeConversationId: widget.conversationId,
                onConversationSelected: (id) {
                  Navigator.of(context).pop(); // закрыть drawer
                  _onConversationSelected(id);
                },
                onNewChat: () {
                  Navigator.of(context).pop();
                  _onNewChat();
                },
              ),
            )
          : null,

      body: ResponsiveLayout(
        // ─── Мобильный layout: только область сообщений ───
        mobile: _buildMessagesArea(),

        // ─── Десктоп layout: боковая панель + сообщения ───
        desktop: Row(
          children: [
            // Боковая панель
            SizedBox(
              width: AppConstants.sidebarWidth,
              child: ChatSidebar(
                activeConversationId: widget.conversationId,
                onConversationSelected: _onConversationSelected,
                onNewChat: _onNewChat,
              ),
            ),
            // Разделитель
            const VerticalDivider(width: 1),
            // Область сообщений
            Expanded(child: _buildMessagesArea()),
          ],
        ),
      ),
    );
  }

  /// Получить роль текущего пользователя из AuthBloc
  UserRole get _userRole {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) return authState.user.role;
    return UserRole.student; // fallback
  }

  /// Область сообщений (правая часть на десктопе, весь экран на мобильных)
  Widget _buildMessagesArea() {
    final role = _userRole;

    return BlocBuilder<ChatBloc, ChatState>(
      builder: (context, state) {
        // ─── Нет открытого чата ───
        if (state is ChatEmpty) {
          return EmptyState(
            icon: Icons.chat_outlined,
            title: 'Выберите чат',
            subtitle: 'Или создайте новый, чтобы начать диалог',
            action: FilledButton.icon(
              onPressed: _onNewChat,
              icon: const Icon(Icons.add),
              label: const Text('Новый чат'),
            ),
          );
        }

        // ─── Загрузка истории ───
        if (state is ChatLoading) {
          return const AppLoader(message: 'Загрузка сообщений...');
        }

        // ─── Ошибка ───
        if (state is ChatError) {
          return ErrorDisplay(
            message: state.message,
            onRetry: () {
              if (widget.conversationId != null) {
                context
                    .read<ChatBloc>()
                    .add(ChatOpened(widget.conversationId!));
              }
            },
          );
        }

        // ─── Активный чат ───
        if (state is ChatActive) {
          // Определяем: пустой ли чат (нужно показать приветствие)
          final isEmptyChat = state.messages.isEmpty;

          return Column(
            children: [
              // ─── Ошибка (если есть) ───
              if (state.errorMessage != null)
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color:
                      Theme.of(context).colorScheme.errorContainer,
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber,
                          size: 18,
                          color: Theme.of(context)
                              .colorScheme
                              .onErrorContainer),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          state.errorMessage!,
                          style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onErrorContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // ─── Список сообщений или приветствие ───
              Expanded(
                child: isEmptyChat
                    ? _buildGreeting(role)
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: state.messages.length,
                        itemBuilder: (context, index) {
                          return MessageBubble(
                            message: state.messages[index],
                          );
                        },
                      ),
              ),

              // ─── Индикатор статуса ИИ ───
              if (state.isProcessing && state.aiStatus != null)
                AiStatusIndicator(status: state.aiStatus!),

              // ─── Поле ввода с ролевым плейсхолдером ───
              MessageInput(
                onSend: _onSendMessage,
                isDisabled: state.isProcessing,
                hintText: RoleTexts.inputHint(role),
              ),
            ],
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  /// Приветственный экран для пустого чата.
  ///
  /// Показывает приветствие по роли (студент/сотрудник) с иконкой
  /// и подсказкой, что можно спросить. Вариант (б) из архитектуры:
  /// фронтенд показывает локальный шаблон мгновенно, без запроса к backend.
  Widget _buildGreeting(UserRole role) {
    final colors = Theme.of(context).colorScheme;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Иконка бота
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: colors.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.smart_toy_outlined,
                size: 36,
                color: colors.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 20),

            // Текст приветствия (зависит от роли)
            Text(
              RoleTexts.greeting(role),
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: colors.onSurfaceVariant,
                    height: 1.5,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // Подсказка
            Text(
              RoleTexts.emptyChatSubtitle(role),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colors.outline,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
