/// Страница входа в систему.
///
/// Содержит форму логина/пароля и ссылку на регистрацию.
/// Используется как для студентов, так и для сотрудников.
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/pattern_columns.dart';
import '../bloc/auth_bloc.dart';
import '../widgets/auth_widgets.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _rememberMe = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLogin() {
    if (!_formKey.currentState!.validate()) return;

    context.read<AuthBloc>().add(
          AuthLoginRequested(
            username: _usernameController.text.trim(),
            password: _passwordController.text,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: colors.error,
              ),
            );
          }
        },
        child: Stack(
          children: [
            const Positioned.fill(child: PatternColumns()),
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const AuthBrandHeader(subtitle: 'Вход в систему'),
                        const SizedBox(height: AppSpacing.xxl),
                        const AuthTitle(text: 'Добро пожаловать'),
                        const SizedBox(height: AppSpacing.xs),
                        const AuthSubtitle(
                          text:
                              'Войдите, чтобы продолжить работу с ассистентом.',
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        AuthLabeledField(
                          label: 'Логин',
                          child: TextFormField(
                            controller: _usernameController,
                            validator: Validators.login,
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                              hintText: 'Ваш логин или номер зачётки',
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        AuthLabeledField(
                          label: 'Пароль',
                          child: TextFormField(
                            controller: _passwordController,
                            validator: Validators.password,
                            obscureText: _obscurePassword,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _onLogin(),
                            decoration: InputDecoration(
                              hintText: '••••••••',
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  size: 20,
                                ),
                                onPressed: () => setState(
                                  () => _obscurePassword = !_obscurePassword,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _RememberRow(
                          remember: _rememberMe,
                          onChanged: (v) =>
                              setState(() => _rememberMe = v ?? false),
                          onForgot: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Восстановление пароля скоро будет доступно. '
                                  'Обратитесь в деканат или к администратору.',
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        BlocBuilder<AuthBloc, AuthState>(
                          builder: (context, state) {
                            final isLoading = state is AuthLoading;
                            return AuthPrimaryButton(
                              label: 'Войти',
                              loading: isLoading,
                              onPressed: _onLogin,
                            );
                          },
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        AuthFooterLink(
                          text: 'Нет аккаунта?',
                          action: 'Зарегистрироваться',
                          onTap: () => context.go('/register'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Строка «чекбокс + Запомнить меня … Забыли пароль?». Используется только на
/// login — поэтому private и живёт здесь, а не в общих auth_widgets.
class _RememberRow extends StatelessWidget {
  final bool remember;
  final ValueChanged<bool?> onChanged;
  final VoidCallback onForgot;
  const _RememberRow({
    required this.remember,
    required this.onChanged,
    required this.onForgot,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted = isDark ? AppColorsDark.textMuted : AppColorsLight.textMuted;
    final accent = Theme.of(context).colorScheme.primary;

    return Row(
      children: [
        SizedBox(
          width: 20, height: 20,
          child: Checkbox(
            value: remember,
            onChanged: onChanged,
            visualDensity: VisualDensity.compact,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          'Запомнить меня',
          style: TextStyle(
            fontFamily: AppFonts.ui, fontSize: 12, color: muted,
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: onForgot,
          behavior: HitTestBehavior.opaque,
          child: Text(
            'Забыли пароль?',
            style: TextStyle(
              fontFamily: AppFonts.ui, fontSize: 12,
              fontWeight: FontWeight.w500, color: accent,
            ),
          ),
        ),
      ],
    );
  }
}
