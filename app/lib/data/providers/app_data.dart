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

  List<Project> projectsInWorkspace(String workspaceId) {
    final ws = workspaces[workspaceId];
    if (ws == null) return [];
    return ws.projectIds.map((id) => projects[id]!).toList();
  }

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

  Category addCategory(String name, IconData icon) {
    final cat = Category(id: _uuid.v4(), name: name, icon: icon);
    categories[cat.id] = cat;
    notifyListeners();
    return cat;
  }

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
  }
}

final appDataProvider = ChangeNotifierProvider<AppData>((ref) => AppData());
