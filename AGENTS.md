# AGENTS.md — Правила для ИИ-ассистентов и разработчиков

## Архитектурные ограничения

- **Архитектура**: feature-first. Каждая feature содержит `data/`, `domain/`, `presentation/`.
- **State management**: только BLoC (flutter_bloc). Никаких Provider, Riverpod, MobX.
- **Роутинг**: только GoRouter (go_router). Никакого Navigator.push.
- **DI**: только GetIt. Регистрация зависимостей — в `app/di.dart`.
- **HTTP**: только через `ApiClient` (Dio). Никаких прямых http-вызовов из feature.
- **Ошибки**: все ошибки → `Failure`. Используем `Either<Failure, T>` из dartz.

## Стиль именования

- **Файлы**: `snake_case.dart`
- **Классы**: `PascalCase`
- **Методы/переменные**: `camelCase`
- **Константы**: `camelCase` (в Dart константы пишутся в camelCase)
- **BLoC события**: `{Feature}{Action}Requested` (например `AuthLoginRequested`)
- **BLoC состояния**: `{Feature}{State}` (например `AuthAuthenticated`)
- **Use cases**: `{Verb}{Noun}UseCase` (например `SendMessageUseCase`)
- **Репозитории**: `{Feature}Repository` (интерфейс), `{Feature}RepositoryImpl` (реализация)

## Правила создания новых feature

1. Создать папку `lib/features/{feature_name}/`
2. Внутри обязательно: `data/`, `domain/`, `presentation/`
3. `domain/entities/` — чистые сущности (Equatable, без JSON)
4. `domain/repositories/` — абстрактные контракты
5. `domain/usecases/` — по одному use case на действие
6. `data/models/` — модели с fromJson/toJson
7. `data/datasources/` — HTTP-вызовы через ApiClient
8. `data/repositories/` — реализация контрактов (try/catch → Either)
9. `presentation/bloc/` — BLoC + Events + States
10. `presentation/pages/` — страницы (подключают BLoC)
11. `presentation/widgets/` — переиспользуемые виджеты feature
12. Создать `README.md` в папке feature

## Где МОЖНО размещать бизнес-логику

- `domain/usecases/` — основная бизнес-логика
- `presentation/bloc/` — логика координации UI-состояний

## Где НЕЛЬЗЯ размещать сетевые вызовы

- `presentation/` — виджеты, BLoC, страницы
- `domain/` — сущности, контракты, use cases
- Только в `data/datasources/`!

## Как писать тесты

```dart
// Unit-тест use case
test('login — успешный вход', () async {
  when(() => mockRepo.login(username: 'user', password: 'pass'))
      .thenAnswer((_) async => Right(testUser));

  final result = await loginUseCase(username: 'user', password: 'pass');

  expect(result, Right(testUser));
  verify(() => mockRepo.login(username: 'user', password: 'pass')).called(1);
});
```

```dart
// BLoC-тест
blocTest<AuthBloc, AuthState>(
  'emits [AuthLoading, AuthAuthenticated] при успешном логине',
  build: () => authBloc,
  act: (bloc) => bloc.add(AuthLoginRequested(username: 'u', password: 'p')),
  expect: () => [AuthLoading(), AuthAuthenticated(testUser)],
);
```

## Как документировать код

- DartDoc (`///`) для всех публичных классов, методов, полей
- Комментарии на русском (с англицизмами где уместно)
- Не дублировать код в комментарии, а объяснять ЗАЧЕМ и КОНТРАКТ
- Каждая feature — свой `README.md`

## Как оформлять PR

- Название: `feat(chat): добавить индикатор статуса ИИ`
- Описание: что сделано, почему, как тестировать
- Линтинг: `flutter analyze` без ошибок
- Тесты: `flutter test` проходят
- Форматирование: `dart format lib/ test/`
