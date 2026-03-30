/// Эндпоинты backend API, сгруппированные по доменам.
///
/// Все URL собраны в одном месте, чтобы при изменении маршрутов backend
/// достаточно было отредактировать только этот файл.
library;

class ApiEndpoints {
  ApiEndpoints._();

  // ───────────────── Авторизация ─────────────────

  /// POST: вход (логин + пароль) → access + refresh токены
  static const String login = '/auth/login';

  /// POST: регистрация нового студента
  static const String register = '/auth/register';

  /// POST: обновление access-токена через refresh-токен
  static const String refreshToken = '/auth/refresh';

  /// POST: выход из системы (инвалидация refresh-токена)
  static const String logout = '/auth/logout';

  // ───────────────── Профиль ─────────────────

  /// GET: данные текущего пользователя
  static const String profile = '/users/me';

  // ───────────────── Чаты ─────────────────

  /// GET: список чатов текущего пользователя (?page=&limit=)
  /// POST: создать новый чат
  static const String chats = '/chat/conversations';

  /// GET/PUT/DELETE: конкретный чат по id
  /// Пример: /chat/conversations/123
  static String chatById(String id) => '/chat/conversations/$id';

  // ───────────────── Сообщения ─────────────────

  /// GET: история сообщений в чате (?page=&limit=)
  /// POST: отправить новое сообщение в чат
  static String messages(String chatId) => '/chat/conversations/$chatId/messages';

  /// POST: отправить сообщение и получить ответ ИИ (stream / polling)
  static String sendMessage(String chatId) => '/chat/conversations/$chatId/send';

  // ───────────────── Системное ─────────────────

  /// GET: проверка здоровья backend
  static const String health = '/health';
}
