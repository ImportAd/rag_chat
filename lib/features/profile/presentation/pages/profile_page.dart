/// Страница профиля пользователя.
///
/// Отображает: ФИО, роль, отдел/группу, логин.
/// Кнопка выхода из системы.
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/domain/entities/user.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';

/// Страница профиля текущего пользователя.
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Профиль'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/chat'),
        ),
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is! AuthAuthenticated) {
            return const Center(
              child: Text('Данные профиля недоступны'),
            );
          }

          final user = state.user;

          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Column(
                  children: [
                    // ─── Аватар ───
                    CircleAvatar(
                      radius: 48,
                      backgroundColor: colors.primaryContainer,
                      child: Text(
                        _initials(user.fullName),
                        style: textTheme.headlineMedium?.copyWith(
                          color: colors.onPrimaryContainer,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ─── ФИО ───
                    Text(
                      user.fullName,
                      style: textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),

                    // ─── Роль ───
                    Chip(
                      label: Text(_roleLabel(user.role)),
                      backgroundColor: colors.secondaryContainer,
                    ),
                    const SizedBox(height: 32),

                    // ─── Карточка с данными ───
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            _ProfileRow(
                              icon: Icons.person_outline,
                              label: 'Логин',
                              value: user.username,
                            ),
                            const Divider(height: 24),
                            _ProfileRow(
                              icon: Icons.groups_outlined,
                              label: 'Отдел / группа',
                              value: user.department,
                            ),
                            const Divider(height: 24),
                            _ProfileRow(
                              icon: Icons.language,
                              label: 'Язык',
                              value: user.language == 'ru'
                                  ? 'Русский'
                                  : user.language,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // ─── Кнопка выхода ───
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          context
                              .read<AuthBloc>()
                              .add(const AuthLogoutRequested());
                        },
                        icon: const Icon(Icons.logout),
                        label: const Text('Выйти из системы'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: colors.error,
                          side: BorderSide(color: colors.error),
                          padding: const EdgeInsets.all(16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Получить инициалы из ФИО
  String _initials(String fullName) {
    final parts = fullName.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return fullName.isNotEmpty ? fullName[0].toUpperCase() : '?';
  }

  /// Человекочитаемое название роли
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
}

/// Строка профиля: иконка + подпись + значение
class _ProfileRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ProfileRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.outline),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            Text(value, style: Theme.of(context).textTheme.bodyLarge),
          ],
        ),
      ],
    );
  }
}
