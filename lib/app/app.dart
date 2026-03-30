/// Корневой виджет приложения «Чат с ИИ».
///
/// Оборачивает всё дерево виджетов в BLoC-провайдеры
/// и настраивает MaterialApp с роутером и темой.
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../features/auth/presentation/bloc/auth_bloc.dart';
import '../features/chat/presentation/bloc/chat_bloc.dart';
import '../features/chat/presentation/bloc/conversation_list_bloc.dart';
import 'di.dart';
import 'router.dart';
import 'theme.dart';

/// Корневой виджет приложения.
class RagChatApp extends StatelessWidget {
  const RagChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Создаём AuthBloc на верхнем уровне (нужен для роутера)
    final authBloc = sl<AuthBloc>();

    return MultiBlocProvider(
      providers: [
        // AuthBloc — глобальный, живёт всё время работы приложения
        BlocProvider<AuthBloc>(
          create: (_) => authBloc..add(const AuthCheckRequested()),
        ),

        // ConversationListBloc — список чатов в боковой панели
        BlocProvider<ConversationListBloc>(
          create: (_) => sl<ConversationListBloc>(),
        ),

        // ChatBloc — активный диалог (сообщения)
        BlocProvider<ChatBloc>(
          create: (_) => sl<ChatBloc>(),
        ),
      ],
      child: MaterialApp.router(
        title: 'Университет правосудия — Чат с ИИ',
        debugShowCheckedModeBanner: false,

        // Тема
        theme: AppTheme.light,

        // Роутер
        routerConfig: createRouter(authBloc),

        // Локализация
        locale: const Locale('ru', 'RU'),
      ),
    );
  }
}
