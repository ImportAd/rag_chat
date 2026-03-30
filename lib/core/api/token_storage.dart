/// Сервис локального хранения JWT-токенов.
///
/// Использует SharedPreferences для персистентного хранения
/// access и refresh токенов между сессиями приложения.
/// На web-платформе SharedPreferences работает через localStorage.
library;

import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

/// Обёртка над SharedPreferences для работы с токенами авторизации.
class TokenStorage {
  final SharedPreferences _prefs;

  TokenStorage(this._prefs);

  // ───────────────── Access Token ─────────────────

  /// Получить текущий access-токен, или null если его нет
  String? get accessToken => _prefs.getString(AppConstants.accessTokenKey);

  /// Сохранить access-токен
  Future<bool> setAccessToken(String token) =>
      _prefs.setString(AppConstants.accessTokenKey, token);

  // ───────────────── Refresh Token ─────────────────

  /// Получить текущий refresh-токен, или null если его нет
  String? get refreshToken => _prefs.getString(AppConstants.refreshTokenKey);

  /// Сохранить refresh-токен
  Future<bool> setRefreshToken(String token) =>
      _prefs.setString(AppConstants.refreshTokenKey, token);

  // ───────────────── Управление сессией ─────────────────

  /// Сохранить оба токена (после логина или обновления)
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await setAccessToken(accessToken);
    await setRefreshToken(refreshToken);
  }

  /// Удалить все токены (при выходе из системы)
  Future<void> clearTokens() async {
    await _prefs.remove(AppConstants.accessTokenKey);
    await _prefs.remove(AppConstants.refreshTokenKey);
  }

  /// Проверить, есть ли сохранённый access-токен
  bool get hasToken => accessToken != null && accessToken!.isNotEmpty;
}
