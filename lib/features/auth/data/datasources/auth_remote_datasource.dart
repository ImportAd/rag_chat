/// Удалённый источник данных для авторизации.
///
/// Выполняет HTTP-запросы к backend API через [ApiClient].
/// Возвращает «сырые» модели. Обработка ошибок — в репозитории.
library;

import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/api/token_storage.dart';
import '../models/user_model.dart';

/// Удалённый datasource авторизации.
///
/// Отвечает только за HTTP-вызовы, не содержит бизнес-логики.
class AuthRemoteDataSource {
  final ApiClient _apiClient;
  final TokenStorage _tokenStorage;

  AuthRemoteDataSource({
    required ApiClient apiClient,
    required TokenStorage tokenStorage,
  })  : _apiClient = apiClient,
        _tokenStorage = tokenStorage;

  /// Отправить запрос на вход, сохранить токены, вернуть пользователя.
  Future<UserModel> login({
    required String username,
    required String password,
  }) async {
    final result = await _apiClient.post(
      ApiEndpoints.login,
      data: {
        'username': username,
        'password': password,
      },
    );

    return result.fold(
      (failure) => throw Exception(failure.message),
      (response) async {
        final data = response.data as Map<String, dynamic>;
        final tokens = data['tokens'] as Map<String, dynamic>;

        // Сохраняем токены
        await _tokenStorage.saveTokens(
          accessToken: tokens['access_token'] as String,
          refreshToken: tokens['refresh_token'] as String,
        );

        // Парсим пользователя
        return UserModel.fromJson(data['user'] as Map<String, dynamic>);
      },
    );
  }

  /// Зарегистрировать нового студента, сохранить токены.
  Future<UserModel> register({
    required String username,
    required String password,
    required String fullName,
    required String department,
  }) async {
    final result = await _apiClient.post(
      ApiEndpoints.register,
      data: {
        'username': username,
        'password': password,
        'full_name': fullName,
        'department': department,
      },
    );

    return result.fold(
      (failure) => throw Exception(failure.message),
      (response) async {
        final data = response.data as Map<String, dynamic>;
        final tokens = data['tokens'] as Map<String, dynamic>;

        await _tokenStorage.saveTokens(
          accessToken: tokens['access_token'] as String,
          refreshToken: tokens['refresh_token'] as String,
        );

        return UserModel.fromJson(data['user'] as Map<String, dynamic>);
      },
    );
  }

  /// Получить профиль текущего пользователя по access-токену.
  Future<UserModel> getCurrentUser() async {
    final result = await _apiClient.get(ApiEndpoints.profile);

    return result.fold(
      (failure) => throw Exception(failure.message),
      (response) {
        return UserModel.fromJson(response.data as Map<String, dynamic>);
      },
    );
  }

  /// Выйти: инвалидировать refresh-токен на сервере, очистить локально.
  Future<void> logout() async {
    // Пытаемся сообщить серверу о выходе (не критично, если упадёт)
    try {
      final refreshToken = _tokenStorage.refreshToken;
      if (refreshToken != null && refreshToken.isNotEmpty) {
        await _apiClient.post(
          ApiEndpoints.logout,
          data: {'refresh_token': refreshToken},
        );
      }
    } catch (_) {
      // Сервер может быть недоступен — не страшно
    }
    await _tokenStorage.clearTokens();
  }
}
