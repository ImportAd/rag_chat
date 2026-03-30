/// BLoC управления списком диалогов (боковая панель).
///
/// Отвечает за: загрузку списка, создание, переименование, удаление чатов.
library;

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/chat_entities.dart';
import '../../domain/usecases/chat_usecases.dart';

// ═══════════════════════ СОБЫТИЯ ═══════════════════════

abstract class ConversationListEvent extends Equatable {
  const ConversationListEvent();
  @override
  List<Object?> get props => [];
}

/// Загрузить список диалогов
class ConversationListLoadRequested extends ConversationListEvent {
  const ConversationListLoadRequested();
}

/// Создать новый диалог
class ConversationCreateRequested extends ConversationListEvent {
  const ConversationCreateRequested();
}

/// Переименовать диалог
class ConversationRenameRequested extends ConversationListEvent {
  final String conversationId;
  final String newTitle;
  const ConversationRenameRequested({
    required this.conversationId,
    required this.newTitle,
  });
  @override
  List<Object?> get props => [conversationId, newTitle];
}

/// Удалить диалог
class ConversationDeleteRequested extends ConversationListEvent {
  final String conversationId;
  const ConversationDeleteRequested(this.conversationId);
  @override
  List<Object?> get props => [conversationId];
}

// ═══════════════════════ СОСТОЯНИЯ ═══════════════════════

abstract class ConversationListState extends Equatable {
  const ConversationListState();
  @override
  List<Object?> get props => [];
}

/// Начальное состояние
class ConversationListInitial extends ConversationListState {
  const ConversationListInitial();
}

/// Загрузка списка
class ConversationListLoading extends ConversationListState {
  const ConversationListLoading();
}

/// Список загружен
class ConversationListLoaded extends ConversationListState {
  final List<Conversation> conversations;
  const ConversationListLoaded(this.conversations);
  @override
  List<Object?> get props => [conversations];
}

/// Ошибка загрузки
class ConversationListError extends ConversationListState {
  final String message;
  const ConversationListError(this.message);
  @override
  List<Object?> get props => [message];
}

// ═══════════════════════ BLOC ═══════════════════════

/// BLoC списка диалогов.
class ConversationListBloc
    extends Bloc<ConversationListEvent, ConversationListState> {
  final GetConversationsUseCase _getConversations;
  final CreateConversationUseCase _createConversation;
  final RenameConversationUseCase _renameConversation;
  final DeleteConversationUseCase _deleteConversation;

  ConversationListBloc({
    required GetConversationsUseCase getConversations,
    required CreateConversationUseCase createConversation,
    required RenameConversationUseCase renameConversation,
    required DeleteConversationUseCase deleteConversation,
  })  : _getConversations = getConversations,
        _createConversation = createConversation,
        _renameConversation = renameConversation,
        _deleteConversation = deleteConversation,
        super(const ConversationListInitial()) {
    on<ConversationListLoadRequested>(_onLoad);
    on<ConversationCreateRequested>(_onCreate);
    on<ConversationRenameRequested>(_onRename);
    on<ConversationDeleteRequested>(_onDelete);
  }

  Future<void> _onLoad(
    ConversationListLoadRequested event,
    Emitter<ConversationListState> emit,
  ) async {
    emit(const ConversationListLoading());
    final result = await _getConversations();
    result.fold(
      (failure) => emit(ConversationListError(failure.message)),
      (conversations) => emit(ConversationListLoaded(conversations)),
    );
  }

  Future<void> _onCreate(
    ConversationCreateRequested event,
    Emitter<ConversationListState> emit,
  ) async {
    final result = await _createConversation();
    result.fold(
      (failure) {
        // Не меняем состояние списка, просто показываем ошибку
      },
      (newConversation) {
        // Добавляем новый чат в начало списка
        if (state is ConversationListLoaded) {
          final current = (state as ConversationListLoaded).conversations;
          emit(ConversationListLoaded([newConversation, ...current]));
        }
      },
    );
  }

  Future<void> _onRename(
    ConversationRenameRequested event,
    Emitter<ConversationListState> emit,
  ) async {
    final result = await _renameConversation(
      conversationId: event.conversationId,
      newTitle: event.newTitle,
    );
    result.fold(
      (failure) {},
      (updated) {
        if (state is ConversationListLoaded) {
          final current = (state as ConversationListLoaded).conversations;
          final updatedList = current.map((c) {
            return c.id == event.conversationId ? updated : c;
          }).toList();
          emit(ConversationListLoaded(updatedList));
        }
      },
    );
  }

  Future<void> _onDelete(
    ConversationDeleteRequested event,
    Emitter<ConversationListState> emit,
  ) async {
    final result = await _deleteConversation(event.conversationId);
    result.fold(
      (failure) {},
      (_) {
        if (state is ConversationListLoaded) {
          final current = (state as ConversationListLoaded).conversations;
          final filtered =
              current.where((c) => c.id != event.conversationId).toList();
          emit(ConversationListLoaded(filtered));
        }
      },
    );
  }
}
