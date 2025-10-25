import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../network/dio_client.dart';
import '../network/network_info.dart';


final getIt = GetIt.instance;

Future<void> initializeDependencies() async {
  // External dependencies
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerLazySingleton<SharedPreferences>(() => sharedPreferences);
  
  getIt.registerLazySingleton<Connectivity>(() => Connectivity());
  
  // Core
  getIt.registerLazySingleton<DioClient>(() => DioClient());
  getIt.registerLazySingleton<Dio>(() => getIt<DioClient>().dio);
  
  getIt.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(getIt<Connectivity>()),
  );

  // Data sources
  getIt.registerLazySingleton<UserRemoteDataSource>(
    () => UserRemoteDataSourceImpl(getIt<DioClient>()),
  );
  
  getIt.registerLazySingleton<UserLocalDataSource>(
    () => UserLocalDataSourceImpl(getIt<SharedPreferences>()),
  );

  // Repository
  getIt.registerLazySingleton<UserRepository>(
    () => UserRepositoryImpl(
      remoteDataSource: getIt<UserRemoteDataSource>(),
      localDataSource: getIt<UserLocalDataSource>(),
      networkInfo: getIt<NetworkInfo>(),
    ),
  );

  // Use cases
  getIt.registerLazySingleton<GetUsers>(
    () => GetUsers(getIt<UserRepository>()),
  );
  
  getIt.registerLazySingleton<GetUserDetail>(
    () => GetUserDetail(getIt<UserRepository>()),
  );
  
  getIt.registerLazySingleton<SearchUsers>(
    () => SearchUsers(getIt<UserRepository>()),
  );

  // Blocs
  getIt.registerFactory<UserBloc>(
    () => UserBloc(
      getUsers: getIt<GetUsers>(),
      getUserDetail: getIt<GetUserDetail>(),
      searchUsers: getIt<SearchUsers>(),
    ),
  );
  
  getIt.registerFactory<ConnectivityBloc>(
    () => ConnectivityBloc(getIt<NetworkInfo>()),
  );
}

Future<void> resetDependencies() async {
  await getIt.reset();
}