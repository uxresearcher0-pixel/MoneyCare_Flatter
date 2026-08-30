// Basic smoke tests: the app boots, and data mutations never reset navigation.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:money_care/data/providers/app_data.dart';
import 'package:money_care/main.dart';

void main() {
  // Avoid network font fetches in the test environment.
  GoogleFonts.config.allowRuntimeFetching = false;

  testWidgets('App boots to the splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: MoneyCareApp()));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Simple money management for everyday life'), findsOneWidget);

    // Let the splash screen's auto-navigation timer fire and settle so no
    // pending timers remain when the test tears down.
    await tester.pump(const Duration(milliseconds: 1300));
    await tester.pumpAndSettle();
  });

  testWidgets(
    'Data mutations never reset navigation back to the splash/welcome screen',
    (WidgetTester tester) async {
      // Regression test for a bug where goRouterProvider watched appDataProvider
      // and rebuilt (recreating GoRouter, and with it the whole navigation
      // stack) on every single AppData.notifyListeners() call — meaning any
      // interaction that mutated data (adding a purchase, creating a
      // workspace, etc.) would silently bounce the user back to the splash
      // screen. See core/router/app_router.dart for the fix.
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(container: container, child: const MoneyCareApp()),
      );

      // Skip straight past the splash timer by marking the user authenticated
      // directly, then let the router settle on the home shell.
      container.read(appDataProvider).signIn();
      await tester.pumpAndSettle(const Duration(milliseconds: 1400));

      expect(find.text('Good morning, Shanto'), findsOneWidget);

      // Mutate AppData the way many screens do (add purchase, add
      // contribution, create workspace, ...) and confirm the dashboard is
      // still on screen afterwards instead of the app bouncing back to
      // Splash/Welcome.
      final appData = container.read(appDataProvider);
      final period = appData.activePeriod!;
      appData.addPurchase(
        periodId: period.id,
        title: 'Test purchase',
        amount: 100,
        categoryId: appData.categories.keys.first,
      );
      await tester.pumpAndSettle();

      expect(find.text('Good morning, Shanto'), findsOneWidget);
      expect(find.text('Simple money management for everyday life'), findsNothing);
      expect(find.text('Take control of your money'), findsNothing);
    },
  );
}
