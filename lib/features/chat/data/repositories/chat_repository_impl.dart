/// Реализация репозитория чата.
///
/// Оборачивает вызовы datasource в Either<Failure, T>.
library;

import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/chat_entities.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_remote_datasource.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource _remoteDataSource;

  ChatRepositoryImpl({required ChatRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<Either<Failure, List<Conversation>>> getConversations({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final result = await _remoteDataSource.getConversations(
        page: page,
        limit: limit,
      );
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Conversation>> createConversation() async {
    try {
      final result = await _remoteDataSource.createConversation();
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Conversation>> renameConversation({
    required String conversationId,
    required String newTitle,
  }) async {
    try {
      final result = await _remoteDataSource.renameConversation(
        conversationId: conversationId,
        newTitle: newTitle,
      );
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteConversation(
      String conversationId) async {
    try {
      await _remoteDataSource.deleteConversation(conversationId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Message>>> getMessages({
    required String conversationId,
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final result = await _remoteDataSource.getMessages(
        conversationId: conversationId,
        page: page,
        limit: limit,
      );
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Message>> sendMessage({
    required String conversationId,
    required String content,
    Function(MessageStatus status)? onStatusUpdate,
  }) async {
    try {
      final result = await _remoteDataSource.sendMessage(
        conversationId: conversationId,
        content: content,
        onStatusUpdate: onStatusUpdate,
      );
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
