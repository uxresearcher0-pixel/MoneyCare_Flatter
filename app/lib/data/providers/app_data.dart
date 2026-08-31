import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../models/models.dart';

const _uuid = Uuid();

/// In-memory application data store. Seeded with sample data that mirrors
/// the Figma "Monthly Grocery" example so every screen renders realistic
/// content out of the box. Swap this for a real backend/repository layer
/// later without touching the UI.
class AppData extends ChangeNotifier {
  AppData() {
    _seed();
  }

  final AppUser currentUser = const AppUser(
    id: 'u1',
    name: 'Shanto',
    email: 'shanto@example.com',
  );

  final Map<String, Workspace> workspaces = {};
  final Map<String, Project> projects = {};
  final Map<String, Person> people = {};
  final Map<String, Period> periods = {};
  final Map<String, Category> categories = {};
  final Map<String, AppTransaction> transactions = {};
  final Map<String, Unit> units = {};
  final Map<String, PaymentMethod> paymentMethods = {};
  final Map<String, ContributionType> contributionTypes = {};
  final Map<String, TxKindConfig> txKindConfigs = {};
  final Map<String, FundAccount> accounts = {};
  final Map<String, CustomField> customFields = {};
  final Map<String, RecurringRule> recurringRules = {};

  String? activeWorkspaceId;
  String? activeProjectId;

  bool isAuthenticated = false;
  bool hasSeenOnboarding = false;

  Workspace? get activeWorkspace => workspaces[activeWorkspaceId];
  Project? get activeProject => projects[activeProjectId];
  Period? get activePeriod {
    final project = activeProject;
    if (project?.activePeriodId == null) return null;
    return periods[project!.activePeriodId];
  }

  List<Project> projectsInWorkspace(String workspaceId, {bool includeArchived = false}) {
    final ws = workspaces[workspaceId];
    if (ws == null) return [];
    final list = ws.projectIds.map((id) => projects[id]!);
    return (includeArchived ? list : list.where((p) => !p.isArchived)).toList();
  }

  List<Project> get archivedProjects => projects.values.where((p) => p.isArchived).toList();

  List<Person> peopleInProject(String projectId) {
    final project = projects[projectId];
    if (project == null) return [];
    return project.memberIds.map((id) => people[id]!).toList();
  }

  List<AppTransaction> transactionsInPeriod(String periodId) {
    final list = transactions.values.where((t) => t.periodId == periodId).toList();
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  List<AppTransaction> purchasesInPeriod(String periodId) => transactionsInPeriod(periodId)
      .where((t) => t.type == TransactionType.purchase)
      .toList();

  List<AppTransaction> contributionsInPeriod(String periodId) => transactionsInPeriod(
        periodId,
      ).where((t) => t.type == TransactionType.contribution).toList();

  num totalPurchases(String periodId) =>
      purchasesInPeriod(periodId).fold<num>(0, (sum, t) => sum + t.amount);

  num totalContributions(String periodId) =>
      contributionsInPeriod(periodId).fold<num>(0, (sum, t) => sum + t.amount);

  num availableBalance(String periodId) {
    final period = periods[periodId];
    if (period == null) return 0;
    return period.openingBalance + totalContributions(periodId) - totalPurchases(periodId);
  }

  Map<Category, num> spendingByCategory(String periodId) {
    final result = <Category, num>{};
    for (final t in purchasesInPeriod(periodId)) {
      final cat = categories[t.categoryId];
      if (cat == null) continue;
      result[cat] = (result[cat] ?? 0) + t.amount;
    }
    return result;
  }

  Map<Person, num> contributionsByPerson(String periodId) {
    final result = <Person, num>{};
    for (final t in contributionsInPeriod(periodId)) {
      final person = people[t.personId];
      if (person == null) continue;
      result[person] = (result[person] ?? 0) + t.amount;
    }
    return result;
  }

  // ---- Mutations -----------------------------------------------------

  void signIn() {
    isAuthenticated = true;
    notifyListeners();
  }

  void signOut() {
    isAuthenticated = false;
    notifyListeners();
  }

  void completeOnboarding() {
    hasSeenOnboarding = true;
    notifyListeners();
  }

  void setActiveWorkspace(String id) {
    activeWorkspaceId = id;
    final ws = workspaces[id];
    if (ws != null && ws.projectIds.isNotEmpty) {
      activeProjectId = ws.projectIds.first;
    } else {
      activeProjectId = null;
    }
    notifyListeners();
  }

  void setActivePeriod(String projectId, String periodId) {
    final project = projects[projectId];
    if (project == null) return;
    project.activePeriodId = periodId;
    activeProjectId = projectId;
    notifyListeners();
  }

  void setActiveProject(String id) {
    activeProjectId = id;
    notifyListeners();
  }

  Workspace createWorkspace(String name) {
    final ws = Workspace(id: _uuid.v4(), name: name, memberCount: 1);
    workspaces[ws.id] = ws;
    activeWorkspaceId = ws.id;
    notifyListeners();
    return ws;
  }

  Project createProject({
    required String workspaceId,
    required String name,
    String description = '',
    ProjectIconKind icon = ProjectIconKind.folder,
    List<String> memberIds = const [],
  }) {
    final project = Project(
      id: _uuid.v4(),
      workspaceId: workspaceId,
      name: name,
      description: description,
      icon: icon,
      memberIds: memberIds,
    );
    projects[project.id] = project;
    workspaces[workspaceId]?.projectIds.add(project.id);
    activeProjectId = project.id;
    notifyListeners();
    return project;
  }

  Period createPeriod({
    required String projectId,
    required String label,
    required DateTime start,
    required DateTime end,
    num openingBalance = 0,
    num monthlyBudget = 0,
    bool makeActive = true,
  }) {
    final period = Period(
      id: _uuid.v4(),
      projectId: projectId,
      label: label,
      startDate: start,
      endDate: end,
      openingBalance: openingBalance,
      monthlyBudget: monthlyBudget,
    );
    periods[period.id] = period;
    projects[projectId]?.periodIds.add(period.id);
    if (makeActive) {
      projects[projectId]?.activePeriodId = period.id;
    }
    notifyListeners();
    return period;
  }

  Person addPerson({
    required String projectId,
    required String name,
    String role = 'Member',
    String contributionType = 'Regular',
    num monthlyPledge = 0,
  }) {
    final person = Person(
      id: _uuid.v4(),
      name: name,
      role: role,
      contributionType: contributionType,
      monthlyPledge: monthlyPledge,
    );
    people[person.id] = person;
    projects[projectId]?.memberIds.add(person.id);
    notifyListeners();
    return person;
  }

  AppTransaction addPurchase({
    required String periodId,
    required String title,
    required num amount,
    required String categoryId,
    String? personId,
    DateTime? date,
    String note = '',
    String? unit,
    num? quantity,
  }) {
    final t = AppTransaction(
      id: _uuid.v4(),
      periodId: periodId,
      type: TransactionType.purchase,
      title: title,
      amount: amount,
      date: date ?? DateTime.now(),
      categoryId: categoryId,
      personId: personId,
      note: note,
      unit: unit,
      quantity: quantity,
    );
    transactions[t.id] = t;
    notifyListeners();
    return t;
  }

  AppTransaction addContribution({
    required String periodId,
    required String personId,
    required num amount,
    String contributionType = 'Regular',
    DateTime? date,
    String note = '',
  }) {
    final person = people[personId];
    final t = AppTransaction(
      id: _uuid.v4(),
      periodId: periodId,
      type: TransactionType.contribution,
      title: person?.name ?? 'Contribution',
      amount: amount,
      date: date ?? DateTime.now(),
      personId: personId,
      contributionType: contributionType,
    );
    transactions[t.id] = t;
    notifyListeners();
    return t;
  }

  void updatePerson(
    String id, {
    String? role,
    String? contributionType,
    num? monthlyPledge,
  }) {
    final person = people[id];
    if (person == null) return;
    if (role != null) person.role = role;
    if (contributionType != null) person.contributionType = contributionType;
    if (monthlyPledge != null) person.monthlyPledge = monthlyPledge;
    notifyListeners();
  }

  void deleteTransaction(String id) {
    transactions.remove(id);
    notifyListeners();
  }

  void updateTransaction(
    String id, {
    String? title,
    num? amount,
    String? categoryId,
    String? note,
  }) {
    final t = transactions[id];
    if (t == null) return;
    if (title != null) t.title = title;
    if (amount != null) t.amount = amount;
    if (categoryId != null) t.categoryId = categoryId;
    if (note != null) t.note = note;
    notifyListeners();
  }

  AppTransaction duplicateTransaction(String id) {
    final t = transactions[id]!;
    final copy = AppTransaction(
      id: _uuid.v4(),
      periodId: t.periodId,
      type: t.type,
      title: t.title,
      amount: t.amount,
      date: DateTime.now(),
      categoryId: t.categoryId,
      personId: t.personId,
      contributionType: t.contributionType,
      note: t.note,
      unit: t.unit,
      quantity: t.quantity,
    );
    transactions[copy.id] = copy;
    notifyListeners();
    return copy;
  }

  Category addCategory(String name, IconData icon) {
    final cat = Category(id: _uuid.v4(), name: name, icon: icon);
    categories[cat.id] = cat;
    notifyListeners();
    return cat;
  }

  void deleteCategory(String id) {
    categories.remove(id);
    notifyListeners();
  }

  void renameCategory(String id, String name) {
    final existing = categories[id];
    if (existing == null) return;
    categories[id] = Category(id: existing.id, name: name, icon: existing.icon, budget: existing.budget);
    notifyListeners();
  }

  Unit addUnit(String name, String abbr) {
    final unit = Unit(id: _uuid.v4(), name: name, abbr: abbr);
    units[unit.id] = unit;
    notifyListeners();
    return unit;
  }

  void deleteUnit(String id) {
    units.remove(id);
    notifyListeners();
  }

  PaymentMethod addPaymentMethod(String name, {IconData icon = Icons.payments_outlined}) {
    final method = PaymentMethod(id: _uuid.v4(), name: name, icon: icon);
    paymentMethods[method.id] = method;
    notifyListeners();
    return method;
  }

  void deletePaymentMethod(String id) {
    paymentMethods.remove(id);
    notifyListeners();
  }

  ContributionType addContributionType(String name, String description, {IconData icon = Icons.label_rounded}) {
    final type = ContributionType(id: _uuid.v4(), name: name, description: description, icon: icon);
    contributionTypes[type.id] = type;
    notifyListeners();
    return type;
  }

  void deleteContributionType(String id) {
    contributionTypes.remove(id);
    notifyListeners();
  }

  void renameContributionType(String id, String name, String description) {
    final existing = contributionTypes[id];
    if (existing == null) return;
    contributionTypes[id] = ContributionType(id: existing.id, name: name, description: description, icon: existing.icon);
    notifyListeners();
  }

  void setTxKindEnabled(String id, bool enabled) {
    final existing = txKindConfigs[id];
    if (existing == null) return;
    txKindConfigs[id] = TxKindConfig(
      id: existing.id,
      name: existing.name,
      description: existing.description,
      icon: existing.icon,
      enabled: enabled,
    );
    notifyListeners();
  }

  FundAccount addAccount(String name, {num balance = 0, IconData icon = Icons.account_balance_wallet_rounded}) {
    final account = FundAccount(id: _uuid.v4(), name: name, balance: balance, icon: icon);
    accounts[account.id] = account;
    notifyListeners();
    return account;
  }

  void deleteAccount(String id) {
    accounts.remove(id);
    notifyListeners();
  }

  CustomField addCustomField(
    String name,
    String type,
    CustomFieldScope scope, {
    String detail = '',
    bool required = false,
    List<String> options = const [],
  }) {
    final field = CustomField(
      id: _uuid.v4(),
      name: name,
      type: type,
      scope: scope,
      detail: detail,
      required: required,
      options: options,
    );
    customFields[field.id] = field;
    notifyListeners();
    return field;
  }

  void updateCustomField(String id, {String? name, String? type, bool? required}) {
    final existing = customFields[id];
    if (existing == null) return;
    customFields[id] = CustomField(
      id: existing.id,
      name: name ?? existing.name,
      type: type ?? existing.type,
      scope: existing.scope,
      detail: existing.detail,
      required: required ?? existing.required,
      options: existing.options,
    );
    notifyListeners();
  }

  void deleteCustomField(String id) {
    customFields.remove(id);
    notifyListeners();
  }

  RecurringRule addRecurringRule(String title, String schedule, num amount) {
    final rule = RecurringRule(id: _uuid.v4(), title: title, schedule: schedule, amount: amount);
    recurringRules[rule.id] = rule;
    notifyListeners();
    return rule;
  }

  void setRecurringRuleEnabled(String id, bool enabled) {
    final existing = recurringRules[id];
    if (existing == null) return;
    recurringRules[id] = RecurringRule(
      id: existing.id,
      title: existing.title,
      schedule: existing.schedule,
      amount: existing.amount,
      enabled: enabled,
    );
    notifyListeners();
  }

  void deleteRecurringRule(String id) {
    recurringRules.remove(id);
    notifyListeners();
  }

  void removePersonFromProject(String projectId, String personId) {
    projects[projectId]?.memberIds.remove(personId);
    notifyListeners();
  }

  void archiveProject(String id) {
    final project = projects[id];
    if (project == null) return;
    project.isArchived = true;
    if (activeProjectId == id) {
      final ws = workspaces[project.workspaceId];
      activeProjectId = ws?.projectIds.firstWhere(
        (pid) => pid != id && !(projects[pid]?.isArchived ?? false),
        orElse: () => '',
      );
      if (activeProjectId == '') activeProjectId = null;
    }
    notifyListeners();
  }

  void unarchiveProject(String id) {
    final project = projects[id];
    if (project == null) return;
    project.isArchived = false;
    notifyListeners();
  }

  void updatePeriodBudget(String periodId, num amount) {
    final period = periods[periodId];
    if (period == null) return;
    period.monthlyBudget = amount;
    notifyListeners();
  }

  void closePeriod(String periodId) {
    final period = periods[periodId];
    if (period == null) return;
    period.isActive = false;
    notifyListeners();
  }

  // ---- Preferences -----------------------------------------------------

  ThemeMode themeMode = ThemeMode.system;

  void setThemeMode(ThemeMode mode) {
    themeMode = mode;
    notifyListeners();
  }

  String currencyCode = 'BDT';
  String currencySymbol = '৳';
  String language = 'English';

  void setCurrency(String code, String symbol) {
    currencyCode = code;
    currencySymbol = symbol;
    notifyListeners();
  }

  void setLanguage(String value) {
    language = value;
    notifyListeners();
  }

  bool pushNotificationsEnabled = true;
  bool emailNotificationsEnabled = false;
  bool budgetAlertsEnabled = true;
  bool biometricLockEnabled = false;

  bool largerTextEnabled = false;
  bool highContrastEnabled = false;
  bool reduceMotionEnabled = false;

  void setAccessibility({bool? largerText, bool? highContrast, bool? reduceMotion}) {
    if (largerText != null) largerTextEnabled = largerText;
    if (highContrast != null) highContrastEnabled = highContrast;
    if (reduceMotion != null) reduceMotionEnabled = reduceMotion;
    notifyListeners();
  }

  void setPreference({
    bool? push,
    bool? email,
    bool? budgetAlerts,
    bool? biometricLock,
  }) {
    if (push != null) pushNotificationsEnabled = push;
    if (email != null) emailNotificationsEnabled = email;
    if (budgetAlerts != null) budgetAlertsEnabled = budgetAlerts;
    if (biometricLock != null) biometricLockEnabled = biometricLock;
    notifyListeners();
  }

  // ---- Notifications -----------------------------------------------------

  final List<AppNotification> notifications = [];

  void markNotificationRead(String id) {
    for (final n in notifications) {
      if (n.id == id) n.read = true;
    }
    notifyListeners();
  }

  void markAllNotificationsRead() {
    for (final n in notifications) {
      n.read = true;
    }
    notifyListeners();
  }

  int get unreadNotificationCount => notifications.where((n) => !n.read).length;

  // ---- Seed data -------------------------------------------------------

  void _seed() {
    categories.addAll({
      'fish': const Category(id: 'fish', name: 'Fish & meat', icon: Icons.set_meal_rounded),
      'rice': const Category(
        id: 'rice',
        name: 'Rice & lentils',
        icon: Icons.inventory_2_rounded,
      ),
      'utility': const Category(id: 'utility', name: 'Utility', icon: Icons.bolt_rounded),
      'household': const Category(
        id: 'household',
        name: 'Household',
        icon: Icons.home_rounded,
      ),
      'produce': const Category(
        id: 'produce',
        name: 'Vegetables & fruits',
        icon: Icons.eco_rounded,
      ),
      'transport': const Category(
        id: 'transport',
        name: 'Transport',
        icon: Icons.directions_car_rounded,
      ),
    });

    units.addAll({
      'kg': const Unit(id: 'kg', name: 'Kilogram', abbr: 'kg'),
      'l': const Unit(id: 'l', name: 'Litre', abbr: 'L'),
      'pcs': const Unit(id: 'pcs', name: 'Piece', abbr: 'pcs'),
      'g': const Unit(id: 'g', name: 'Gram', abbr: 'g'),
      'dz': const Unit(id: 'dz', name: 'Dozen', abbr: 'dz'),
      'pack': const Unit(id: 'pack', name: 'Pack', abbr: 'pack'),
    });

    paymentMethods.addAll({
      'cash': const PaymentMethod(id: 'cash', name: 'Cash', icon: Icons.payments_outlined),
      'bank': const PaymentMethod(id: 'bank', name: 'Bank transfer', icon: Icons.account_balance_outlined),
      'mobile': const PaymentMethod(
        id: 'mobile',
        name: 'Mobile banking (bKash/Nagad)',
        icon: Icons.smartphone_outlined,
      ),
      'card': const PaymentMethod(id: 'card', name: 'Card', icon: Icons.credit_card_outlined),
    });

    contributionTypes.addAll({
      'regular': const ContributionType(
        id: 'regular',
        name: 'Regular',
        description: 'Recurring monthly share',
        icon: Icons.repeat_rounded,
      ),
      'extra': const ContributionType(
        id: 'extra',
        name: 'Extra',
        description: 'One-off additional amount',
        icon: Icons.add_circle_outline_rounded,
      ),
      'occasion': const ContributionType(
        id: 'occasion',
        name: 'Occasion',
        description: 'Gifts, festivals, special events',
        icon: Icons.celebration_rounded,
      ),
    });

    txKindConfigs.addAll({
      'purchase': const TxKindConfig(
        id: 'purchase',
        name: 'Purchase',
        description: 'Money spent from a project fund',
        icon: Icons.shopping_cart_rounded,
        enabled: true,
      ),
      'contribution': const TxKindConfig(
        id: 'contribution',
        name: 'Contribution',
        description: 'Money paid in by a contributor',
        icon: Icons.arrow_downward_rounded,
        enabled: true,
      ),
      'transfer': const TxKindConfig(
        id: 'transfer',
        name: 'Transfer',
        description: 'Move funds between accounts or wallets',
        icon: Icons.swap_horiz_rounded,
        enabled: true,
      ),
      'refund': const TxKindConfig(
        id: 'refund',
        name: 'Refund',
        description: 'Money returned for a prior purchase',
        icon: Icons.replay_rounded,
        enabled: false,
      ),
    });

    accounts.addAll({
      'grocery': const FundAccount(
        id: 'grocery',
        name: 'Grocery Fund',
        balance: 18640,
        icon: Icons.account_balance_wallet_rounded,
      ),
      'rent': const FundAccount(id: 'rent', name: 'House Rent', balance: 42000, icon: Icons.home_rounded),
      'savings': const FundAccount(
        id: 'savings',
        name: 'Emergency Savings',
        balance: 96500,
        icon: Icons.savings_rounded,
      ),
    });

    customFields.addAll({
      'household-id': const CustomField(
        id: 'household-id',
        name: 'Household ID',
        type: 'Text',
        scope: CustomFieldScope.workspace,
        detail: 'Shared reference across all projects',
      ),
      'default-currency': const CustomField(
        id: 'default-currency',
        name: 'Default Currency',
        type: 'Dropdown',
        scope: CustomFieldScope.workspace,
        detail: '৳ BDT for every new project',
        options: ['BDT'],
      ),
      'fiscal-year-start': const CustomField(
        id: 'fiscal-year-start',
        name: 'Fiscal Year Start',
        type: 'Date',
        scope: CustomFieldScope.workspace,
        detail: 'Used for yearly reports',
      ),
      'grocery-fund': const CustomField(
        id: 'grocery-fund',
        name: 'Grocery Fund',
        type: 'Wallet',
        scope: CustomFieldScope.project,
        detail: 'Default payment source',
      ),
      'monthly-budget-cap': const CustomField(
        id: 'monthly-budget-cap',
        name: 'Monthly Budget Cap',
        type: 'Calculated Total',
        scope: CustomFieldScope.project,
        detail: 'Sum of category budgets',
      ),
      'receipt-required': const CustomField(
        id: 'receipt-required',
        name: 'Receipt Required',
        type: 'Toggle',
        scope: CustomFieldScope.project,
        detail: 'Off by default',
      ),
      'preferred-unit': const CustomField(
        id: 'preferred-unit',
        name: 'Preferred Unit',
        type: 'Dropdown',
        scope: CustomFieldScope.project,
        detail: 'kg, L, pcs',
        options: ['kg', 'L', 'pcs'],
      ),
    });

    recurringRules.addAll({
      'r1': const RecurringRule(id: 'r1', title: 'Abbu — Regular contribution', schedule: 'Monthly on the 1st', amount: 14200),
      'r2': const RecurringRule(id: 'r2', title: 'Electricity bill', schedule: 'Monthly on the 5th', amount: 1000),
      'r3': const RecurringRule(id: 'r3', title: 'House rent contribution', schedule: 'Monthly on the 1st', amount: 9440, enabled: false),
    });

    people.addAll({
      'p1': Person(id: 'p1', name: 'Shanto', role: 'Owner', isOwner: true, monthlyPledge: 4000),
      'p2': Person(id: 'p2', name: 'Abbu', role: 'Contributor', monthlyPledge: 18000),
      'p3': Person(id: 'p3', name: 'Bhaiya', role: 'Contributor', monthlyPledge: 4000),
      'p4': Person(
        id: 'p4',
        name: 'Amma',
        role: 'Contributor',
        contributionType: 'Occasion',
        monthlyPledge: 3500,
      ),
    });

    final workspace = Workspace(id: 'w1', name: "Shanto's Family", memberCount: 4);
    workspaces[workspace.id] = workspace;
    activeWorkspaceId = workspace.id;

    final project = Project(
      id: 'proj1',
      workspaceId: workspace.id,
      name: 'Monthly Grocery',
      description: 'Shared household grocery budget',
      icon: ProjectIconKind.cart,
      memberIds: ['p1', 'p2', 'p3', 'p4'],
    );
    projects[project.id] = project;
    workspace.projectIds.add(project.id);
    activeProjectId = project.id;

    final period = Period(
      id: 'period1',
      projectId: project.id,
      label: 'August 2026',
      startDate: DateTime(2026, 8, 1),
      endDate: DateTime(2026, 8, 31),
      openingBalance: 1642,
      monthlyBudget: 35000,
    );
    periods[period.id] = period;
    project.periodIds.add(period.id);
    project.activePeriodId = period.id;

    final now = DateTime(2026, 8, 30);
    void purchase(
      String title,
      num amount,
      String category,
      String person,
      DateTime date,
    ) {
      final t = AppTransaction(
        id: _uuid.v4(),
        periodId: period.id,
        type: TransactionType.purchase,
        title: title,
        amount: amount,
        date: date,
        categoryId: category,
        personId: person,
      );
      transactions[t.id] = t;
    }

    void contribution(
      String person,
      num amount,
      String type,
      DateTime date,
    ) {
      final t = AppTransaction(
        id: _uuid.v4(),
        periodId: period.id,
        type: TransactionType.contribution,
        title: people[person]!.name,
        amount: amount,
        date: date,
        personId: person,
        contributionType: type,
      );
      transactions[t.id] = t;
    }

    purchase('Fish', 1250, 'fish', 'p1', now);
    purchase('Electricity bill', 1000, 'utility', 'p1', now.subtract(const Duration(days: 1)));
    purchase('Rice', 2200, 'rice', 'p1', DateTime(2026, 8, 2));
    purchase('Vegetables', 850, 'produce', 'p1', DateTime(2026, 8, 3));
    purchase('Meat', 4000, 'fish', 'p2', DateTime(2026, 8, 5));
    purchase('Lentils & spices', 750, 'rice', 'p1', DateTime(2026, 8, 8));
    purchase('Household supplies', 1900, 'household', 'p3', DateTime(2026, 8, 10));
    purchase('Gas bill', 900, 'utility', 'p1', DateTime(2026, 8, 12));
    purchase('Fish', 1900, 'fish', 'p2', DateTime(2026, 8, 18));
    purchase('Cooking oil', 1873, 'rice', 'p3', DateTime(2026, 8, 20));

    contribution('p2', 4000, 'Regular', now);
    contribution('p2', 14200, 'Regular', DateTime(2026, 8, 1));
    contribution('p2', 2470, 'Extra', DateTime(2026, 8, 1));
    contribution('p3', 4011, 'Regular', DateTime(2026, 8, 1));
    contribution('p4', 3500, 'Occasion', DateTime(2026, 8, 1));
    contribution('p1', 5440, 'Regular', DateTime(2026, 8, 1));

    notifications.addAll([
      AppNotification(
        id: _uuid.v4(),
        title: 'Budget 70% used — Utility',
        body: 'Utility category has used 70% of its ৳4,000 budget this period.',
        time: now,
        icon: Icons.bolt_rounded,
      ),
      AppNotification(
        id: _uuid.v4(),
        title: 'Abbu added a contribution',
        body: '৳4,000 regular contribution logged for Monthly Grocery.',
        time: now.subtract(const Duration(hours: 3)),
        icon: Icons.arrow_downward_rounded,
      ),
      AppNotification(
        id: _uuid.v4(),
        title: 'Weekly summary is ready',
        body: 'Spending is 12% lower than last week — view the full report.',
        time: now.subtract(const Duration(days: 1)),
        icon: Icons.bar_chart_rounded,
        read: true,
      ),
    ]);
  }
}

final appDataProvider = ChangeNotifierProvider<AppData>((ref) => AppData());
