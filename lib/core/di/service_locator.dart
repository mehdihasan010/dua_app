import 'dart:async';

import 'package:dua/core/base/base_presenter.dart';
import 'package:dua/core/services/audio_player_service.dart';
import 'package:dua/core/services/bookmark_service.dart';
import 'package:dua/data/error_message_handler_impl.dart';
import 'package:dua/data/services/database/database_service.dart';
import 'package:dua/domain/service/error_message_handler.dart';
import 'package:dua/presentation/home/presenter/home_presenter.dart';
import 'package:dua/presentation/prayer_time/presenter/prayer_time_presenter.dart';
import 'package:dua/presentation/ruqyah_video/presenter/video_play_list_presenter.dart';
import 'package:dua/presentation/scheduale/presenter/schedule_presenter.dart';
import 'package:dua/presentation/subcategory/presenter/sub_category_presenter.dart';
import 'package:get_it/get_it.dart';
import 'package:dua/data/datasource/local_data_source.dart';
import 'package:dua/data/repositories/dua_repository_impl.dart';
import 'package:dua/domain/repositories/dua_repository.dart';
import 'package:dua/domain/usecases/get_all_duas.dart';
import 'package:dua/presentation/all_duas/presenter/all_duas_presenter.dart';

final _serviceLocator = GetIt.instance;

T locate<T extends Object>() => _serviceLocator.get<T>();

void dislocate<T extends BasePresenter>() => unloadPresenterManually<T>();

class ServiceLocator {
  ServiceLocator._();

  static Future<void> setUp({bool startOnlyService = false}) async {
    final ServiceLocator locator = ServiceLocator._();
    await locator._setUpServices();
    if (startOnlyService) return;
    await locator._setUpDataSources();
    await locator._setUpRepositories();
    await locator._setUpUseCase();
    await locator._setUpPresenters();
  }

  Future<void> _setUpServices() async {
    _serviceLocator.registerLazySingleton<DuaDatabase>(() => DuaDatabase());
    _serviceLocator.registerLazySingleton<ErrorMessageHandler>(
        ErrorMessageHandlerImpl.new);
    _serviceLocator
        .registerLazySingleton<AudioPlayerService>(() => AudioPlayerService());
    _serviceLocator
        .registerLazySingleton<BookmarkService>(() => BookmarkService());
  }

  Future<void> _setUpDataSources() async {
    _serviceLocator.registerLazySingleton<LocalDataSource>(
        () => LocalDataSourceImpl(_serviceLocator<DuaDatabase>()));
  }

  Future<void> _setUpRepositories() async {
    _serviceLocator.registerLazySingleton<DuaRepository>(
        () => DuaRepositoryImpl(_serviceLocator<LocalDataSource>()));
  }

  Future<void> _setUpUseCase() async {
    _serviceLocator
        .registerFactory(() => GetAllDuas(_serviceLocator<DuaRepository>()));
  }

  Future<void> _setUpPresenters() async {
    _serviceLocator.registerLazySingleton(() => loadPresenter(HomePresenter()));
    _serviceLocator
        .registerLazySingleton(() => loadPresenter(PrayerTimePresenter()));
    _serviceLocator
        .registerLazySingleton(() => loadPresenter(VideoPlayListPresenter()));
    _serviceLocator
        .registerLazySingleton(() => loadPresenter(SubCategoryPresenter()));
    _serviceLocator
        .registerLazySingleton(() => loadPresenter(SchedulePresenter()));
    _serviceLocator.registerLazySingleton(
        () => loadPresenter(AllDuasPresenter(_serviceLocator<GetAllDuas>())));
  }
}
