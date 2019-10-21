import 'package:dio/dio.dart';
import 'package:flutter_template/repository/api.dart';
import 'package:flutter_template/repository/flutter_api.dart';
import 'package:flutter_template/repository/flutter_shared_prefs.dart';
import 'package:flutter_template/repository/locale_repository.dart';
import 'package:flutter_template/repository/shared_prefs.dart';
import 'package:flutter_template/repository/user_repository.dart';
import 'package:flutter_template/util/env/flavor_config.dart';
import 'package:flutter_template/util/interceptor/network_log_interceptor.dart';
import 'package:flutter_template/viewmodel/home/home_viewmodel.dart';
import 'package:flutter_template/viewmodel/locale/locale_viewmodel.dart';
import 'package:flutter_template/viewmodel/splash/splash_viewmodel.dart';
import 'package:kiwi/kiwi.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'injector.g.dart';

abstract class Injector {
  @Register.factory(NetworkLogInterceptor)
  void registerNetworkDependencies();

  @Register.singleton(UserRepository)
  @Register.singleton(LocaleRepository)
  @Register.factory(Api, from: FlutterApi)
  @Register.singleton(SharedPrefs, from: FlutterSharedPrefs)
  void registerCommonDependencies();

  @Register.factory(HomeViewModel)
  @Register.factory(SplashViewModel)
  @Register.factory(LocaleViewModel)
  void registerViewModelFactories();
}

Future<void> setupDependencyTree() async {
  await provideSharedPreferences();
  final injector = _$Injector()..registerNetworkDependencies();
  Container().registerSingleton((c) => provideDio(c.resolve()));
  injector
    ..registerCommonDependencies()
    ..registerViewModelFactories();
}

Future<void> provideSharedPreferences() async {
  final sharedPreferences = await SharedPreferences.getInstance();
  Container().registerSingleton((c) => sharedPreferences);
}

Dio provideDio(NetworkLogInterceptor networkInterceptor) {
  final dio = Dio();
  dio.options.baseUrl = FlavorConfig.instance.values.baseUrl;
  dio.interceptors.add(networkInterceptor);
  return dio;
}
