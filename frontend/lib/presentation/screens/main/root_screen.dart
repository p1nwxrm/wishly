import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';

import '../../../core/di/injection.dart';
import '../../../core/router/app_router.dart';
import '../../blocs/blocs.dart';

@RoutePage()
class RootScreen extends StatelessWidget {
  const RootScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AutoTabsScaffold(
      routes: const [
        FeedRoute(),
        SearchRoute(),
        MyProfileRoute(),
      ],

      bottomNavigationBuilder: (_, tabsRouter) {
        return NavigationBar(
          // Current selected tab index
          selectedIndex: tabsRouter.activeIndex,

          // Switch tabs when a user taps an icon
          onDestinationSelected: (index) {
            if (tabsRouter.activeIndex == index) {
              getIt<TabRefreshCubit>().refreshTab(index);
            } else {
              tabsRouter.setActiveIndex(index);
            }
          },

          // Styling using our AppTheme color scheme
          backgroundColor: Theme.of(context).colorScheme.surface,
          indicatorColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),

          // The individual buttons in the bottom bar
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Feed',
            ),
            NavigationDestination(
              icon: Icon(Icons.search_outlined),
              selectedIcon: Icon(Icons.search),
              label: 'Search',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        );
      },
    );
  }
}