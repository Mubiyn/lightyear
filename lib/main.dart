import 'package:buzz/src/core/injections/app_container.dart';
import 'package:buzz/src/core/notification/notification.dart';
import 'package:buzz/src/core/theme/theme.dart';
import 'package:buzz/src/features/chat/presentation/provider/viewmodels.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().init();
  await AppContainer.setupLocator();
  runApp(MultiProvider(providers: [
    ...chatProviders,
  ], child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: settingsController,
      builder: (context, child) => MaterialApp.router(
        title: 'Buzz Chat App',
        debugShowCheckedModeBanner: false,
        theme: lightTheme,
        darkTheme: darkTheme,
        themeMode: settingsController.themeMode,
        routerConfig: appRouter,
      ),
    );
  }
}
