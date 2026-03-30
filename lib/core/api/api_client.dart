/// HTTP-клиент на базе Dio с автоматическим управлением JWT-токенами.
///
/// Основные возможности:
/// - Автоматическая подстановка access-токена в заголовок Authorization
/// - Автоматическое обновление токена при 401-ответе
/// - Централизованная обработка ошибок → [Failure]
/// - Логирование запросов (только в debug)
library;

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../constants/app_constants.dart';
import '../errors/failures.dart';
import 'api_endpoints.dart';
import 'token_storage.dart';

/// Главный HTTP-клиент приложения.
///
/// Все сетевые вызовы проходят через этот класс.
/// Никакие data-источники не создают свои Dio-инстансы.
class ApiClient {
  late final Dio _dio;
  final TokenStorage _tokenStorage;

  /// Флаг: сейчас идёт процесс обновления токена
  bool _isRefreshing = false;

  ApiClient({required TokenStorage tokenStorage})
      : _tokenStorage = tokenStorage {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.apiBaseUrl,
        connectTimeout:
            const Duration(milliseconds: AppConstants.connectionTimeoutMs),
        receiveTimeout:
            const Duration(milliseconds: AppConstants.receiveTimeoutMs),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Интерсептор: подставляем access-токен в каждый запрос
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: _onRequest,
        onError: _onError,
      ),
    );
  }

  // ───────────────── Публичные методы ─────────────────

  /// GET-запрос с автоматической обработкой ошибок
  Future<Either<Failure, Response>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    return _safeRequest(
      () => _dio.get(path, queryParameters: queryParameters),
    );
  }

  /// POST-запрос с автоматической обработкой ошибок
  Future<Either<Failure, Response>> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    return _safeRequest(
      () => _dio.post(path, data: data, queryParameters: queryParameters),
    );
  }

  /// PUT-запрос с автоматической обработкой ошибок
  Future<Either<Failure, Response>> put(
    String path, {
    dynamic data,
  }) async {
    return _safeRequest(
      () => _dio.put(path, data: data),
    );
  }

  /// DELETE-запрос с автоматической обработкой ошибок
  Future<Either<Failure, Response>> delete(String path) async {
    return _safeRequest(
      () => _dio.delete(path),
    );
  }

  /// Прямой доступ к Dio (для кастомных запросов, например multipart)
  Dio get dio => _dio;

  // ───────────────── Приватные методы ─────────────────

  /// Обёртка: выполняет запрос и конвертирует исключения в [Failure]
  Future<Either<Failure, Response>> _safeRequest(
    Future<Response> Function() request,
  ) async {
    try {
      final response = await request();
      return Right(response);
    } on DioException catch (e) {
      return Left(_mapDioException(e));
    } catch (e) {
      return const Left(UnknownFailure());
    }
  }

  /// Подставляем Bearer-токен перед каждым запросом
  void _onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    final token = _tokenStorage.accessToken;
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  /// Обработка ошибок: при 401 пытаемся обновить токен
  Future<void> _onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // Если 401 и это НЕ запрос на обновление токена — пробуем refresh
    if (err.response?.statusCode == 401 &&
        !err.requestOptions.path.contains(ApiEndpoints.refreshToken) &&
        !_isRefreshing) {
      _isRefreshing = true;
      try {
        final refreshed = await _tryRefreshToken();
        if (refreshed) {
          // Повторяем исходный запрос с новым токеном
          final retryResponse = await _retryRequest(err.requestOptions);
          _isRefreshing = false;
          return handler.resolve(retryResponse);
        }
      } catch (_) {
        // Если refresh не удался — очищаем токены
      }
      _isRefreshing = false;
      await _tokenStorage.clearTokens();
    }
    handler.next(err);
  }

  /// Попытка обновить access-токен через refresh-токен
  Future<bool> _tryRefreshToken() async {
    final refreshToken = _tokenStorage.refreshToken;
    if (refreshToken == null) return false;

    try {
      // Создаём чистый Dio без интерсепторов, чтобы не попасть в цикл
      final refreshDio = Dio(BaseOptions(
        baseUrl: AppConstants.apiBaseUrl,
        headers: {'Content-Type': 'application/json'},
      ));

      final response = await refreshDio.post(
        ApiEndpoints.refreshToken,
        data: {'refresh_token': refreshToken},
      );

      if (response.statusCode == 200) {
        final newAccess = response.data['access_token'] as String;
        final newRefresh = response.data['refresh_token'] as String;
        await _tokenStorage.saveTokens(
          accessToken: newAccess,
          refreshToken: newRefresh,
        );
        return true;
      }
    } catch (_) {
      // refresh не удался — возвращаем false
    }
    return false;
  }

  /// Повторить запрос с обновлёнными заголовками
  Future<Response> _retryRequest(RequestOptions requestOptions) {
    requestOptions.headers['Authorization'] =
        'Bearer ${_tokenStorage.accessToken}';
    return _dio.fetch(requestOptions);
  }

  /// Маппинг Dio-исключений в наши типы [Failure]
  Failure _mapDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const TimeoutFailure();

      case DioExceptionType.connectionError:
        return const NetworkFailure();

      case DioExceptionType.badResponse:
        return _mapStatusCode(e.response);

      default:
        return const UnknownFailure();
    }
  }

  /// Маппинг HTTP-статус кодов в [Failure]
  Failure _mapStatusCode(Response? response) {
    final statusCode = response?.statusCode;
    final data = response?.data;

    // Пытаемся достать сообщение от backend
    final serverMessage = data is Map ? data['detail'] as String? : null;

    switch (statusCode) {
      case 400:
        return ServerFailure(
          message: serverMessage ?? 'Некорректный запрос.',
          statusCode: 400,
        );
      case 401:
        return const SessionExpiredFailure();
      case 403:
        return const ServerFailure(
          message: 'Доступ запрещён.',
          statusCode: 403,
        );
      case 404:
        return const ServerFailure(
          message: 'Ресурс не найден.',
          statusCode: 404,
        );
      case 409:
        return ServerFailure(
          message: serverMessage ?? 'Конфликт данных.',
          statusCode: 409,
        );
      case 422:
        return ServerFailure(
          message: serverMessage ?? 'Ошибка валидации данных.',
          statusCode: 422,
        );
      case 429:
        final retryAfter = data is Map ? data['retry_after'] as int? : null;
        return RateLimitFailure(retryAfterSec: retryAfter);
      case 503:
        return const SystemBusyFailure();
      default:
        return ServerFailure(
          message: serverMessage ?? 'Ошибка сервера. Попробуйте позже.',
          statusCode: statusCode,
        );
    }
  }
}
