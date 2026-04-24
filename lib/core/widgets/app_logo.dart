/// Логотип РГУП (щит со звездой).
///
/// - `monochrome: true` — рендерится одним цветом (например, белым поверх
///   синей плашки в AI-аватаре и welcome-плашке).
/// - `monochrome: false` — оригинальный синий логотип из assets.
library;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final bool monochrome;
  final Color? color;

  const AppLogo({
    super.key,
    this.size = 32,
    this.monochrome = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final tint = monochrome
        ? (color ?? Theme.of(context).colorScheme.onPrimary)
        : null;

    return SvgPicture.asset(
      'assets/images/logo-rgup.svg',
      width: size,
      height: size,
      colorFilter: tint != null
          ? ColorFilter.mode(tint, BlendMode.srcIn)
          : null,
    );
  }
}
