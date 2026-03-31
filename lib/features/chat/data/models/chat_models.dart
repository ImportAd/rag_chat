/// Модели данных чата для сериализации/десериализации JSON.
///
/// Каждая модель расширяет соответствующую доменную сущность
/// и добавляет методы fromJson/toJson.
library;

import '../../domain/entities/chat_entities.dart';

// ═══════════════════════ ConversationModel ═══════════════════════

/// Модель диалога с поддержкой JSON.
class ConversationModel extends Conversation {
  const ConversationModel({
    required super.id,
    required super.title,
    required super.createdAt,
    required super.updatedAt,
    super.messageCount,
  });

  /// Создать из JSON-ответа backend
  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      id: json['id'].toString(),
      title: json['title'] as String? ?? 'Новый чат',
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      messageCount: json['message_count'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };
}

// ═══════════════════════ MessageModel ═══════════════════════

/// Модель сообщения с поддержкой JSON.
class MessageModel extends Message {
  const MessageModel({
    required super.id,
    required super.conversationId,
    required super.role,
    required super.content,
    required super.status,
    super.sourceType,
    super.sources,
    required super.timestamp,
  });

  /// Создать из JSON-ответа backend
  factory MessageModel.fromJson(
    Map<String, dynamic> json, {
    required String conversationId,
  }) {
    // Парсим список источников, если есть
    List<Source>? sources;
    if (json['sources'] != null) {
      sources = (json['sources'] as List)
          .map((s) => SourceModel.fromJson(s as Map<String, dynamic>))
          .toList();
    }

    return MessageModel(
      id: json['id'].toString(),
      conversationId: conversationId,
      role: _parseRole(json['role'] as String),
      content: json['content'] as String,
      status: _parseStatus(json['status'] as String? ?? 'completed'),
      sourceType: _parseSourceType(json['source_type'] as String?),
      sources: sources,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'conversation_id': conversationId,
        'content': content,
      };

  /// Маппинг строковой роли
  static MessageRole _parseRole(String role) {
    switch (role) {
      case 'user':
        return MessageRole.user;
      case 'assistant':
        return MessageRole.assistant;
      case 'system':
        return MessageRole.system;
      default:
        return MessageRole.user;
    }
  }

  /// Маппинг строкового статуса
  static MessageStatus _parseStatus(String status) {
    switch (status) {
      case 'sent':
        return MessageStatus.sent;
      case 'searching':
        return MessageStatus.searching;
      case 'refining':
        return MessageStatus.refining;
      case 'generating':
        return MessageStatus.generating;
      case 'completed':
        return MessageStatus.completed;
      case 'error':
        return MessageStatus.error;
      default:
        return MessageStatus.completed;
    }
  }

  /// Маппинг типа источника
  static SourceType? _parseSourceType(String? sourceType) {
    if (sourceType == null) return null;
    switch (sourceType) {
      case 'rag_found':
        return SourceType.ragFound;
      case 'rag_not_found':
        return SourceType.ragNotFound;
      case 'no_rag':
        return SourceType.noRag;
      case 'off_topic':
        return SourceType.offTopic;
      default:
        return null;
    }
  }
}

// ═══════════════════════ SourceModel ═══════════════════════

/// Модель источника с поддержкой JSON.
class SourceModel extends Source {
  const SourceModel({
    required super.documentName,
    super.description,
    super.relevanceScore,
  });

  factory SourceModel.fromJson(Map<String, dynamic> json) {
    return SourceModel(
      documentName: json['doc_name'] as String,
      description: json['description'] as String?,
      relevanceScore: (json['relevance_score'] as num?)?.toDouble(),
    );
  }
}
