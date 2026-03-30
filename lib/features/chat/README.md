# Feature: chat (Чат с ИИ)

## Назначение
Основная feature: диалоги с ИИ-ассистентом на базе RAG.

## Возможности
- Список чатов с пагинацией
- Создание, переименование, удаление чатов
- Отправка сообщений с отображением статуса обработки
- Markdown-рендеринг ответов ИИ (текст, списки, таблицы, код)
- Отображение источников (документов) в ответе
- Индикатор типа ответа (RAG найден / не найден / без RAG)
- Rate limiting на клиенте (10 сообщений/мин, 1 одновременный запрос)
- Адаптивный layout: sidebar + чат на desktop, drawer на mobile
- Копирование ответов

## Слои
- `domain/entities/chat_entities.dart` — Conversation, Message, Source
- `domain/usecases/` — CRUD чатов, отправка сообщений
- `data/models/` — JSON-модели
- `presentation/bloc/` — ConversationListBloc, ChatBloc
- `presentation/widgets/` — MessageBubble, MessageInput, ChatSidebar, AiStatusIndicator
- `presentation/pages/chat_page.dart` — главная страница
