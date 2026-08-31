import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_colors.dart';
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
    final largerText = ref.watch(appDataProvider.select((d) => d.largerTextEnabled));
    final reduceMotion = ref.watch(appDataProvider.select((d) => d.reduceMotionEnabled));

    // AppColors resolves every screen's colors from this flag (see its own
    // doc comment) — it must be set before the rest of the tree builds, and
    // ThemeMode.system needs the platform's live brightness to resolve.
    AppColors.brightness = switch (themeMode) {
      ThemeMode.light => Brightness.light,
      ThemeMode.dark => Brightness.dark,
      ThemeMode.system => MediaQuery.platformBrightnessOf(context),
    };

    return MaterialApp.router(
      title: 'Money Care',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(reduceMotion: reduceMotion),
      darkTheme: AppTheme.dark(reduceMotion: reduceMotion),
      themeMode: themeMode,
      routerConfig: router,
      builder: (context, child) {
        if (!largerText || child == null) return child ?? const SizedBox.shrink();
        final mediaQuery = MediaQuery.of(context);
        return MediaQuery(
          data: mediaQuery.copyWith(textScaler: const TextScaler.linear(1.2)),
          child: child,
        );
      },
    );
  }
}
