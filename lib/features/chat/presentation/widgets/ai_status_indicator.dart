/// Индикатор обработки запроса ИИ.
///
/// Три пульсирующие точки + ролевой текст статуса («Поиск в базе знаний…»,
/// «Генерация ответа…» и т.д.). Показывается между лентой сообщений
/// и полем ввода, пока ИИ работает.
library;

import 'package:flutter/material.dart';

import '../../../../app/theme.dart';
import '../../domain/entities/chat_entities.dart';

class AiStatusIndicator extends StatefulWidget {
  final MessageStatus status;
  const AiStatusIndicator({super.key, required this.status});

  @override
  State<AiStatusIndicator> createState() => _AiStatusIndicatorState();
}

class _AiStatusIndicatorState extends State<AiStatusIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String get _label {
    switch (widget.status) {
      case MessageStatus.sent:
        return 'Запрос отправлен…';
      case MessageStatus.searching:
        return 'Поиск в базе знаний…';
      case MessageStatus.refining:
        return 'Уточняю поиск…';
      case MessageStatus.generating:
        return 'Генерация ответа…';
      case MessageStatus.completed:
        return 'Ответ получен';
      case MessageStatus.error:
        return 'Ошибка при обработке';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted = isDark ? AppColorsDark.textMuted : AppColorsLight.textMuted;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 820),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl, AppSpacing.sm, AppSpacing.xl, AppSpacing.sm,
          ),
          // Выравниваем под аватар (30px) + gap (12) = 42 px отступ слева,
          // чтобы точки стояли ровно под «Ассистент».
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(width: 30 + AppSpacing.md),
              _PulsingDots(controller: _controller),
              const SizedBox(width: AppSpacing.sm),
              Text(
                _label,
                style: TextStyle(
                  fontFamily: AppFonts.ui,
                  fontSize: 12.5,
                  color: muted,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PulsingDots extends StatelessWidget {
  final AnimationController controller;
  const _PulsingDots({required this.controller});

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    return SizedBox(
      width: 26, height: 10,
      child: AnimatedBuilder(
        animation: controller,
        builder: (_, __) => Stack(
          children: [
            for (var i = 0; i < 3; i++)
              Positioned(
                left: i * 9.0,
                top: 0,
                child: Opacity(
                  opacity: _dotOpacity(controller.value, i),
                  child: Container(
                    width: 6, height: 6,
                    margin: const EdgeInsets.only(top: 2),
                    decoration: BoxDecoration(
                      color: accent,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Волна: точки мигают с фазовым сдвигом 0 / 0.33 / 0.66.
  double _dotOpacity(double t, int i) {
    final phase = (t - i * 0.22) % 1.0;
    // Синусоида с минимумом 0.25, максимумом 1.0.
    final v = 0.5 + 0.5 * -(phase * 2 - 1).abs();
    return 0.25 + 0.75 * v;
  }
}
