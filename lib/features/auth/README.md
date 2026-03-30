# Feature: auth (Авторизация)

## Назначение
Авторизация и регистрация пользователей. JWT (access + refresh tokens).

## Возможности
- Вход по логину и паролю
- Регистрация новых студентов (сотрудники создаются вручную)
- Автоматическое обновление access-токена при 401
- Хранение токенов в SharedPreferences
- Проверка сессии при запуске приложения
- Выход из системы

## Слои
- `domain/entities/user.dart` — сущность User с ролями (student/staff/admin)
- `domain/repositories/` — контракт AuthRepository
- `domain/usecases/` — LoginUseCase, RegisterUseCase, GetCurrentUserUseCase, LogoutUseCase
- `data/models/user_model.dart` — UserModel с JSON-сериализацией
- `data/datasources/` — HTTP-вызовы к /auth/*
- `data/repositories/` — AuthRepositoryImpl
- `presentation/bloc/auth_bloc.dart` — AuthBloc (события, состояния)
- `presentation/pages/` — LoginPage, RegisterPage
