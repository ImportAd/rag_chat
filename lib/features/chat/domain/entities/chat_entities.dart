/// Доменные сущности чата: диалог, сообщение, источник.
///
/// Описывают бизнес-объекты без привязки к JSON или API.
library;

import 'package:equatable/equatable.dart';

// ═══════════════════════ Диалог (чат) ═══════════════════════

/// Один диалог (чат) пользователя с ИИ.
class Conversation extends Equatable {
  /// Уникальный ID чата
  final String id;

  /// Название чата (может быть переименовано пользователем)
  final String title;

  /// Дата создания
  final DateTime createdAt;

  /// Дата последнего сообщения (для сортировки)
  final DateTime updatedAt;

  /// Количество сообщений в чате (опционально)
  final int? messageCount;

  const Conversation({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    this.messageCount,
  });

  @override
  List<Object?> get props => [id, title, createdAt, updatedAt];
}

// ═══════════════════════ Сообщение ═══════════════════════

/// Роль отправителя сообщения.
enum MessageRole {
  /// Сообщение пользователя
  user,

  /// Ответ ИИ-ассистента
  assistant,

  /// Системное сообщение (ошибка, информация)
  system,
}

/// Статус обработки сообщения (для ответов ИИ).
enum MessageStatus {
  /// Запрос отправлен на сервер
  sent,

  /// Идёт поиск по RAG-базе
  searching,

  /// Pipeline уточняет поиск (query reformulation — повторный поиск
  /// при низких скорах, может добавить до 2 дополнительных итераций)
  refining,

  /// Идёт генерация ответа LLM
  generating,

  /// Ответ получен и отображён
  completed,

  /// Ошибка при обработке
  error,
}

/// Тип источника ответа: RAG нашёл, не нашёл, или ответ без RAG.
enum SourceType {
  /// Информация найдена в RAG-базе
  ragFound,

  /// Информация НЕ найдена в RAG-базе
  ragNotFound,

  /// Ответ дан без опоры на внутреннюю базу
  noRag,

  /// Запрос вне тематики базы знаний
  offTopic,
}

/// Одно сообщение в диалоге.
class Message extends Equatable {
  /// Уникальный ID сообщения
  final String id;

  /// ID диалога, к которому принадлежит сообщение
  final String conversationId;

  /// Роль отправителя: пользователь, ассистент, система
  final MessageRole role;

  /// Текст сообщения (может содержать Markdown для ответов ИИ)
  final String content;

  /// Статус обработки (актуален для ответов ИИ)
  final MessageStatus status;

  /// Тип источника ответа (только для ответов ИИ)
  final SourceType? sourceType;

  /// Список источников, на которых основан ответ
  final List<Source>? sources;

  /// Время отправки / получения
  final DateTime timestamp;

  const Message({
    required this.id,
    required this.conversationId,
    required this.role,
    required this.content,
    required this.status,
    this.sourceType,
    this.sources,
    required this.timestamp,
  });

  /// Создать копию с изменёнными полями (для обновления статуса)
  Message copyWith({
    String? content,
    MessageStatus? status,
    SourceType? sourceType,
    List<Source>? sources,
  }) {
    return Message(
      id: id,
      conversationId: conversationId,
      role: role,
      content: content ?? this.content,
      status: status ?? this.status,
      sourceType: sourceType ?? this.sourceType,
      sources: sources ?? this.sources,
      timestamp: timestamp,
    );
  }

  @override
  List<Object?> get props =>
      [id, conversationId, role, content, status, sourceType, timestamp];
}

// ═══════════════════════ Источник ═══════════════════════

/// Источник (документ), на основе которого был сформирован ответ.
///
/// Содержит только ту информацию, которая доступна текущему пользователю.
/// Backend фильтрует недоступные источники — клиент их никогда не получает.
class Source extends Equatable {
  /// Название документа
  final String documentName;

  /// Краткое описание документа
  final String? description;

  /// Релевантность (0.0–1.0), если backend возвращает score
  final double? relevanceScore;

  /// Цитата — конкретный фрагмент документа, на который опирается ответ.
  final String? quote;

  /// Раздел документа («4.2. Экзаменационные сессии»).
  final String? section;

  /// Тип документа («Положение», «Приказ», «План»).
  final String? documentType;

  /// Дата документа.
  final DateTime? date;

  const Source({
    required this.documentName,
    this.description,
    this.relevanceScore,
    this.quote,
    this.section,
    this.documentType,
    this.date,
  });

  @override
  List<Object?> get props => [
        documentName,
        description,
        relevanceScore,
        quote,
        section,
        documentType,
        date,
      ];
}
