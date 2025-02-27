import 'package:buzz/src/core/route/go_router.dart';
import 'package:buzz/src/features/chat/presentation/screen/dialog_screen.dart';
import 'package:go_router/go_router.dart';

final chatRoutes = [
  GoRoute(
      path: '/',
      pageBuilder: (context, state) =>
          getScreenTransition(const ChatDialogScreen(), state)),
];
