/// Конфигурация маршрутизации приложения (GoRouter).
///
/// Декларативный роутинг с защитой маршрутов:
/// - Неавторизованные пользователи перенаправляются на /login
/// - Авторизованные пользователи с /login перенаправляются на /chat
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/presentation/bloc/auth_bloc.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/auth/presentation/pages/register_page.dart';
import '../features/chat/presentation/pages/chat_page.dart';
import '../features/profile/presentation/pages/profile_page.dart';

/// Создать экземпляр GoRouter с привязкой к [AuthBloc].
///
/// Роутер слушает изменения состояния авторизации
/// и автоматически перенаправляет пользователя.
GoRouter createRouter(AuthBloc authBloc) {
  return GoRouter(
    // Начальный маршрут
    initialLocation: '/chat',

    // Перенаправление на основе состояния авторизации
    redirect: (context, state) {
      final authState = authBloc.state;
      final isLoggedIn = authState is AuthAuthenticated;
      final isAuthRoute = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';

      // Не авторизован и не на auth-странице → на логин
      if (!isLoggedIn && !isAuthRoute) {
        return '/login';
      }

      // Авторизован и на auth-странице → на чат
      if (isLoggedIn && isAuthRoute) {
        return '/chat';
      }

      return null; // Без перенаправления
    },

    // Обновлять маршруты при изменении состояния авторизации
    refreshListenable: GoRouterRefreshStream(authBloc.stream),

    // Определение маршрутов
    routes: [
      // ─── Авторизация ───
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterPage(),
      ),

      // ─── Чат (главная страница) ───
      GoRoute(
        path: '/chat',
        name: 'chat',
        builder: (context, state) => const ChatPage(),
        routes: [
          // Конкретный чат по ID
          GoRoute(
            path: ':conversationId',
            name: 'chatConversation',
            builder: (context, state) {
              final id = state.pathParameters['conversationId']!;
              return ChatPage(conversationId: id);
            },
          ),
        ],
      ),

      // ─── Профиль ───
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfilePage(),
      ),
    ],

    // Страница 404
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 64),
            const SizedBox(height: 16),
            const Text('Страница не найдена'),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => context.go('/chat'),
              child: const Text('На главную'),
            ),
          ],
        ),
      ),
    ),
  );
}

/// Утилита для интеграции GoRouter с BLoC-стримом.
///
/// GoRouter принимает [Listenable] для обновления redirect.
/// Этот класс оборачивает Stream<AuthState> в ChangeNotifier.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) {
      notifyListeners();
    });
  }

  late final dynamic _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
