/// Глобальные константы приложения «Чат с ИИ».
///
/// Все магические значения вынесены сюда, чтобы не дублировались
/// в разных частях кодовой базы и легко менялись из одного места.
library;

class AppConstants {
  AppConstants._(); // запрещаем создание экземпляра

  // ─────────────────────────── API ───────────────────────────

  /// Базовый URL backend-сервера.
  /// В продакшене заменяется через .env или compile-time переменную.
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8000/api/v1',
  );

  /// Таймаут подключения к серверу (мс)
  static const int connectionTimeoutMs = 15000;

  /// Таймаут получения ответа от сервера (мс)
  static const int receiveTimeoutMs = 60000;

  // ─────────────────────── Авторизация ──────────────────────

  /// Ключ для хранения access-токена в SharedPreferences
  static const String accessTokenKey = 'access_token';

  /// Ключ для хранения refresh-токена
  static const String refreshTokenKey = 'refresh_token';

  // ──────────────────────── Чат / ИИ ────────────────────────

  /// Максимальная длина одного сообщения пользователя (символов)
  static const int maxMessageLength = 2000;

  /// Лимит сообщений в минуту на одного пользователя
  static const int rateLimitPerMinute = 10;

  /// Лимит сообщений в час на одного пользователя
  static const int rateLimitPerHour = 100;

  /// Только один активный запрос к ИИ одновременно
  static const int maxConcurrentRequests = 1;

  /// Таймаут полного цикла обработки запроса (секунды)
  static const int chatRequestTimeoutSec = 60;

  // ──────────────────── Пагинация ────────────────────

  /// Количество чатов, подгружаемых за раз в боковой панели
  static const int chatsPageSize = 20;

  /// Количество сообщений, подгружаемых за раз в истории чата
  static const int messagesPageSize = 50;

  // ──────────────────── UI / Адаптивность ────────────────────

  /// Ширина экрана, при которой переключаемся на desktop-layout
  static const double desktopBreakpoint = 1200.0;

  /// Ширина экрана, при которой переключаемся на tablet-layout
  static const double tabletBreakpoint = 768.0;

  /// Максимальная ширина контентной области на desktop
  static const double maxContentWidth = 900.0;

  /// Ширина боковой панели чатов на desktop
  static const double sidebarWidth = 320.0;
}
