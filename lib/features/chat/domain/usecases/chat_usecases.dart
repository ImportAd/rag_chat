/// Use case'ы чата.
///
/// Каждый — одно действие. Вызывается из ChatBloc.
library;

import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/chat_entities.dart';
import '../repositories/chat_repository.dart';

/// Получить список диалогов пользователя.
class GetConversationsUseCase {
  final ChatRepository _repository;
  GetConversationsUseCase(this._repository);

  Future<Either<Failure, List<Conversation>>> call({
    int page = 1,
    int limit = 20,
  }) {
    return _repository.getConversations(page: page, limit: limit);
  }
}

/// Создать новый диалог.
class CreateConversationUseCase {
  final ChatRepository _repository;
  CreateConversationUseCase(this._repository);

  Future<Either<Failure, Conversation>> call() {
    return _repository.createConversation();
  }
}

/// Переименовать диалог.
class RenameConversationUseCase {
  final ChatRepository _repository;
  RenameConversationUseCase(this._repository);

  Future<Either<Failure, Conversation>> call({
    required String conversationId,
    required String newTitle,
  }) {
    return _repository.renameConversation(
      conversationId: conversationId,
      newTitle: newTitle,
    );
  }
}

/// Удалить диалог.
class DeleteConversationUseCase {
  final ChatRepository _repository;
  DeleteConversationUseCase(this._repository);

  Future<Either<Failure, void>> call(String conversationId) {
    return _repository.deleteConversation(conversationId);
  }
}

/// Получить историю сообщений в диалоге.
class GetMessagesUseCase {
  final ChatRepository _repository;
  GetMessagesUseCase(this._repository);

  Future<Either<Failure, List<Message>>> call({
    required String conversationId,
    int page = 1,
    int limit = 50,
  }) {
    return _repository.getMessages(
      conversationId: conversationId,
      page: page,
      limit: limit,
    );
  }
}

/// Отправить сообщение и получить ответ ИИ.
class SendMessageUseCase {
  final ChatRepository _repository;
  SendMessageUseCase(this._repository);

  Future<Either<Failure, Message>> call({
    required String conversationId,
    required String content,
    Function(MessageStatus status)? onStatusUpdate,
  }) {
    return _repository.sendMessage(
      conversationId: conversationId,
      content: content,
      onStatusUpdate: onStatusUpdate,
    );
  }
}
