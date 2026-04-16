/// Точка входа в приложение «Чат с ИИ-ассистентом».
///
/// Инициализирует зависимости и запускает корневой виджет.
library;

import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:intl/date_symbol_data_local.dart';
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

  // Инициализация русской локали для форматирования дат
  await initializeDateFormatting('ru', null);

  // Запускаем приложение
  runApp(const RagChatApp());
}
