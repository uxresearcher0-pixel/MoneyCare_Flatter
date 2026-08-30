import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'data/providers/app_data.dart';

void main() {
  runApp(const ProviderScope(child: MoneyCareApp()));
}

class MoneyCareApp extends ConsumerWidget {
  const MoneyCareApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // goRouterProvider is created exactly once (see app_router.dart) so this
    // watch never rebuilds MaterialApp.router's routerConfig identity.
    final router = ref.watch(goRouterProvider);
    // Watched separately so preference changes (theme, etc.) rebuild the app
    // shell without touching the router.
    final themeMode = ref.watch(appDataProvider.select((d) => d.themeMode));

    return MaterialApp.router(
      title: 'Money Care',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
