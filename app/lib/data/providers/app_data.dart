import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../models/models.dart';

const _uuid = Uuid();

/// Set from main.dart before runApp(), once Firebase.initializeApp() has
/// been attempted. True only when a Firebase app actually initialized for
/// this platform (Android today — see firebase_options.dart). AppData reads
/// this once, at construction, to choose between:
///  - real Firebase Auth + Firestore-backed sync: accounts, nothing is lost
///    when the app closes, and a household's members see each other's
///    changes live, or
///  - the original local-only in-memory demo mode, used wherever there's no
///    registered Firebase app yet (web/desktop).
bool firebaseEnabled = false;

Map<String, T> _decodeMap<T>(dynamic raw, T Function(Map<String, dynamic>) fromMap) {
  final result = <String, T>{};
  if (raw is Map) {
    raw.forEach((key, value) {
      if (value is Map) {
        result[key.toString()] = fromMap(Map<String, dynamic>.from(value));
      }
    });
  }
  return result;
}

List<String> _stringList(dynamic value) =>
    (value as List?)?.map((e) => e.toString()).toList() ?? <String>[];

String _generateInviteCode() {
  const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'; // no 0/O/1/I — easy to read aloud
  final rand = Random.secure();
  return List.generate(6, (_) => chars[rand.nextInt(chars.length)]).join();
}

/// Application data store. Two backends behind one API so every screen in
/// the app can call the same methods either way:
///  - Firebase mode (`firebaseEnabled`): real Firebase Auth + a Firestore
///    document per household that every member's device listens to in
///    real time. Every mutator below applies the change locally *and*
///    pushes it to Firestore; the Firestore listener then re-applies the
///    authoritative state (own writes included) so collaborators' changes
///    show up live without a manual refresh.
///  - Local demo mode (web/desktop, no Firebase project registered yet):
///    exactly the original in-memory behaviour, seeded with sample data.
class AppData extends ChangeNotifier {
  AppData() {
    if (firebaseEnabled) {
      _authSub = fb_auth.FirebaseAuth.instance.authStateChanges().listen(_onAuthChanged);
    } else {
      _seedLocalDemo();
    }
  }

  AppUser currentUser = const AppUser(id: '', name: '', email: '');

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

  // ---- Firebase-backed sync state --------------------------------------

  StreamSubscription<fb_auth.User?>? _authSub;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _userDocSub;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _householdSub;
  fb_auth.User? _fbUser;
  String? _householdId;
  String? _savedActiveWorkspaceId;
  String? _savedActiveProjectId;

  /// Household display name (Firebase mode only).
  String householdName = '';

  /// Members of the currently-loaded household (Firebase mode only).
  List<String> householdMemberIds = [];

  /// Shareable 6-character code other users enter to join this household.
  String householdInviteCode = '';

  bool get isFirebaseBacked => firebaseEnabled;

  @override
  void dispose() {
    _authSub?.cancel();
    _userDocSub?.cancel();
    _householdSub?.cancel();
    super.dispose();
  }

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
      purchasesInPeriod(periodId).fold<num>(0, (total, t) => total + t.amount);

  num totalContributions(String periodId) =>
      contributionsInPeriod(periodId).fold<num>(0, (total, t) => total + t.amount);

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

  // ---- Auth (Firebase mode) ---------------------------------------------

  Future<void> signUpWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    final cred = await fb_auth.FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    await cred.user?.updateDisplayName(name.trim());
  }

  Future<void> signInWithEmail({required String email, required String password}) {
    return fb_auth.FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<void> sendPasswordReset(String email) {
    return fb_auth.FirebaseAuth.instance.sendPasswordResetEmail(email: email.trim());
  }

  /// Demo-mode-only fake sign-in — used on platforms with no Firebase
  /// project registered yet (see firebaseEnabled). Real builds call
  /// signInWithEmail/signUpWithEmail instead.
  void signIn() {
    if (firebaseEnabled) return;
    isAuthenticated = true;
    notifyListeners();
  }

  void signOut() {
    if (firebaseEnabled) {
      unawaited(fb_auth.FirebaseAuth.instance.signOut());
      return;
    }
    isAuthenticated = false;
    notifyListeners();
  }

  Future<void> _onAuthChanged(fb_auth.User? user) async {
    await _userDocSub?.cancel();
    await _householdSub?.cancel();
    _userDocSub = null;
    _householdSub = null;

    if (user == null) {
      _fbUser = null;
      _householdId = null;
      _savedActiveWorkspaceId = null;
      _savedActiveProjectId = null;
      isAuthenticated = false;
      _clearAllData();
      notifyListeners();
      return;
    }

    _fbUser = user;
    final displayName = user.displayName?.trim();
    currentUser = AppUser(
      id: user.uid,
      name: (displayName != null && displayName.isNotEmpty)
          ? displayName
          : (user.email?.split('@').first ?? 'You'),
      email: user.email ?? '',
    );
    isAuthenticated = true;
    notifyListeners();

    final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
    _userDocSub = userRef.snapshots().listen((snap) => _onUserDocChanged(snap, userRef));
  }

  Future<void> _onUserDocChanged(
    DocumentSnapshot<Map<String, dynamic>> snap,
    DocumentReference<Map<String, dynamic>> ref,
  ) async {
    final data = snap.data();
    if (data == null) {
      // First sign-in ever for this account: stand up a brand-new household
      // and the user's profile doc together. Wrapped defensively — this
      // runs inside a stream callback, so an unhandled failure here (e.g. a
      // transient network drop, or Firestore rules not published yet)
      // would otherwise surface as an unhandled Future rejection rather
      // than something the UI can react to. The listener fires again next
      // time the doc changes, so a retry naturally happens on next launch.
      try {
        final householdId = await _createHousehold(
          ownerId: _fbUser!.uid,
          ownerName: currentUser.name,
        );
        await ref.set({
          'name': currentUser.name,
          'email': currentUser.email,
          'householdId': householdId,
          'hasSeenOnboarding': false,
          'themeMode': ThemeMode.system.name,
          'language': 'English',
          'pushNotificationsEnabled': true,
          'emailNotificationsEnabled': false,
          'budgetAlertsEnabled': true,
          'biometricLockEnabled': false,
          'largerTextEnabled': false,
          'highContrastEnabled': false,
          'reduceMotionEnabled': false,
          'notifications': [],
        });
      } catch (e) {
        debugPrint('Money Care: failed to create household for new user: $e');
      }
      return; // A successful set() above re-triggers this listener with real data.
    }

    hasSeenOnboarding = data['hasSeenOnboarding'] as bool? ?? false;
    themeMode = ThemeMode.values.firstWhere(
      (m) => m.name == data['themeMode'],
      orElse: () => ThemeMode.system,
    );
    language = data['language'] as String? ?? 'English';
    pushNotificationsEnabled = data['pushNotificationsEnabled'] as bool? ?? true;
    emailNotificationsEnabled = data['emailNotificationsEnabled'] as bool? ?? false;
    budgetAlertsEnabled = data['budgetAlertsEnabled'] as bool? ?? true;
    biometricLockEnabled = data['biometricLockEnabled'] as bool? ?? false;
    largerTextEnabled = data['largerTextEnabled'] as bool? ?? false;
    highContrastEnabled = data['highContrastEnabled'] as bool? ?? false;
    reduceMotionEnabled = data['reduceMotionEnabled'] as bool? ?? false;
    notifications
      ..clear()
      ..addAll(
        ((data['notifications'] as List?) ?? [])
            .whereType<Map>()
            .map((m) => AppNotification.fromMap(Map<String, dynamic>.from(m))),
      );
    _savedActiveWorkspaceId = data['activeWorkspaceId'] as String?;
    _savedActiveProjectId = data['activeProjectId'] as String?;

    final householdId = data['householdId'] as String?;
    if (householdId != _householdId) {
      _householdId = householdId;
      await _householdSub?.cancel();
      _householdSub = null;
      if (householdId != null) {
        _householdSub = FirebaseFirestore.instance
            .collection('households')
            .doc(householdId)
            .snapshots()
            .listen(_onHouseholdChanged);
      }
    }
    notifyListeners();
  }

  void _onHouseholdChanged(DocumentSnapshot<Map<String, dynamic>> snap) {
    final data = snap.data();
    if (data == null) return;

    householdName = data['name'] as String? ?? 'Household';
    householdMemberIds = _stringList(data['memberIds']);
    householdInviteCode = data['inviteCode'] as String? ?? '';
    currencyCode = data['currencyCode'] as String? ?? 'BDT';
    currencySymbol = data['currencySymbol'] as String? ?? '৳';

    workspaces
      ..clear()
      ..addAll(_decodeMap(data['workspaces'], Workspace.fromMap));
    for (final ws in workspaces.values) {
      ws.memberCount = householdMemberIds.isEmpty ? 1 : householdMemberIds.length;
    }
    projects
      ..clear()
      ..addAll(_decodeMap(data['projects'], Project.fromMap));
    people
      ..clear()
      ..addAll(_decodeMap(data['people'], Person.fromMap));
    periods
      ..clear()
      ..addAll(_decodeMap(data['periods'], Period.fromMap));
    categories
      ..clear()
      ..addAll(_decodeMap(data['categories'], Category.fromMap));
    transactions
      ..clear()
      ..addAll(_decodeMap(data['transactions'], AppTransaction.fromMap));
    units
      ..clear()
      ..addAll(_decodeMap(data['units'], Unit.fromMap));
    paymentMethods
      ..clear()
      ..addAll(_decodeMap(data['paymentMethods'], PaymentMethod.fromMap));
    contributionTypes
      ..clear()
      ..addAll(_decodeMap(data['contributionTypes'], ContributionType.fromMap));
    txKindConfigs
      ..clear()
      ..addAll(_decodeMap(data['txKindConfigs'], TxKindConfig.fromMap));
    accounts
      ..clear()
      ..addAll(_decodeMap(data['accounts'], FundAccount.fromMap));
    customFields
      ..clear()
      ..addAll(_decodeMap(data['customFields'], CustomField.fromMap));
    recurringRules
      ..clear()
      ..addAll(_decodeMap(data['recurringRules'], RecurringRule.fromMap));

    if (activeWorkspaceId == null &&
        _savedActiveWorkspaceId != null &&
        workspaces.containsKey(_savedActiveWorkspaceId)) {
      activeWorkspaceId = _savedActiveWorkspaceId;
    }
    if (activeWorkspaceId == null || !workspaces.containsKey(activeWorkspaceId)) {
      activeWorkspaceId = workspaces.keys.isNotEmpty ? workspaces.keys.first : null;
    }
    if (activeProjectId == null &&
        _savedActiveProjectId != null &&
        projects.containsKey(_savedActiveProjectId)) {
      activeProjectId = _savedActiveProjectId;
    }
    if (activeProjectId == null || !projects.containsKey(activeProjectId)) {
      final ws = workspaces[activeWorkspaceId];
      activeProjectId = (ws != null && ws.projectIds.isNotEmpty) ? ws.projectIds.first : null;
    }

    notifyListeners();
  }

  void _clearAllData() {
    workspaces.clear();
    projects.clear();
    people.clear();
    periods.clear();
    categories.clear();
    transactions.clear();
    units.clear();
    paymentMethods.clear();
    contributionTypes.clear();
    txKindConfigs.clear();
    accounts.clear();
    customFields.clear();
    recurringRules.clear();
    notifications.clear();
    activeWorkspaceId = null;
    activeProjectId = null;
    householdName = '';
    householdMemberIds = [];
    householdInviteCode = '';
    currentUser = const AppUser(id: '', name: '', email: '');
    hasSeenOnboarding = false;
  }

  /// Creates a new household doc (with sensible starter reference lists —
  /// categories, units, payment methods… — but no fake people or
  /// transactions) plus one starter workspace/project/period so the rest of
  /// the app always has somewhere to point at. Returns the new household id.
  Future<String> _createHousehold({required String ownerId, required String ownerName}) async {
    final householdRef = FirebaseFirestore.instance.collection('households').doc();
    final code = _generateInviteCode();

    final wsId = _uuid.v4();
    final projectId = _uuid.v4();
    final periodId = _uuid.v4();
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final monthEnd = DateTime(now.year, now.month + 1, 0);
    const monthNames = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];

    final workspace = Workspace(
      id: wsId,
      name: "$ownerName's Household",
      memberCount: 1,
      projectIds: [projectId],
    );
    final project = Project(
      id: projectId,
      workspaceId: wsId,
      name: 'General',
      description: 'Shared household budget',
      icon: ProjectIconKind.wallet,
      periodIds: [periodId],
      activePeriodId: periodId,
    );
    final period = Period(
      id: periodId,
      projectId: projectId,
      label: '${monthNames[now.month - 1]} ${now.year}',
      startDate: monthStart,
      endDate: monthEnd,
    );

    await householdRef.set({
      'name': "$ownerName's Household",
      'ownerId': ownerId,
      'memberIds': [ownerId],
      'inviteCode': code,
      'createdAt': FieldValue.serverTimestamp(),
      'currencyCode': 'BDT',
      'currencySymbol': '৳',
      'workspaces': {wsId: workspace.toMap()},
      'projects': {projectId: project.toMap()},
      'people': <String, dynamic>{},
      'periods': {periodId: period.toMap()},
      'transactions': <String, dynamic>{},
      'categories': _defaultCategories(),
      'units': _defaultUnits(),
      'paymentMethods': _defaultPaymentMethods(),
      'contributionTypes': _defaultContributionTypes(),
      'txKindConfigs': _defaultTxKindConfigs(),
      'accounts': <String, dynamic>{},
      'customFields': <String, dynamic>{},
      'recurringRules': <String, dynamic>{},
    });
    await FirebaseFirestore.instance
        .collection('invites')
        .doc(code)
        .set({'householdId': householdRef.id});
    return householdRef.id;
  }

  /// Joins the household behind a 6-character invite code shared by an
  /// existing member (see the Household screen). Throws if the code is
  /// unknown.
  Future<void> joinHouseholdByCode(String rawCode) async {
    final code = rawCode.trim().toUpperCase();
    final invite = await FirebaseFirestore.instance.collection('invites').doc(code).get();
    if (!invite.exists) {
      throw Exception('No household found for that invite code.');
    }
    final householdId = invite.data()!['householdId'] as String;
    final uid = _fbUser!.uid;
    await FirebaseFirestore.instance.collection('households').doc(householdId).update({
      'memberIds': FieldValue.arrayUnion([uid]),
    });
    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'householdId': householdId,
    });
  }

  // ---- Firestore write-through helpers -----------------------------------

  Future<void> _put(String collection, String id, Map<String, dynamic> map) async {
    if (!firebaseEnabled || _householdId == null) return;
    try {
      await FirebaseFirestore.instance
          .collection('households')
          .doc(_householdId)
          .update({'$collection.$id': map});
    } catch (_) {
      // Offline: Firestore's local cache queues the write and retries once
      // connectivity returns.
    }
  }

  Future<void> _remove(String collection, String id) async {
    if (!firebaseEnabled || _householdId == null) return;
    try {
      await FirebaseFirestore.instance
          .collection('households')
          .doc(_householdId)
          .update({'$collection.$id': FieldValue.delete()});
    } catch (_) {}
  }

  Future<void> _syncHousehold(Map<String, dynamic> patch) async {
    if (!firebaseEnabled || _householdId == null) return;
    try {
      await FirebaseFirestore.instance.collection('households').doc(_householdId).update(patch);
    } catch (_) {}
  }

  Future<void> _syncUserPrefs(Map<String, dynamic> patch) async {
    if (!firebaseEnabled || _fbUser == null) return;
    try {
      await FirebaseFirestore.instance.collection('users').doc(_fbUser!.uid).update(patch);
    } catch (_) {}
  }

  // ---- Mutations -----------------------------------------------------

  void completeOnboarding() {
    hasSeenOnboarding = true;
    notifyListeners();
    unawaited(_syncUserPrefs({'hasSeenOnboarding': true}));
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
    unawaited(_syncUserPrefs({'activeWorkspaceId': id, 'activeProjectId': activeProjectId}));
  }

  void setActivePeriod(String projectId, String periodId) {
    final project = projects[projectId];
    if (project == null) return;
    project.activePeriodId = periodId;
    activeProjectId = projectId;
    notifyListeners();
    unawaited(_put('projects', project.id, project.toMap()));
    unawaited(_syncUserPrefs({'activeProjectId': projectId}));
  }

  void setActiveProject(String id) {
    activeProjectId = id;
    notifyListeners();
    unawaited(_syncUserPrefs({'activeProjectId': id}));
  }

  Workspace createWorkspace(String name) {
    final memberCount = householdMemberIds.isEmpty ? 1 : householdMemberIds.length;
    final ws = Workspace(id: _uuid.v4(), name: name, memberCount: memberCount);
    workspaces[ws.id] = ws;
    activeWorkspaceId = ws.id;
    notifyListeners();
    unawaited(_put('workspaces', ws.id, ws.toMap()));
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
    unawaited(_put('projects', project.id, project.toMap()));
    final ws = workspaces[workspaceId];
    if (ws != null) unawaited(_put('workspaces', ws.id, ws.toMap()));
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
    unawaited(_put('periods', period.id, period.toMap()));
    final project = projects[projectId];
    if (project != null) unawaited(_put('projects', project.id, project.toMap()));
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
    unawaited(_put('people', person.id, person.toMap()));
    final project = projects[projectId];
    if (project != null) unawaited(_put('projects', project.id, project.toMap()));
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
    unawaited(_put('transactions', t.id, t.toMap()));
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
    unawaited(_put('transactions', t.id, t.toMap()));
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
    unawaited(_put('people', person.id, person.toMap()));
  }

  void deleteTransaction(String id) {
    transactions.remove(id);
    notifyListeners();
    unawaited(_remove('transactions', id));
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
    unawaited(_put('transactions', t.id, t.toMap()));
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
    unawaited(_put('transactions', copy.id, copy.toMap()));
    return copy;
  }

  Category addCategory(String name, IconData icon) {
    final cat = Category(id: _uuid.v4(), name: name, icon: icon);
    categories[cat.id] = cat;
    notifyListeners();
    unawaited(_put('categories', cat.id, cat.toMap()));
    return cat;
  }

  void deleteCategory(String id) {
    categories.remove(id);
    notifyListeners();
    unawaited(_remove('categories', id));
  }

  void renameCategory(String id, String name) {
    final existing = categories[id];
    if (existing == null) return;
    final updated = Category(id: existing.id, name: name, icon: existing.icon, budget: existing.budget);
    categories[id] = updated;
    notifyListeners();
    unawaited(_put('categories', updated.id, updated.toMap()));
  }

  Unit addUnit(String name, String abbr) {
    final unit = Unit(id: _uuid.v4(), name: name, abbr: abbr);
    units[unit.id] = unit;
    notifyListeners();
    unawaited(_put('units', unit.id, unit.toMap()));
    return unit;
  }

  void deleteUnit(String id) {
    units.remove(id);
    notifyListeners();
    unawaited(_remove('units', id));
  }

  PaymentMethod addPaymentMethod(String name, {IconData icon = Icons.payments_outlined}) {
    final method = PaymentMethod(id: _uuid.v4(), name: name, icon: icon);
    paymentMethods[method.id] = method;
    notifyListeners();
    unawaited(_put('paymentMethods', method.id, method.toMap()));
    return method;
  }

  void deletePaymentMethod(String id) {
    paymentMethods.remove(id);
    notifyListeners();
    unawaited(_remove('paymentMethods', id));
  }

  ContributionType addContributionType(String name, String description, {IconData icon = Icons.label_rounded}) {
    final type = ContributionType(id: _uuid.v4(), name: name, description: description, icon: icon);
    contributionTypes[type.id] = type;
    notifyListeners();
    unawaited(_put('contributionTypes', type.id, type.toMap()));
    return type;
  }

  void deleteContributionType(String id) {
    contributionTypes.remove(id);
    notifyListeners();
    unawaited(_remove('contributionTypes', id));
  }

  void renameContributionType(String id, String name, String description) {
    final existing = contributionTypes[id];
    if (existing == null) return;
    final updated = ContributionType(id: existing.id, name: name, description: description, icon: existing.icon);
    contributionTypes[id] = updated;
    notifyListeners();
    unawaited(_put('contributionTypes', updated.id, updated.toMap()));
  }

  void setTxKindEnabled(String id, bool enabled) {
    final existing = txKindConfigs[id];
    if (existing == null) return;
    final updated = TxKindConfig(
      id: existing.id,
      name: existing.name,
      description: existing.description,
      icon: existing.icon,
      enabled: enabled,
    );
    txKindConfigs[id] = updated;
    notifyListeners();
    unawaited(_put('txKindConfigs', updated.id, updated.toMap()));
  }

  FundAccount addAccount(String name, {num balance = 0, IconData icon = Icons.account_balance_wallet_rounded}) {
    final account = FundAccount(id: _uuid.v4(), name: name, balance: balance, icon: icon);
    accounts[account.id] = account;
    notifyListeners();
    unawaited(_put('accounts', account.id, account.toMap()));
    return account;
  }

  void deleteAccount(String id) {
    accounts.remove(id);
    notifyListeners();
    unawaited(_remove('accounts', id));
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
    unawaited(_put('customFields', field.id, field.toMap()));
    return field;
  }

  void updateCustomField(String id, {String? name, String? type, bool? required}) {
    final existing = customFields[id];
    if (existing == null) return;
    final updated = CustomField(
      id: existing.id,
      name: name ?? existing.name,
      type: type ?? existing.type,
      scope: existing.scope,
      detail: existing.detail,
      required: required ?? existing.required,
      options: existing.options,
    );
    customFields[id] = updated;
    notifyListeners();
    unawaited(_put('customFields', updated.id, updated.toMap()));
  }

  void deleteCustomField(String id) {
    customFields.remove(id);
    notifyListeners();
    unawaited(_remove('customFields', id));
  }

  RecurringRule addRecurringRule(String title, String schedule, num amount) {
    final rule = RecurringRule(id: _uuid.v4(), title: title, schedule: schedule, amount: amount);
    recurringRules[rule.id] = rule;
    notifyListeners();
    unawaited(_put('recurringRules', rule.id, rule.toMap()));
    return rule;
  }

  void setRecurringRuleEnabled(String id, bool enabled) {
    final existing = recurringRules[id];
    if (existing == null) return;
    final updated = RecurringRule(
      id: existing.id,
      title: existing.title,
      schedule: existing.schedule,
      amount: existing.amount,
      enabled: enabled,
    );
    recurringRules[id] = updated;
    notifyListeners();
    unawaited(_put('recurringRules', updated.id, updated.toMap()));
  }

  void deleteRecurringRule(String id) {
    recurringRules.remove(id);
    notifyListeners();
    unawaited(_remove('recurringRules', id));
  }

  void removePersonFromProject(String projectId, String personId) {
    projects[projectId]?.memberIds.remove(personId);
    notifyListeners();
    final project = projects[projectId];
    if (project != null) unawaited(_put('projects', project.id, project.toMap()));
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
    unawaited(_put('projects', project.id, project.toMap()));
  }

  void unarchiveProject(String id) {
    final project = projects[id];
    if (project == null) return;
    project.isArchived = false;
    notifyListeners();
    unawaited(_put('projects', project.id, project.toMap()));
  }

  void updatePeriodBudget(String periodId, num amount) {
    final period = periods[periodId];
    if (period == null) return;
    period.monthlyBudget = amount;
    notifyListeners();
    unawaited(_put('periods', period.id, period.toMap()));
  }

  void closePeriod(String periodId) {
    final period = periods[periodId];
    if (period == null) return;
    period.isActive = false;
    notifyListeners();
    unawaited(_put('periods', period.id, period.toMap()));
  }

  // ---- Preferences -----------------------------------------------------

  ThemeMode themeMode = ThemeMode.system;

  void setThemeMode(ThemeMode mode) {
    themeMode = mode;
    notifyListeners();
    unawaited(_syncUserPrefs({'themeMode': mode.name}));
  }

  // Currency is shared across the whole household (it's the ledger's unit
  // of account, not a personal display preference) — synced onto the
  // household doc itself rather than per-user.
  String currencyCode = 'BDT';
  String currencySymbol = '৳';
  String language = 'English';

  void setCurrency(String code, String symbol) {
    currencyCode = code;
    currencySymbol = symbol;
    notifyListeners();
    unawaited(_syncHousehold({'currencyCode': code, 'currencySymbol': symbol}));
  }

  void setLanguage(String value) {
    language = value;
    notifyListeners();
    unawaited(_syncUserPrefs({'language': value}));
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
    unawaited(_syncUserPrefs({
      'largerTextEnabled': largerTextEnabled,
      'highContrastEnabled': highContrastEnabled,
      'reduceMotionEnabled': reduceMotionEnabled,
    }));
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
    unawaited(_syncUserPrefs({
      'pushNotificationsEnabled': pushNotificationsEnabled,
      'emailNotificationsEnabled': emailNotificationsEnabled,
      'budgetAlertsEnabled': budgetAlertsEnabled,
      'biometricLockEnabled': biometricLockEnabled,
    }));
  }

  // ---- Notifications -----------------------------------------------------

  final List<AppNotification> notifications = [];

  void markNotificationRead(String id) {
    for (final n in notifications) {
      if (n.id == id) n.read = true;
    }
    notifyListeners();
    _syncNotifications();
  }

  void markAllNotificationsRead() {
    for (final n in notifications) {
      n.read = true;
    }
    notifyListeners();
    _syncNotifications();
  }

  void _syncNotifications() {
    unawaited(_syncUserPrefs({'notifications': notifications.map((n) => n.toMap()).toList()}));
  }

  int get unreadNotificationCount => notifications.where((n) => !n.read).length;

  // ---- Default reference lists (Firebase mode: new household seed) -------
  // These are genuinely reusable starting options (like a to-do app's
  // default lists) — not the fake people/transactions the local demo below
  // uses. A brand-new household gets these plus nothing else.

  Map<String, dynamic> _defaultCategories() => {
        'fish': const Category(id: 'fish', name: 'Fish & meat', icon: Icons.set_meal_rounded).toMap(),
        'rice': const Category(id: 'rice', name: 'Rice & lentils', icon: Icons.inventory_2_rounded).toMap(),
        'utility': const Category(id: 'utility', name: 'Utility', icon: Icons.bolt_rounded).toMap(),
        'household': const Category(id: 'household', name: 'Household', icon: Icons.home_rounded).toMap(),
        'produce': const Category(id: 'produce', name: 'Vegetables & fruits', icon: Icons.eco_rounded).toMap(),
        'transport': const Category(id: 'transport', name: 'Transport', icon: Icons.directions_car_rounded).toMap(),
      };

  Map<String, dynamic> _defaultUnits() => {
        'kg': const Unit(id: 'kg', name: 'Kilogram', abbr: 'kg').toMap(),
        'l': const Unit(id: 'l', name: 'Litre', abbr: 'L').toMap(),
        'pcs': const Unit(id: 'pcs', name: 'Piece', abbr: 'pcs').toMap(),
        'g': const Unit(id: 'g', name: 'Gram', abbr: 'g').toMap(),
        'dz': const Unit(id: 'dz', name: 'Dozen', abbr: 'dz').toMap(),
        'pack': const Unit(id: 'pack', name: 'Pack', abbr: 'pack').toMap(),
      };

  Map<String, dynamic> _defaultPaymentMethods() => {
        'cash': const PaymentMethod(id: 'cash', name: 'Cash', icon: Icons.payments_outlined).toMap(),
        'bank': const PaymentMethod(id: 'bank', name: 'Bank transfer', icon: Icons.account_balance_outlined).toMap(),
        'mobile': const PaymentMethod(
          id: 'mobile',
          name: 'Mobile banking (bKash/Nagad)',
          icon: Icons.smartphone_outlined,
        ).toMap(),
        'card': const PaymentMethod(id: 'card', name: 'Card', icon: Icons.credit_card_outlined).toMap(),
      };

  Map<String, dynamic> _defaultContributionTypes() => {
        'regular': const ContributionType(
          id: 'regular',
          name: 'Regular',
          description: 'Recurring monthly share',
          icon: Icons.repeat_rounded,
        ).toMap(),
        'extra': const ContributionType(
          id: 'extra',
          name: 'Extra',
          description: 'One-off additional amount',
          icon: Icons.add_circle_outline_rounded,
        ).toMap(),
        'occasion': const ContributionType(
          id: 'occasion',
          name: 'Occasion',
          description: 'Gifts, festivals, special events',
          icon: Icons.celebration_rounded,
        ).toMap(),
      };

  Map<String, dynamic> _defaultTxKindConfigs() => {
        'purchase': const TxKindConfig(
          id: 'purchase',
          name: 'Purchase',
          description: 'Money spent from a project fund',
          icon: Icons.shopping_cart_rounded,
          enabled: true,
        ).toMap(),
        'contribution': const TxKindConfig(
          id: 'contribution',
          name: 'Contribution',
          description: 'Money paid in by a contributor',
          icon: Icons.arrow_downward_rounded,
          enabled: true,
        ).toMap(),
        'transfer': const TxKindConfig(
          id: 'transfer',
          name: 'Transfer',
          description: 'Move funds between accounts or wallets',
          icon: Icons.swap_horiz_rounded,
          enabled: true,
        ).toMap(),
        'refund': const TxKindConfig(
          id: 'refund',
          name: 'Refund',
          description: 'Money returned for a prior purchase',
          icon: Icons.replay_rounded,
          enabled: false,
        ).toMap(),
      };

  // ---- Local demo seed (no Firebase project registered for this
  // platform) — unchanged from the original in-memory prototype. --------

  void _seedLocalDemo() {
    currentUser = const AppUser(id: 'u1', name: 'Shanto', email: 'shanto@example.com');

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
