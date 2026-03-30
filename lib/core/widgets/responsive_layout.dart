/// Адаптивный layout-builder.
///
/// Определяет текущий тип устройства по ширине экрана
/// и рендерит соответствующий виджет: mobile / tablet / desktop.
///
/// Breakpoints заданы в [AppConstants] и легко меняются.
library;

import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

/// Тип текущего устройства по ширине viewport
enum DeviceType { mobile, tablet, desktop }

/// Виджет-обёртка для адаптивной вёрстки.
///
/// Пример использования:
/// ```dart
/// ResponsiveLayout(
///   mobile: MobileChatPage(),
///   tablet: TabletChatPage(),
///   desktop: DesktopChatPage(),
/// )
/// ```
class ResponsiveLayout extends StatelessWidget {
  /// Виджет для мобильных устройств (ширина < tabletBreakpoint)
  final Widget mobile;

  /// Виджет для планшетов (tabletBreakpoint <= ширина < desktopBreakpoint)
  /// Если не указан — используется [mobile]
  final Widget? tablet;

  /// Виджет для десктопа (ширина >= desktopBreakpoint)
  /// Если не указан — используется [tablet] или [mobile]
  final Widget? desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  /// Определить тип устройства по переданной ширине экрана
  static DeviceType getDeviceType(double width) {
    if (width >= AppConstants.desktopBreakpoint) return DeviceType.desktop;
    if (width >= AppConstants.tabletBreakpoint) return DeviceType.tablet;
    return DeviceType.mobile;
  }

  /// Проверить — сейчас десктоп?
  static bool isDesktop(BuildContext context) =>
      getDeviceType(MediaQuery.sizeOf(context).width) == DeviceType.desktop;

  /// Проверить — сейчас планшет?
  static bool isTablet(BuildContext context) =>
      getDeviceType(MediaQuery.sizeOf(context).width) == DeviceType.tablet;

  /// Проверить — сейчас мобильный?
  static bool isMobile(BuildContext context) =>
      getDeviceType(MediaQuery.sizeOf(context).width) == DeviceType.mobile;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final deviceType = getDeviceType(constraints.maxWidth);

        switch (deviceType) {
          case DeviceType.desktop:
            return desktop ?? tablet ?? mobile;
          case DeviceType.tablet:
            return tablet ?? mobile;
          case DeviceType.mobile:
            return mobile;
        }
      },
    );
  }
}
