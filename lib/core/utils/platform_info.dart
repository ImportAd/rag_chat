/// Флаги платформы: web vs mobile-build + текущая ширина экрана.
///
/// Единственный источник правды для ветвления UI «web / mobile».
/// Декоративные элементы (PatternColumns), клавиатурные хоткеи,
/// специфичные web-действия — ориентируются на эти флаги.
library;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/widgets.dart';

/// true — приложение запущено как web-сборка.
bool get isWebPlatform => kIsWeb;

/// true — приложение запущено как нативное мобильное (Android/iOS) или desktop.
bool get isMobilePlatform => !kIsWeb;

/// true — текущая ширина экрана меньше [breakpoint] (по умолчанию 600 px).
/// Узкое окно в браузере тоже считается «компактным».
bool isCompactWidth(BuildContext context, {double breakpoint = 600}) {
  return MediaQuery.sizeOf(context).width < breakpoint;
}

/// true — узкий экран на ширину сайдбара (меньше 900 px).
/// Используется для решений «показать сайдбар как Drawer вместо колонки».
bool isNarrowLayout(BuildContext context) {
  return MediaQuery.sizeOf(context).width < 900;
}
