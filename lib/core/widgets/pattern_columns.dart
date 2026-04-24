/// Декоративный паттерн вертикальных колонн (библиотечно-правовая эстетика).
///
/// Отрисовывается подложкой на welcome- и auth-экранах в web-сборке
/// при нормальной ширине. В мобильных билдах и на узком экране виджет
/// возвращает пустоту — решение принимается внутри, чтобы call-site не
/// дублировали проверку `if (kIsWeb && !isCompact)`.
library;

import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../utils/platform_info.dart';

class PatternColumns extends StatelessWidget {
  /// Сколько колонн уместить по горизонтали.
  final int columns;

  /// Прозрачность паттерна (по дефолту 0.04 — как в handoff).
  final double opacity;

  /// Принудительно показать, игнорируя проверки платформы/ширины.
  final bool force;

  const PatternColumns({
    super.key,
    this.columns = 8,
    this.opacity = 0.04,
    this.force = false,
  });

  @override
  Widget build(BuildContext context) {
    if (!force) {
      // Только для web и только при нормальной ширине.
      if (!isWebPlatform) return const SizedBox.shrink();
      if (isCompactWidth(context)) return const SizedBox.shrink();
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = (isDark ? AppColorsDark.text : AppColorsLight.text)
        .withValues(alpha: opacity);

    return IgnorePointer(
      child: CustomPaint(
        painter: _ColumnsPainter(columns: columns, color: color),
        size: Size.infinite,
      ),
    );
  }
}

class _ColumnsPainter extends CustomPainter {
  final int columns;
  final Color color;

  _ColumnsPainter({required this.columns, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;

    final slot = size.width / columns;
    // Ширина колонны — треть слота, капитель чуть шире.
    final shaftW = slot * 0.35;
    final capW = slot * 0.55;
    const capH = 10.0;

    for (int i = 0; i < columns; i++) {
      final cx = slot * (i + 0.5);
      // Шахта (вертикальный столб).
      final shaft = Rect.fromLTWH(
        cx - shaftW / 2, capH, shaftW, size.height - capH * 2,
      );
      canvas.drawRect(shaft, paint);
      // Капитель сверху.
      final top = Rect.fromLTWH(cx - capW / 2, 0, capW, capH);
      canvas.drawRect(top, paint);
      // База снизу.
      final bot = Rect.fromLTWH(cx - capW / 2, size.height - capH, capW, capH);
      canvas.drawRect(bot, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ColumnsPainter old) =>
      old.columns != columns || old.color != color;
}
