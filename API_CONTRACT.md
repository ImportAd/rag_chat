# API-контракт: Чат с ИИ-ассистентом (rag_chat)

Этот документ описывает **все HTTP-эндпоинты**, которые Flutter-клиент ожидает от backend.

**Base URL**: задаётся через переменную окружения `API_BASE_URL` (по умолчанию `http://localhost:8000/api/v1`).

---

## 1. Авторизация

### POST `/auth/login`
Вход по логину и паролю.

**Запрос:**
```json
{
  "username": "ivanov",
  "password": "secret123"
}
```

**Ответ (200):**
```json
{
  "access_token": "eyJ...",
  "refresh_token": "eyJ...",
  "user": {
    "id": "uuid-1234",
    "username": "ivanov",
    "full_name": "Иванов Иван Иванович",
    "role": "student",
    "department": "ЮИ-21",
    "language": "ru"
  }
}
```

**Ошибки:**
- `401` — Неверный логин или пароль: `{"detail": "Неверные учётные данные"}`
- `422` — Ошибка валидации

---

### POST `/auth/register`
Регистрация нового студента. Сотрудники создаются вручную.

**Запрос:**
```json
{
  "username": "petrov",
  "password": "password1",
  "full_name": "Петров Пётр Петрович",
  "department": "ЮИ-22"
}
```

**Ответ (201):** аналогичен `/auth/login`.

**Ошибки:**
- `409` — Логин уже занят: `{"detail": "Пользователь с таким логином уже существует"}`

---

### POST `/auth/refresh`
Обновить access-токен.

**Запрос:**
```json
{
  "refresh_token": "eyJ..."
}
```

**Ответ (200):**
```json
{
  "access_token": "eyJ...",
  "refresh_token": "eyJ..."
}
```

**Ошибки:**
- `401` — refresh-токен невалиден или истёк

---

### POST `/auth/logout`
Инвалидировать refresh-токен.

**Заголовки:** `Authorization: Bearer {access_token}`

**Ответ:** `204 No Content`

---

## 2. Профиль

### GET `/users/me`
Получить данные текущего пользователя.

**Заголовки:** `Authorization: Bearer {access_token}`

**Ответ (200):**
```json
{
  "id": "uuid-1234",
  "username": "ivanov",
  "full_name": "Иванов Иван Иванович",
  "role": "student",
  "department": "ЮИ-21",
  "language": "ru"
}
```

Возможные значения `role`: `"student"`, `"staff"`, `"admin"`.

---

## 3. Диалоги (Conversations)

### GET `/chat/conversations?page=1&limit=20`
Список чатов текущего пользователя, отсортированных по `updated_at` (новые первые).

**Ответ (200):**
```json
{
  "items": [
    {
      "id": "conv-uuid-1",
      "title": "Вопрос про зачётную книжку",
      "created_at": "2026-03-10T10:00:00Z",
      "updated_at": "2026-03-10T14:30:00Z",
      "message_count": 12
    }
  ],
  "total": 42,
  "page": 1,
  "limit": 20
}
```

---

### POST `/chat/conversations`
Создать новый чат.

**Запрос:** `{}` (пустое тело)

**Ответ (201):**
```json
{
  "id": "conv-uuid-new",
  "title": "Новый чат",
  "created_at": "2026-03-10T15:00:00Z",
  "updated_at": "2026-03-10T15:00:00Z",
  "message_count": 0
}
```

---

### PUT `/chat/conversations/{id}`
Переименовать чат.

**Запрос:**
```json
{
  "title": "Новое название чата"
}
```

**Ответ (200):** обновлённый объект Conversation.

---

### DELETE `/chat/conversations/{id}`
Удалить чат и всю историю.

**Ответ:** `204 No Content`

---

## 4. Сообщения (Messages)

### GET `/chat/conversations/{id}/messages?page=1&limit=50`
История сообщений (от старых к новым).

**Ответ (200):**
```json
{
  "items": [
    {
      "id": "msg-uuid-1",
      "conversation_id": "conv-uuid-1",
      "role": "user",
      "content": "Как получить справку?",
      "status": "completed",
      "source_type": null,
      "sources": null,
      "timestamp": "2026-03-10T10:01:00Z"
    },
    {
      "id": "msg-uuid-2",
      "conversation_id": "conv-uuid-1",
      "role": "assistant",
      "content": "Для получения справки обратитесь...",
      "status": "completed",
      "source_type": "rag_found",
      "sources": [
        {
          "document_name": "Регламент выдачи справок",
          "description": "Порядок выдачи справок студентам очной формы",
          "relevance_score": 0.92
        }
      ],
      "timestamp": "2026-03-10T10:01:15Z"
    }
  ],
  "total": 12,
  "page": 1,
  "limit": 50
}
```

**Значения `role`:** `"user"`, `"assistant"`, `"system"`

**Значения `status`:** `"sent"`, `"searching"`, `"refining"`, `"generating"`, `"completed"`, `"error"`

**Значения `source_type`:**
- `"rag_found"` — информация найдена в RAG-базе
- `"rag_not_found"` — информация не найдена в RAG-базе
- `"no_rag"` — ответ без опоры на внутреннюю базу
- `null` — для сообщений пользователя

---

### POST `/chat/conversations/{id}/send`
Отправить сообщение и получить ответ ИИ.

**Запрос:**
```json
{
  "content": "Текст вопроса пользователя"
}
```

**Ответ (200):** объект Message (ответ ИИ).

**Ошибки:**
- `429` — Превышен лимит запросов:
  ```json
  {
    "detail": "Слишком много запросов",
    "retry_after": 10
  }
  ```
- `503` — Система занята:
  ```json
  {
    "detail": "Система сейчас занята, попробуйте через несколько секунд."
  }
  ```
- `504` — Таймаут обработки (>60 сек)

---

## 5. Системное

### GET `/health`
Проверка здоровья backend.

**Ответ (200):**
```json
{
  "status": "ok",
  "version": "1.0.0"
}
```

---

## Общие соглашения

| Аспект | Соглашение |
|---|---|
| Авторизация | `Authorization: Bearer {access_token}` во всех запросах (кроме login/register) |
| Формат дат | ISO 8601 UTC: `2026-03-10T14:30:00Z` |
| Пагинация | `page` (начиная с 1) + `limit` |
| ID | UUID строковые |
| Ошибки | `{"detail": "Текст ошибки"}` |
| Rate limiting | Заголовки: `X-RateLimit-Limit`, `X-RateLimit-Remaining`, `X-RateLimit-Reset` |
| Права доступа RAG | Backend фильтрует источники по правам пользователя. Клиент **никогда** не получает недоступные источники. |

## Лимиты

| Параметр | Значение |
|---|---|
| Максимальная длина сообщения | 2000 символов |
| Сообщений в минуту (на пользователя) | 10 |
| Сообщений в час (на пользователя) | 100 |
| Одновременных запросов (на пользователя) | 1 |
| Одновременных chat-запросов (на систему) | 3 |
| Очередь запросов (на систему) | 10 |
| Таймаут обработки одного запроса | 60 секунд |
