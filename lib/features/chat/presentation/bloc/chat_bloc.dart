/// BLoC управления активным диалогом (сообщения).
///
/// Отвечает за: загрузку истории, отправку сообщений,
/// отображение статуса ИИ, rate limiting на клиенте.
library;

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/chat_entities.dart';
import '../../domain/usecases/chat_usecases.dart';

// ═══════════════════════ СОБЫТИЯ ═══════════════════════

abstract class ChatEvent extends Equatable {
  const ChatEvent();
  @override
  List<Object?> get props => [];
}

/// Открыть диалог (загрузить историю сообщений)
class ChatOpened extends ChatEvent {
  final String conversationId;
  const ChatOpened(this.conversationId);
  @override
  List<Object?> get props => [conversationId];
}

/// Отправить сообщение пользователя
class ChatMessageSent extends ChatEvent {
  final String content;
  const ChatMessageSent(this.content);
  @override
  List<Object?> get props => [content];
}

/// Обновление статуса обработки ИИ (внутреннее событие)
class ChatAiStatusUpdated extends ChatEvent {
  final MessageStatus status;
  const ChatAiStatusUpdated(this.status);
  @override
  List<Object?> get props => [status];
}

/// Закрыть текущий диалог (при переключении или выходе)
class ChatClosed extends ChatEvent {
  const ChatClosed();
}

// ═══════════════════════ СОСТОЯНИЯ ═══════════════════════

abstract class ChatState extends Equatable {
  const ChatState();
  @override
  List<Object?> get props => [];
}

/// Нет открытого диалога
class ChatEmpty extends ChatState {
  const ChatEmpty();
}

/// Загрузка истории сообщений
class ChatLoading extends ChatState {
  const ChatLoading();
}

/// Диалог загружен и активен
class ChatActive extends ChatState {
  /// ID текущего диалога
  final String conversationId;

  /// Список сообщений (от старых к новым)
  final List<Message> messages;

  /// Текущий статус обработки запроса ИИ (null если ИИ не обрабатывает)
  final MessageStatus? aiStatus;

  /// Занят ли ИИ обработкой запроса (блокирует отправку нового)
  final bool isProcessing;

  /// Текст ошибки, если есть
  final String? errorMessage;

  const ChatActive({
    required this.conversationId,
    required this.messages,
    this.aiStatus,
    this.isProcessing = false,
    this.errorMessage,
  });

  /// Создать копию с изменёнными полями
  ChatActive copyWith({
    List<Message>? messages,
    MessageStatus? aiStatus,
    bool? isProcessing,
    String? errorMessage,
    bool clearAiStatus = false,
    bool clearError = false,
  }) {
    return ChatActive(
      conversationId: conversationId,
      messages: messages ?? this.messages,
      aiStatus: clearAiStatus ? null : (aiStatus ?? this.aiStatus),
      isProcessing: isProcessing ?? this.isProcessing,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props =>
      [conversationId, messages, aiStatus, isProcessing, errorMessage];
}

/// Ошибка загрузки диалога
class ChatError extends ChatState {
  final String message;
  const ChatError(this.message);
  @override
  List<Object?> get props => [message];
}

// ═══════════════════════ BLOC ═══════════════════════

/// BLoC активного диалога.
///
/// Управляет сообщениями, статусами ИИ и rate limiting.
class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final GetMessagesUseCase _getMessages;
  final SendMessageUseCase _sendMessage;

  /// Метки времени отправленных сообщений (для rate limiting на клиенте)
  final List<DateTime> _sentTimestamps = [];

  ChatBloc({
    required GetMessagesUseCase getMessages,
    required SendMessageUseCase sendMessage,
  })  : _getMessages = getMessages,
        _sendMessage = sendMessage,
        super(const ChatEmpty()) {
    on<ChatOpened>(_onOpened);
    on<ChatMessageSent>(_onMessageSent);
    on<ChatAiStatusUpdated>(_onAiStatusUpdated);
    on<ChatClosed>(_onClosed);
  }

  /// Открыть диалог — загрузить историю
  Future<void> _onOpened(ChatOpened event, Emitter<ChatState> emit) async {
    emit(const ChatLoading());

    final result = await _getMessages(conversationId: event.conversationId);
    result.fold(
      (failure) => emit(ChatError(failure.message)),
      (messages) => emit(ChatActive(
        conversationId: event.conversationId,
        messages: messages,
      )),
    );
  }

  /// Отправить сообщение
  Future<void> _onMessageSent(
      ChatMessageSent event, Emitter<ChatState> emit) async {
    if (state is! ChatActive) return;
    final current = state as ChatActive;

    // ─── Проверка: не идёт ли уже обработка ───
    if (current.isProcessing) return;

    // ─── Rate limiting на клиенте ───
    final now = DateTime.now();
    _sentTimestamps.removeWhere(
      (ts) => now.difference(ts).inMinutes >= 1,
    );
    if (_sentTimestamps.length >= AppConstants.rateLimitPerMinute) {
      emit(current.copyWith(
        errorMessage: 'Слишком много сообщений. Подождите минуту.',
      ));
      return;
    }
    _sentTimestamps.add(now);

    // ─── Добавляем сообщение пользователя в список ───
    final userMessage = Message(
      id: 'temp_${now.millisecondsSinceEpoch}',
      conversationId: current.conversationId,
      role: MessageRole.user,
      content: event.content,
      status: MessageStatus.completed,
      timestamp: now,
    );

    emit(current.copyWith(
      messages: [...current.messages, userMessage],
      isProcessing: true,
      aiStatus: MessageStatus.sent,
      clearError: true,
    ));

    // ─── Отправляем на backend и ждём ответ ИИ ───
    final result = await _sendMessage(
      conversationId: current.conversationId,
      content: event.content,
      onStatusUpdate: (status) {
        // Обновляем статус ИИ через отдельное событие
        add(ChatAiStatusUpdated(status));
      },
    );

    // Берём актуальное состояние ПОСЛЕ возможных обновлений статуса
    if (state is! ChatActive) return;
    final updated = state as ChatActive;

    result.fold(
      (failure) {
        emit(updated.copyWith(
          isProcessing: false,
          clearAiStatus: true,
          errorMessage: failure.message,
        ));
      },
      (aiMessage) {
        emit(updated.copyWith(
          messages: [...updated.messages, aiMessage],
          isProcessing: false,
          clearAiStatus: true,
        ));
      },
    );
  }

  /// Обновление статуса ИИ (промежуточное)
  void _onAiStatusUpdated(
      ChatAiStatusUpdated event, Emitter<ChatState> emit) {
    if (state is! ChatActive) return;
    final current = state as ChatActive;
    emit(current.copyWith(aiStatus: event.status));
  }

  /// Закрыть диалог
  void _onClosed(ChatClosed event, Emitter<ChatState> emit) {
    emit(const ChatEmpty());
  }
}
