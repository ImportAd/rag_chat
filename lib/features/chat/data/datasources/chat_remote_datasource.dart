/// Удалённый источник данных для чатов.
///
/// Выполняет HTTP-запросы к backend через [ApiClient].
library;

import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../domain/entities/chat_entities.dart';
import '../models/chat_models.dart';

/// Remote datasource для работы с диалогами и сообщениями.
class ChatRemoteDataSource {
  final ApiClient _apiClient;

  ChatRemoteDataSource({required ApiClient apiClient})
      : _apiClient = apiClient;

  /// Получить список диалогов
  Future<List<ConversationModel>> getConversations({
    int page = 1,
    int limit = 20,
  }) async {
    final result = await _apiClient.get(
      ApiEndpoints.chats,
      queryParameters: {'page': page, 'limit': limit},
    );

    return result.fold(
      (failure) => throw Exception(failure.message),
      (response) {
        final items = response.data['items'] as List;
        return items
            .map((json) =>
                ConversationModel.fromJson(json as Map<String, dynamic>))
            .toList();
      },
    );
  }

  /// Создать новый диалог
  Future<ConversationModel> createConversation() async {
    final result = await _apiClient.post(ApiEndpoints.chats);

    return result.fold(
      (failure) => throw Exception(failure.message),
      (response) =>
          ConversationModel.fromJson(response.data as Map<String, dynamic>),
    );
  }

  /// Переименовать диалог
  Future<ConversationModel> renameConversation({
    required String conversationId,
    required String newTitle,
  }) async {
    final result = await _apiClient.put(
      ApiEndpoints.chatById(conversationId),
      data: {'title': newTitle},
    );

    return result.fold(
      (failure) => throw Exception(failure.message),
      (response) =>
          ConversationModel.fromJson(response.data as Map<String, dynamic>),
    );
  }

  /// Удалить диалог
  Future<void> deleteConversation(String conversationId) async {
    final result =
        await _apiClient.delete(ApiEndpoints.chatById(conversationId));

    result.fold(
      (failure) => throw Exception(failure.message),
      (_) {},
    );
  }

  /// Получить историю сообщений
  Future<List<MessageModel>> getMessages({
    required String conversationId,
    int page = 1,
    int limit = 50,
  }) async {
    final result = await _apiClient.get(
      ApiEndpoints.messages(conversationId),
      queryParameters: {'page': page, 'limit': limit},
    );

    return result.fold(
      (failure) => throw Exception(failure.message),
      (response) {
        final items = response.data['items'] as List;
        return items
            .map(
                (json) => MessageModel.fromJson(json as Map<String, dynamic>))
            .toList();
      },
    );
  }

  /// Отправить сообщение и получить ответ ИИ.
  ///
  /// Backend может использовать polling или streaming.
  /// Клиент передаёт callback [onStatusUpdate] для промежуточных статусов.
  Future<MessageModel> sendMessage({
    required String conversationId,
    required String content,
    Function(MessageStatus status)? onStatusUpdate,
  }) async {
    // Сообщаем UI что запрос отправлен
    onStatusUpdate?.call(MessageStatus.sent);

    final result = await _apiClient.post(
      ApiEndpoints.sendMessage(conversationId),
      data: {'content': content},
    );

    return result.fold(
      (failure) => throw Exception(failure.message),
      (response) {
        final data = response.data as Map<String, dynamic>;

        // Если backend вернул промежуточные статусы — прокидываем
        if (data['status'] == 'searching') {
          onStatusUpdate?.call(MessageStatus.searching);
        }
        if (data['status'] == 'refining') {
          onStatusUpdate?.call(MessageStatus.refining);
        }
        if (data['status'] == 'generating') {
          onStatusUpdate?.call(MessageStatus.generating);
        }

        onStatusUpdate?.call(MessageStatus.completed);
        return MessageModel.fromJson(data);
      },
    );
  }
}
