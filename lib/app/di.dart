/// Настройка внедрения зависимостей (Dependency Injection).
///
/// Используем GetIt как Service Locator.
/// Все зависимости регистрируются один раз при старте приложения.
/// Порядок регистрации: core → data → domain → presentation.
library;

import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/api/api_client.dart';
import '../core/api/token_storage.dart';

// Auth
import '../features/auth/data/datasources/auth_remote_datasource.dart';
import '../features/auth/data/repositories/auth_repository_impl.dart';
import '../features/auth/domain/repositories/auth_repository.dart';
import '../features/auth/domain/usecases/auth_usecases.dart';
import '../features/auth/presentation/bloc/auth_bloc.dart';

// Chat
import '../features/chat/data/datasources/chat_remote_datasource.dart';
import '../features/chat/data/repositories/chat_repository_impl.dart';
import '../features/chat/domain/repositories/chat_repository.dart';
import '../features/chat/domain/usecases/chat_usecases.dart';
import '../features/chat/presentation/bloc/chat_bloc.dart';
import '../features/chat/presentation/bloc/conversation_list_bloc.dart';

/// Глобальный экземпляр GetIt (Service Locator)
final sl = GetIt.instance;

/// Инициализация всех зависимостей.
///
/// Вызывается один раз в main() до runApp().
/// Порядок важен: сначала core, затем data/domain, в конце presentation.
Future<void> initDependencies() async {
  // ═══════════════════ Core ═══════════════════

  // SharedPreferences (async инициализация)
  final prefs = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(prefs);

  // Хранилище токенов
  sl.registerSingleton<TokenStorage>(TokenStorage(sl()));

  // HTTP-клиент
  sl.registerSingleton<ApiClient>(
    ApiClient(tokenStorage: sl()),
  );

  // ═══════════════════ Auth ═══════════════════

  // Data layer
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSource(apiClient: sl(), tokenStorage: sl()),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl(), tokenStorage: sl()),
  );

  // Domain layer (use cases)
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));

  // Presentation layer (BLoC)
  sl.registerFactory<AuthBloc>(
    () => AuthBloc(
      loginUseCase: sl(),
      registerUseCase: sl(),
      getCurrentUserUseCase: sl(),
      logoutUseCase: sl(),
    ),
  );

  // ═══════════════════ Chat ═══════════════════

  // Data layer
  sl.registerLazySingleton<ChatRemoteDataSource>(
    () => ChatRemoteDataSource(apiClient: sl()),
  );
  sl.registerLazySingleton<ChatRepository>(
    () => ChatRepositoryImpl(remoteDataSource: sl()),
  );

  // Domain layer (use cases)
  sl.registerLazySingleton(() => GetConversationsUseCase(sl()));
  sl.registerLazySingleton(() => CreateConversationUseCase(sl()));
  sl.registerLazySingleton(() => RenameConversationUseCase(sl()));
  sl.registerLazySingleton(() => DeleteConversationUseCase(sl()));
  sl.registerLazySingleton(() => GetMessagesUseCase(sl()));
  sl.registerLazySingleton(() => SendMessageUseCase(sl()));

  // Presentation layer (BLoC-и)
  sl.registerFactory<ConversationListBloc>(
    () => ConversationListBloc(
      getConversations: sl(),
      createConversation: sl(),
      renameConversation: sl(),
      deleteConversation: sl(),
    ),
  );
  sl.registerFactory<ChatBloc>(
    () => ChatBloc(
      getMessages: sl(),
      sendMessage: sl(),
    ),
  );
}
