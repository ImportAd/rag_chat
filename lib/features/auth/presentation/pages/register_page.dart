/// Страница регистрации нового студента.
///
/// Доступна только для студентов.
/// Сотрудники создаются вручную администратором.
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/pattern_columns.dart';
import '../bloc/auth_bloc.dart';
import '../widgets/auth_widgets.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  // ФИО разбито на три поля для визуального соответствия дизайну.
  // Для backend собирается в одну строку fullName.
  final _surnameCtrl = TextEditingController();
  final _firstNameCtrl = TextEditingController();
  final _patronymicCtrl = TextEditingController();

  final _usernameCtrl = TextEditingController();
  final _departmentCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();

  bool _obscurePassword = true;
  bool _acceptedTerms = false;

  @override
  void dispose() {
    _surnameCtrl.dispose();
    _firstNameCtrl.dispose();
    _patronymicCtrl.dispose();
    _usernameCtrl.dispose();
    _departmentCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  void _onRegister() {
    if (!_formKey.currentState!.validate()) return;
    if (!_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Для продолжения согласитесь с условиями.'),
        ),
      );
      return;
    }

    final fullName = [
      _surnameCtrl.text.trim(),
      _firstNameCtrl.text.trim(),
      _patronymicCtrl.text.trim(),
    ].where((s) => s.isNotEmpty).join(' ');

    context.read<AuthBloc>().add(
          AuthRegisterRequested(
            username: _usernameCtrl.text.trim(),
            password: _passwordCtrl.text,
            fullName: fullName,
            department: _departmentCtrl.text.trim(),
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
                        const AuthBrandHeader(subtitle: 'Регистрация'),
                        const SizedBox(height: AppSpacing.xxl),
                        const AuthTitle(text: 'Создать аккаунт'),
                        const SizedBox(height: AppSpacing.xs),
                        const AuthSubtitle(
                          text: 'Доступ получают студенты с активным статусом.',
                        ),
                        const SizedBox(height: AppSpacing.xl),

                        // ─── Фамилия + Имя (1fr 1fr) ───
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: AuthLabeledField(
                                label: 'Фамилия',
                                child: TextFormField(
                                  controller: _surnameCtrl,
                                  validator: (v) =>
                                      Validators.required(v, 'Фамилия'),
                                  textInputAction: TextInputAction.next,
                                  decoration: const InputDecoration(
                                    hintText: 'Иванов',
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: AuthLabeledField(
                                label: 'Имя',
                                child: TextFormField(
                                  controller: _firstNameCtrl,
                                  validator: (v) =>
                                      Validators.required(v, 'Имя'),
                                  textInputAction: TextInputAction.next,
                                  decoration: const InputDecoration(
                                    hintText: 'Иван',
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.lg),

                        // Отчество (опционально)
                        AuthLabeledField(
                          label: 'Отчество',
                          child: TextFormField(
                            controller: _patronymicCtrl,
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                              hintText: 'Иванович (если есть)',
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),

                        // Номер зачётки / Логин
                        AuthLabeledField(
                          label: 'Номер зачётки',
                          child: TextFormField(
                            controller: _usernameCtrl,
                            validator: Validators.login,
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                              hintText: '6-значный номер из студенческого',
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),

                        // Группа / отдел
                        AuthLabeledField(
                          label: 'Группа',
                          child: TextFormField(
                            controller: _departmentCtrl,
                            validator: (v) =>
                                Validators.required(v, 'Группа'),
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                              hintText: 'Например: ЮФ-21-1',
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),

                        // Пароль
                        AuthLabeledField(
                          label: 'Пароль',
                          child: TextFormField(
                            controller: _passwordCtrl,
                            validator: Validators.password,
                            obscureText: _obscurePassword,
                            textInputAction: TextInputAction.next,
                            decoration: InputDecoration(
                              hintText: 'Минимум 6 символов',
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
                        const SizedBox(height: AppSpacing.lg),

                        // Подтверждение пароля
                        AuthLabeledField(
                          label: 'Подтвердите пароль',
                          child: TextFormField(
                            controller: _confirmPasswordCtrl,
                            obscureText: true,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _onRegister(),
                            validator: (value) {
                              if (value != _passwordCtrl.text) {
                                return 'Пароли не совпадают';
                              }
                              return null;
                            },
                            decoration: const InputDecoration(
                              hintText: '••••••••',
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),

                        _TermsCheckbox(
                          accepted: _acceptedTerms,
                          onChanged: (v) =>
                              setState(() => _acceptedTerms = v ?? false),
                        ),
                        const SizedBox(height: AppSpacing.xl),

                        BlocBuilder<AuthBloc, AuthState>(
                          builder: (context, state) {
                            final isLoading = state is AuthLoading;
                            return AuthPrimaryButton(
                              label: 'Зарегистрироваться',
                              loading: isLoading,
                              onPressed: _onRegister,
                            );
                          },
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        AuthFooterLink(
                          text: 'Уже есть аккаунт?',
                          action: 'Войти',
                          onTap: () => context.go('/login'),
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

/// Чекбокс согласия с условиями использования и политикой данных.
class _TermsCheckbox extends StatelessWidget {
  final bool accepted;
  final ValueChanged<bool?> onChanged;
  const _TermsCheckbox({required this.accepted, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted = isDark ? AppColorsDark.textMuted : AppColorsLight.textMuted;
    final accent = Theme.of(context).colorScheme.primary;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: SizedBox(
            width: 20, height: 20,
            child: Checkbox(
              value: accepted,
              onChanged: onChanged,
              visualDensity: VisualDensity.compact,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: TextStyle(
                fontFamily: AppFonts.ui, fontSize: 12,
                color: muted, height: 1.45,
              ),
              children: [
                const TextSpan(text: 'Я соглашаюсь с '),
                TextSpan(
                  text: 'условиями использования',
                  style: TextStyle(color: accent, fontWeight: FontWeight.w500),
                ),
                const TextSpan(text: ' и '),
                TextSpan(
                  text: 'политикой обработки персональных данных',
                  style: TextStyle(color: accent, fontWeight: FontWeight.w500),
                ),
                const TextSpan(text: '.'),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
