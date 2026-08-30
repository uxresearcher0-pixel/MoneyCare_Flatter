// Basic smoke test: the app boots to the splash screen without throwing.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

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
}
