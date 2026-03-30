/// Контракт репозитория чата.
///
/// Определяет операции над диалогами и сообщениями.
/// Реализация — в data layer.
library;

import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/chat_entities.dart';

/// Абстрактный репозиторий для работы с чатами и сообщениями.
abstract class ChatRepository {
  // ───────────────── Диалоги ─────────────────

  /// Получить список чатов текущего пользователя.
  /// [page] — номер страницы (начиная с 1).
  Future<Either<Failure, List<Conversation>>> getConversations({
    int page = 1,
    int limit = 20,
  });

  /// Создать новый диалог. Возвращает созданный [Conversation].
  Future<Either<Failure, Conversation>> createConversation();

  /// Переименовать диалог.
  Future<Either<Failure, Conversation>> renameConversation({
    required String conversationId,
    required String newTitle,
  });

  /// Удалить диалог.
  Future<Either<Failure, void>> deleteConversation(String conversationId);

  // ───────────────── Сообщения ─────────────────

  /// Получить историю сообщений в диалоге.
  Future<Either<Failure, List<Message>>> getMessages({
    required String conversationId,
    int page = 1,
    int limit = 50,
  });

  /// Отправить сообщение пользователя и получить ответ ИИ.
  ///
  /// Возвращает поток состояний обработки:
  /// sent → searching → generating → completed / error.
  ///
  /// [onStatusUpdate] вызывается при каждом изменении статуса,
  /// чтобы UI мог показать прогресс.
  Future<Either<Failure, Message>> sendMessage({
    required String conversationId,
    required String content,
    Function(MessageStatus status)? onStatusUpdate,
  });
}
