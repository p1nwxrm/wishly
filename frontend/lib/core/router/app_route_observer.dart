import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:talker_flutter/talker_flutter.dart';

class AppRouteObserver extends AutoRouterObserver {
  final Talker talker;

  AppRouteObserver(this.talker);

  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    if (route.settings.name != null) {
      talker.info('[Route] Pushed: ${route.settings.name}');
    }
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
    if (route.settings.name != null) {
      talker.info('[Route] Popped: ${route.settings.name}');
    }
  }

  @override
  void didChangeTabRoute(TabPageRoute route, TabPageRoute previousRoute) {
    talker.info('[Route] Tab Changed to: ${route.name}');
  }

  @override
  void didInitTabRoute(TabPageRoute route, TabPageRoute? previousRoute) {
    talker.info('[Route] Tab Initialized: ${route.name}');
  }
}