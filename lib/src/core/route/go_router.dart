import 'package:buzz/src/features/chat/presentation/route/routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

GlobalKey<NavigatorState> parentKey = GlobalKey<NavigatorState>();

GoRouter buzzRouter = GoRouter(
  navigatorKey: parentKey,
  routes: [...chatRoutes],
  initialLocation: '/',
  debugLogDiagnostics: true,
);

getScreenTransition(Widget screen, GoRouterState state) {
  return CustomTransitionPage(
      key: state.pageKey,
      child: screen,
      transitionDuration: const Duration(milliseconds: 450),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.2, 1.6);
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        var offsetAnimation = animation.drive(tween);

        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      });
}
