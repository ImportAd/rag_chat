/// Точка входа в приложение «Чат с ИИ-ассистентом».
///
/// Инициализирует зависимости и запускает корневой виджет.
library;

import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'app/app.dart';
import 'app/di.dart';

/// Точка входа: инициализация DI → запуск приложения.
Future<void> main() async {
  // Гарантируем инициализацию Flutter-движка
  WidgetsFlutterBinding.ensureInitialized();

  // Убираем # из URL — теперь это настоящие пути
  usePathUrlStrategy();

  // Инициализируем все зависимости (SharedPreferences, Dio, BLoC и т.д.)
  await initDependencies();

  // Запускаем приложение
  runApp(const RagChatApp());
}
