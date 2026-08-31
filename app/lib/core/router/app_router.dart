import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/providers/app_data.dart';
import '../../features/auth/splash_screen.dart';
import '../../features/auth/welcome_screen.dart';
import '../../features/auth/sign_in_screen.dart';
import '../../features/auth/sign_up_screen.dart';
import '../../features/dashboard/home_shell.dart';
import '../../features/workspaces/create_workspace_screen.dart';
import '../../features/workspaces/workspace_list_screen.dart';
import '../../features/workspaces/workspace_overview_screen.dart';
import '../../features/projects/create_project_screen.dart';
import '../../features/projects/project_list_screen.dart';
import '../../features/projects/project_overview_screen.dart';
import '../../features/periods/period_list_screen.dart';
import '../../features/periods/create_period_screen.dart';
import '../../features/people/project_members_screen.dart';
import '../../features/people/add_person_screen.dart';
import '../../features/people/contributor_setup_screen.dart';
import '../../features/people/people_hub_screen.dart';
import '../../features/people/contributions_screen.dart';
import '../../features/people/person_details_screen.dart';
import '../../features/purchases/add_purchase_screen.dart';
import '../../features/purchases/add_contribution_screen.dart';
import '../../features/purchases/bulk_entry_screen.dart';
import '../../features/purchases/scan_receipt_screen.dart';
import '../../features/activity/transaction_activity_screen.dart';
import '../../features/activity/transaction_details_screen.dart';
import '../../features/reports/spending_overview_screen.dart';
import '../../features/budget/budget_overview_screen.dart';
import '../../features/settings/settings_hub_screen.dart';
import '../../features/settings/categories_screen.dart';
import '../../features/settings/units_screen.dart';
import '../../features/settings/contribution_types_screen.dart';
import '../../features/settings/accounts_screen.dart';
import '../../features/settings/project_details_screen.dart';
import '../../features/settings/budget_rules_screen.dart';
import '../../features/settings/carry_forward_screen.dart';
import '../../features/settings/transaction_types_screen.dart';
import '../../features/settings/payment_methods_screen.dart';
import '../../features/settings/tags_screen.dart';
import '../../features/settings/recurring_rules_screen.dart';
import '../../features/settings/language_screen.dart';
import '../../features/settings/appearance_screen.dart';
import '../../features/settings/notifications_settings_screen.dart';
import '../../features/settings/security_screen.dart';
import '../../features/settings/sync_screen.dart';
import '../../features/config/project_fields_screen.dart';
import '../../features/config/workspace_custom_fields_screen.dart';
import '../../features/config/field_editor_screen.dart';
import '../../features/config/field_templates_screen.dart';
import '../../features/config/custom_field_builder_screen.dart';
import '../../features/more/more_hub_screen.dart';
import '../../features/more/import_export_screen.dart';
import '../../features/more/archive_screen.dart';
import '../../features/more/help_screen.dart';
import '../../features/more/notifications_screen.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  // IMPORTANT: read (not watch) — GoRouter must be created exactly once.
  // `refreshListenable` below is what makes it re-evaluate `redirect` on every
  // AppData change; watching appDataProvider here would instead rebuild this
  // provider (and hand MaterialApp.router a brand-new GoRouter, resetting the
  // whole navigation stack back to `initialLocation`) on every single data
  // mutation — add a purchase, create a workspace, anything.
  final appData = ref.read(appDataProvider);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: appData,
    redirect: (context, state) {
      final loc = state.matchedLocation;
      final authRoutes = {'/splash', '/welcome', '/sign-in', '/sign-up'};
      if (!appData.isAuthenticated && !authRoutes.contains(loc)) {
        return '/welcome';
      }
      if (appData.isAuthenticated && authRoutes.contains(loc) && loc != '/splash') {
        return '/home';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (c, s) => const SplashScreen()),
      GoRoute(path: '/welcome', builder: (c, s) => const WelcomeScreen()),
      GoRoute(path: '/sign-in', builder: (c, s) => const SignInScreen()),
      GoRoute(path: '/sign-up', builder: (c, s) => const SignUpScreen()),

      GoRoute(path: '/home', builder: (c, s) => const HomeShell()),
      // Standalone push target for "See all activity" links outside the
      // bottom-nav Activity tab (which only exists embedded in HomeShell's
      // IndexedStack and isn't reachable by path on its own).
      GoRoute(path: '/activity', builder: (c, s) => const TransactionActivityScreen()),

      GoRoute(path: '/workspaces', builder: (c, s) => const WorkspaceListScreen()),
      GoRoute(
        path: '/workspace/create',
        builder: (c, s) => const CreateWorkspaceScreen(),
      ),
      GoRoute(
        path: '/workspace/:id',
        builder: (c, s) => WorkspaceOverviewScreen(workspaceId: s.pathParameters['id']!),
      ),
      GoRoute(
        path: '/workspace/:id/projects',
        builder: (c, s) => ProjectListScreen(workspaceId: s.pathParameters['id']!),
      ),

      GoRoute(
        path: '/project/create',
        builder: (c, s) => CreateProjectScreen(workspaceId: s.uri.queryParameters['workspaceId']),
      ),
      GoRoute(
        path: '/project/:id',
        builder: (c, s) => ProjectOverviewScreen(projectId: s.pathParameters['id']!),
      ),

      GoRoute(
        path: '/project/:id/periods',
        builder: (c, s) => PeriodListScreen(projectId: s.pathParameters['id']!),
      ),
      GoRoute(
        path: '/project/:id/periods/create',
        builder: (c, s) => CreatePeriodScreen(projectId: s.pathParameters['id']!),
      ),

      GoRoute(
        path: '/project/:id/people',
        builder: (c, s) => ProjectMembersScreen(projectId: s.pathParameters['id']!),
      ),
      GoRoute(
        path: '/project/:id/people/add',
        builder: (c, s) => AddPersonScreen(projectId: s.pathParameters['id']!),
      ),
      GoRoute(
        path: '/project/:id/people/:personId/setup',
        builder: (c, s) => ContributorSetupScreen(
          projectId: s.pathParameters['id']!,
          personId: s.pathParameters['personId']!,
        ),
      ),
      GoRoute(path: '/people-hub', builder: (c, s) => const PeopleHubScreen()),
      GoRoute(
        path: '/people/:id',
        builder: (c, s) => PersonDetailsScreen(personId: s.pathParameters['id']!),
      ),
      GoRoute(
        path: '/people/:id/contributions',
        builder: (c, s) => ContributionsScreen(personId: s.pathParameters['id']!),
      ),

      GoRoute(path: '/purchase/add', builder: (c, s) => const AddPurchaseScreen()),
      GoRoute(path: '/purchase/bulk', builder: (c, s) => const BulkEntryScreen()),
      GoRoute(path: '/contribution/add', builder: (c, s) => const AddContributionScreen()),
      GoRoute(path: '/scan-receipt', builder: (c, s) => const ScanReceiptScreen()),

      GoRoute(
        path: '/transaction/:id',
        builder: (c, s) => TransactionDetailsScreen(transactionId: s.pathParameters['id']!),
      ),

      GoRoute(path: '/reports/spending', builder: (c, s) => const SpendingOverviewScreen()),
      GoRoute(path: '/budget', builder: (c, s) => const BudgetOverviewScreen()),

      GoRoute(path: '/settings', builder: (c, s) => const SettingsHubScreen()),
      GoRoute(path: '/settings/categories', builder: (c, s) => const CategoriesScreen()),
      GoRoute(path: '/settings/units', builder: (c, s) => const UnitsScreen()),
      GoRoute(
        path: '/settings/contribution-types',
        builder: (c, s) => const ContributionTypesScreen(),
      ),
      GoRoute(path: '/settings/accounts', builder: (c, s) => const AccountsScreen()),
      GoRoute(path: '/settings/project-details', builder: (c, s) => const ProjectDetailsScreen()),
      GoRoute(path: '/settings/budget-rules', builder: (c, s) => const BudgetRulesScreen()),
      GoRoute(path: '/settings/carry-forward', builder: (c, s) => const CarryForwardScreen()),
      GoRoute(path: '/settings/transaction-types', builder: (c, s) => const TransactionTypesScreen()),
      GoRoute(path: '/settings/payment-methods', builder: (c, s) => const PaymentMethodsScreen()),
      GoRoute(path: '/settings/tags', builder: (c, s) => const TagsScreen()),
      GoRoute(path: '/settings/recurring-rules', builder: (c, s) => const RecurringRulesScreen()),
      GoRoute(path: '/settings/language', builder: (c, s) => const LanguageScreen()),
      GoRoute(path: '/settings/appearance', builder: (c, s) => const AppearanceScreen()),
      GoRoute(path: '/settings/notifications', builder: (c, s) => const NotificationsSettingsScreen()),
      GoRoute(path: '/settings/security', builder: (c, s) => const SecurityScreen()),
      GoRoute(path: '/settings/sync', builder: (c, s) => const SyncScreen()),
      GoRoute(
        path: '/settings/workspace-custom-fields',
        builder: (c, s) => const WorkspaceCustomFieldsScreen(),
      ),

      GoRoute(path: '/config/project-fields', builder: (c, s) => const ProjectFieldsScreen()),
      GoRoute(
        path: '/config/field-editor',
        builder: (c, s) => FieldEditorScreen(fieldId: s.uri.queryParameters['id'] ?? ''),
      ),
      GoRoute(path: '/config/field-templates', builder: (c, s) => const FieldTemplatesScreen()),
      GoRoute(
        path: '/config/custom-field-builder',
        builder: (c, s) => CustomFieldBuilderScreen(scope: s.uri.queryParameters['scope'] ?? 'project'),
      ),

      GoRoute(path: '/more', builder: (c, s) => const MoreHubScreen()),
      GoRoute(path: '/more/import-export', builder: (c, s) => const ImportExportScreen()),
      GoRoute(path: '/more/archive', builder: (c, s) => const ArchiveScreen()),
      GoRoute(path: '/more/help', builder: (c, s) => const HelpScreen()),
      GoRoute(path: '/notifications', builder: (c, s) => const NotificationsScreen()),
    ],
  );
});
