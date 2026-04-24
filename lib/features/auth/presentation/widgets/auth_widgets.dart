/// Общие виджеты auth-экранов (login / register): шапка, типографика,
/// поля с label, primary-кнопка, футер со ссылкой.
library;

import 'package:flutter/material.dart';

import '../../../../app/theme.dart';
import '../../../../core/widgets/app_logo.dart';

/// Шапка «плашка с лого + название + подзаголовок».
class AuthBrandHeader extends StatelessWidget {
  final String subtitle;
  const AuthBrandHeader({super.key, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted = isDark ? AppColorsDark.textMuted : AppColorsLight.textMuted;

    return Row(
      children: [
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(
            color: colors.primary,
            borderRadius: BorderRadius.circular(AppRadius.md - 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 24, offset: const Offset(0, 6),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: const AppLogo(size: 26, monochrome: true),
        ),
        const SizedBox(width: AppSpacing.md),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'РГУП · Ассистент',
              style: TextStyle(
                fontFamily: AppFonts.display,
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: colors.onSurface,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontFamily: AppFonts.ui,
                fontSize: 12,
                color: muted,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Большой заголовок экрана (Lora display).
class AuthTitle extends StatelessWidget {
  final String text;
  const AuthTitle({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(text, style: Theme.of(context).textTheme.displayMedium);
  }
}

/// Подзаголовок (14, muted, 1.5).
class AuthSubtitle extends StatelessWidget {
  final String text;
  const AuthSubtitle({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted = isDark ? AppColorsDark.textMuted : AppColorsLight.textMuted;
    return Text(
      text,
      style: TextStyle(
        fontFamily: AppFonts.ui,
        fontSize: 14, height: 1.5,
        color: muted,
      ),
    );
  }
}

/// Поле с label сверху (12/500/muted) + child (обычно TextFormField).
class AuthLabeledField extends StatelessWidget {
  final String label;
  final Widget child;
  const AuthLabeledField({super.key, required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted = isDark ? AppColorsDark.textMuted : AppColorsLight.textMuted;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 6, left: 2),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: AppFonts.ui,
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: muted,
            ),
          ),
        ),
        child,
      ],
    );
  }
}

/// Primary-кнопка во всю ширину, поддерживает loading-состояние.
class AuthPrimaryButton extends StatelessWidget {
  final String label;
  final bool loading;
  final VoidCallback onPressed;
  const AuthPrimaryButton({
    super.key,
    required this.label,
    required this.loading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return SizedBox(
      width: double.infinity,
      height: 46,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        child: loading
            ? SizedBox(
                width: 18, height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2, color: colors.onPrimary,
                ),
              )
            : Text(label),
      ),
    );
  }
}

/// Футер «Нет аккаунта? *Зарегистрироваться*» или «Уже есть аккаунт? *Войти*».
class AuthFooterLink extends StatelessWidget {
  final String text;
  final String action;
  final VoidCallback onTap;
  const AuthFooterLink({
    super.key,
    required this.text,
    required this.action,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted = isDark ? AppColorsDark.textMuted : AppColorsLight.textMuted;
    final accent = Theme.of(context).colorScheme.primary;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '$text ',
          style: TextStyle(
            fontFamily: AppFonts.ui, fontSize: 13, color: muted,
          ),
        ),
        GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Text(
            action,
            style: TextStyle(
              fontFamily: AppFonts.ui, fontSize: 13,
              fontWeight: FontWeight.w500, color: accent,
            ),
          ),
        ),
      ],
    );
  }
}
