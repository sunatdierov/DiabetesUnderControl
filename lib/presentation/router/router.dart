import 'package:diabet_app/presentation/provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/bloc.dart';
import 'bloc/event.dart';

class AppRouterDelegate extends RouterDelegate<RouteInfo>
    with PopNavigatorRouterDelegateMixin<RouteInfo>, ChangeNotifier {
  @override
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RouterBloc, Iterable<RouteInfo>>(
      buildWhen: (previous, current) => previous != current,
      builder: (context, stack) {
        if (stack.isEmpty) return Container();
        var path = '';
        final pages = <EclipsePage>[];
        for (var page in stack) {
          path += page.id;
          pages.add(
            EclipsePage(
              id: page.id,
              type: page.type,
              key: ValueKey(path),
              child: WillPopScope(
                onWillPop: () async {
                  return !Navigator.of(context).userGestureInProgress;
                },
                child: page.builder(context),
              ),
            ),
          );
        }
        return Navigator(
          key: navigatorKey,
          pages: pages,
          reportsRouteUpdateToEngine: true,
          onPopPage: (route, result) {
            if (!route.didPop(result)) return false;

            if (route.settings.name != null) {
              context.read<RouterBloc>().add(const RouterEvent.pop());
            }
            return true;
          },
        );
      },
    );
  }

  @override
  Future<void> setNewRoutePath(RouteInfo configuration) async {}
}

class EclipsePage<T> extends Page<T> {
  const EclipsePage({
    required this.child,
    required this.type,
    required String id,
    required ValueKey key,
  }) : super(key: key, name: id);

  /// The content to be shown in the [Route] created by this page.
  final Widget child;
  final PageType type;

  @override
  Route<T> createRoute(BuildContext context) {
    var _child = child;

    switch (type) {
      case PageType.screen:
        return MaterialPageRoute<T>(
          settings: this,
          builder: (_) => _child,
        );
      case PageType.dialog:
        return DialogRoute<T>(
          context: context,
          settings: this,
          builder: (_) => _child,
        );
    }
  }
}


enum PageType {
  screen,
  dialog,
}
