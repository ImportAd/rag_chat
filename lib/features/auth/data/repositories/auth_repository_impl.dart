/// Реализация репозитория авторизации.
///
/// Связывает domain layer с data layer.
/// Обрабатывает исключения из datasource и преобразует их в [Failure].
library;

import 'package:dartz/dartz.dart';
import '../../../../core/api/token_storage.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

/// Реализация [AuthRepository].
///
/// Все методы ловят исключения и оборачивают результат в [Either].
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final TokenStorage _tokenStorage;

  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required TokenStorage tokenStorage,
  })  : _remoteDataSource = remoteDataSource,
        _tokenStorage = tokenStorage;

  @override
  Future<Either<Failure, User>> login({
    required String username,
    required String password,
  }) async {
    try {
      final user = await _remoteDataSource.login(
        username: username,
        password: password,
      );
      return Right(user);
    } catch (e) {
      return Left(AuthFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> register({
    required String username,
    required String password,
    required String fullName,
    required String department,
  }) async {
    try {
      final user = await _remoteDataSource.register(
        username: username,
        password: password,
        fullName: fullName,
        department: department,
      );
      return Right(user);
    } catch (e) {
      return Left(AuthFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> getCurrentUser() async {
    try {
      final user = await _remoteDataSource.getCurrentUser();
      return Right(user);
    } catch (e) {
      return Left(AuthFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await _remoteDataSource.logout();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  bool get isLoggedIn => _tokenStorage.hasToken;
}
