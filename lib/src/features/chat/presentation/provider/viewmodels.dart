import 'package:buzz/src/core/injections/app_container.dart';
import 'package:buzz/src/features/chat/presentation/provider/chat_viewmodel.dart';
import 'package:buzz/src/features/settings/settings_controller.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

export 'chat_viewmodel.dart';

final chatProviders = <SingleChildWidget>[
  ChangeNotifierProvider<ChatProvider>(
    create: (_) => locator<ChatProvider>(),
  ),
  ChangeNotifierProvider<SettingsController>(
    create: (_) => GetIt.I<SettingsController>(),
  ),
];
