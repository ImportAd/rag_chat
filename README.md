# RAG Chat — Чат с ИИ-ассистентом

Университет правосудия — Flutter Web-клиент для чата с ИИ на основе RAG-системы.

## Назначение

Веб-приложение для студентов и сотрудников, позволяющее задавать вопросы ИИ-ассистенту.
Ответы формируются на основе внутренней базы знаний университета (RAG) с учётом прав доступа пользователя.

## Стек технологий

- **Flutter 3.41.x** (stable) — целевая платформа: Web
- **Dart 3.2+**
- **BLoC** — управление состоянием
- **GoRouter** — декларативная маршрутизация
- **Dio** — HTTP-клиент
- **GetIt** — внедрение зависимостей
- **dartz** — функциональное программирование (Either)

## Минимальные требования

- Flutter SDK ≥ 3.41.0
- Dart SDK ≥ 3.2.0
- Backend API (FastAPI) — см. корневые [api-contracts.md](../api-contracts.md) и [api-endpoints-models.md](../api-endpoints-models.md)

## Быстрый старт

```bash
# 1. Клонировать и перейти в папку
cd rag_chat

# 2. Установить зависимости
flutter pub get

# 3. Запустить (web, dev mode)
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:8000/api/v1

# 4. Собрать для продакшена
flutter build web --dart-define=API_BASE_URL=https://your-server.ru/api/v1
```

## Конфигурация окружения

| Переменная | Описание | По умолчанию |
|---|---|---|
| `API_BASE_URL` | URL backend API | `http://localhost:8000/api/v1` |

Передаётся через `--dart-define` при сборке/запуске.

## Архитектура

**Feature-first** с обязательными слоями внутри каждой feature:

```
lib/
├── app/                    # Конфигурация приложения
│   ├── app.dart            # Корневой виджет
│   ├── di.dart             # Dependency Injection (GetIt)
│   ├── router.dart         # GoRouter
│   └── theme.dart          # Material Theme
├── core/                   # Общие модули
│   ├── api/                # HTTP-клиент, токены, эндпоинты
│   ├── constants/          # Глобальные константы
│   ├── errors/             # Failure-иерархия
│   ├── utils/              # Валидация, форматирование дат
│   └── widgets/            # Общие виджеты (EmptyState, ErrorDisplay)
├── features/
│   ├── auth/               # Авторизация и регистрация
│   │   ├── data/           # Модели, datasource, репозиторий
│   │   ├── domain/         # Сущности, контракт репозитория, use cases
│   │   └── presentation/   # BLoC, страницы, виджеты
│   ├── chat/               # Чат с ИИ
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   └── profile/            # Профиль пользователя
│       └── presentation/
└── main.dart               # Точка входа
```

## Описание фич

### auth (Авторизация)
Вход по логину/паролю, регистрация студентов, хранение JWT-токенов, автоматическое обновление access-токена.

### chat (Чат с ИИ)
Список диалогов (боковая панель), создание/удаление/переименование чатов, отправка сообщений, отображение ответов ИИ с Markdown, индикатор статуса обработки, источники ответа, rate limiting на клиенте.

### profile (Профиль)
Отображение ФИО, роли, отдела, логина. Кнопка выхода из системы.

## Команды

```bash
# Запуск (web)
flutter run -d chrome

# Сборка (web, release)
flutter build web --release

# Тесты
flutter test

# Генерация кода (freezed, json_serializable)
dart run build_runner build --delete-conflicting-outputs

# Линтинг
flutter analyze

# Форматирование
dart format lib/ test/
```

## Работа с API

Клиент — чистый frontend. Вся бизнес-логика (права доступа, RAG, LLM) на backend.
Полный контракт API: [../api-contracts.md](../api-contracts.md) и [../api-endpoints-models.md](../api-endpoints-models.md).

## Адаптивность

- **Desktop** (≥1200px): боковая панель + область чата
- **Tablet** (≥768px): боковая панель + область чата (компактнее)
- **Mobile** (<768px): Drawer с чатами + полноэкранный чат

## Правила внесения изменений

1. Новая feature → создавать папку `features/имя/` с подпапками `data/`, `domain/`, `presentation/`
2. Каждая feature — изолирована, зависит только от `core/`
3. Бизнес-логика — только в `domain/usecases/`
4. Сетевые вызовы — только в `data/datasources/`
5. BLoC — только в `presentation/bloc/`
6. Комментарии — на русском
7. DartDoc — для всех публичных классов и методов
