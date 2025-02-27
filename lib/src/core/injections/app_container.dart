import 'package:buzz/src/core/notification/notification.dart';
import 'package:buzz/src/core/route/go_router.dart';
import 'package:buzz/src/features/chat/data/data.dart';
import 'package:buzz/src/features/chat/domain/models/models.dart';
import 'package:buzz/src/features/chat/presentation/provider/viewmodels.dart';
import 'package:buzz/src/features/settings/settings_controller.dart';
import 'package:buzz/src/features/settings/settings_service.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

final locator = GetIt.instance;

final appRouter = locator<GoRouter>();

final prefs = locator<SharedPreferences>();

final settingsController = locator<SettingsController>();
NotificationService notificationService = locator<NotificationService>();

class AppContainer {
  static Future<void> setupLocator() async {
    locator.registerLazySingleton<GoRouter>(() => buzzRouter);
    HiveInjectionContainer.initialize();
    final sharedPreferences = await SharedPreferences.getInstance();
    locator.registerLazySingleton(() => sharedPreferences);
    locator.registerFactory<SettingsService>(() => SettingsService());
    locator.registerLazySingleton<SettingsController>(
        () => SettingsController(locator()));
    locator<SettingsController>().loadSettings();
    locator.registerLazySingleton<NotificationService>(
      () => NotificationService(),
    );
    locator<NotificationService>().init();

    locator.registerLazySingleton<LocalStorage>(() => LocalStorage());
    locator.registerLazySingleton<ChatProvider>(() => ChatProvider(locator()));

    final appDocumentDirectory = await getApplicationDocumentsDirectory();
    Hive.init(appDocumentDirectory.path);
  }
}

class HiveInjectionContainer {
  static Future<void> initialize() async {
    await Hive.initFlutter();
    Hive.registerAdapter(ChatMessageAdapter());
    Hive.registerAdapter(ChatAdapter());
    Hive.registerAdapter(MessageTypeAdapter());
  }
}
