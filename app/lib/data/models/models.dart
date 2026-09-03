import 'package:flutter/material.dart';

// ---- Icon (de)serialization helpers ---------------------------------
// IconData isn't JSON-native. We store its codePoint + fontFamily and
// rebuild it on the way back. Reconstructing IconData from a variable
// (rather than a literal `Icons.xxx`) defeats Flutter's icon-font
// tree-shaker, so release builds pass --no-tree-shake-icons (see the CI
// workflow) — the app ships the full Material icon font instead of a
// per-icon subset, which is fine at this app's size.
Map<String, dynamic> _iconToMap(IconData icon) => {
      'codePoint': icon.codePoint,
      'fontFamily': icon.fontFamily,
      'fontPackage': icon.fontPackage,
    };

IconData _iconFromMap(Map<String, dynamic>? map, IconData fallback) {
  if (map == null) return fallback;
  return IconData(
    (map['codePoint'] as num?)?.toInt() ?? fallback.codePoint,
    fontFamily: map['fontFamily'] as String? ?? fallback.fontFamily,
    fontPackage: map['fontPackage'] as String? ?? fallback.fontPackage,
  );
}

List<String> _stringList(dynamic value) =>
    (value as List?)?.map((e) => e.toString()).toList() ?? <String>[];

/// The signed-in user / household owner.
class AppUser {
  const AppUser({required this.id, required this.name, required this.email});

  final String id;
  final String name;
  final String email;

  String get initial => name.isNotEmpty ? name[0].toUpperCase() : '?';
  String get firstName => name.split(' ').first;
}

/// A workspace groups projects for a household, team, or shared circle.
class Workspace {
  Workspace({
    required this.id,
    required this.name,
    required this.memberCount,
    List<String>? projectIds,
  }) : projectIds = List<String>.of(projectIds ?? const []);

  final String id;
  String name;
  int memberCount;
  List<String> projectIds;

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'memberCount': memberCount,
        'projectIds': projectIds,
      };

  factory Workspace.fromMap(Map<String, dynamic> map) => Workspace(
        id: map['id'] as String,
        name: map['name'] as String? ?? '',
        memberCount: (map['memberCount'] as num?)?.toInt() ?? 1,
        projectIds: _stringList(map['projectIds']),
      );
}

enum ProjectIconKind { folder, home, cart, flight, gift, wallet }

/// A project is a tracked budget/spending scope inside a workspace
/// (e.g. "Monthly Grocery", "Family Vacation").
class Project {
  Project({
    required this.id,
    required this.workspaceId,
    required this.name,
    this.description = '',
    this.icon = ProjectIconKind.folder,
    List<String>? memberIds,
    List<String>? periodIds,
    this.activePeriodId,
    this.isArchived = false,
  })  : memberIds = List<String>.of(memberIds ?? const []),
        periodIds = List<String>.of(periodIds ?? const []);

  final String id;
  final String workspaceId;
  String name;
  String description;
  ProjectIconKind icon;
  List<String> memberIds;
  List<String> periodIds;
  String? activePeriodId;
  bool isArchived;

  Map<String, dynamic> toMap() => {
        'id': id,
        'workspaceId': workspaceId,
        'name': name,
        'description': description,
        'icon': icon.name,
        'memberIds': memberIds,
        'periodIds': periodIds,
        'activePeriodId': activePeriodId,
        'isArchived': isArchived,
      };

  factory Project.fromMap(Map<String, dynamic> map) => Project(
        id: map['id'] as String,
        workspaceId: map['workspaceId'] as String? ?? '',
        name: map['name'] as String? ?? '',
        description: map['description'] as String? ?? '',
        icon: ProjectIconKind.values.firstWhere(
          (v) => v.name == map['icon'],
          orElse: () => ProjectIconKind.folder,
        ),
        memberIds: _stringList(map['memberIds']),
        periodIds: _stringList(map['periodIds']),
        activePeriodId: map['activePeriodId'] as String?,
        isArchived: map['isArchived'] as bool? ?? false,
      );
}

/// A person participating in a project (contributor / member).
class Person {
  Person({
    required this.id,
    required this.name,
    this.role = 'Member',
    this.contributionType = 'Regular',
    this.monthlyPledge = 0,
    this.isOwner = false,
  });

  final String id;
  String name;
  String role;
  String contributionType;
  num monthlyPledge;
  bool isOwner;

  String get initial => name.isNotEmpty ? name[0].toUpperCase() : '?';

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'role': role,
        'contributionType': contributionType,
        'monthlyPledge': monthlyPledge,
        'isOwner': isOwner,
      };

  factory Person.fromMap(Map<String, dynamic> map) => Person(
        id: map['id'] as String,
        name: map['name'] as String? ?? '',
        role: map['role'] as String? ?? 'Member',
        contributionType: map['contributionType'] as String? ?? 'Regular',
        monthlyPledge: (map['monthlyPledge'] as num?) ?? 0,
        isOwner: map['isOwner'] as bool? ?? false,
      );
}

/// A budget/tracking period within a project (e.g. "August 2026").
class Period {
  Period({
    required this.id,
    required this.projectId,
    required this.label,
    required this.startDate,
    required this.endDate,
    this.openingBalance = 0,
    this.monthlyBudget = 0,
    this.isActive = true,
  });

  final String id;
  final String projectId;
  String label;
  DateTime startDate;
  DateTime endDate;
  num openingBalance;
  num monthlyBudget;
  bool isActive;

  Map<String, dynamic> toMap() => {
        'id': id,
        'projectId': projectId,
        'label': label,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'openingBalance': openingBalance,
        'monthlyBudget': monthlyBudget,
        'isActive': isActive,
      };

  factory Period.fromMap(Map<String, dynamic> map) => Period(
        id: map['id'] as String,
        projectId: map['projectId'] as String? ?? '',
        label: map['label'] as String? ?? '',
        startDate: DateTime.tryParse(map['startDate'] as String? ?? '') ?? DateTime.now(),
        endDate: DateTime.tryParse(map['endDate'] as String? ?? '') ?? DateTime.now(),
        openingBalance: (map['openingBalance'] as num?) ?? 0,
        monthlyBudget: (map['monthlyBudget'] as num?) ?? 0,
        isActive: map['isActive'] as bool? ?? true,
      );
}

class Category {
  const Category({
    required this.id,
    required this.name,
    required this.icon,
    this.budget,
  });

  final String id;
  final String name;
  final IconData icon;
  final num? budget;

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'icon': _iconToMap(icon),
        'budget': budget,
      };

  factory Category.fromMap(Map<String, dynamic> map) => Category(
        id: map['id'] as String,
        name: map['name'] as String? ?? '',
        icon: _iconFromMap(map['icon'] as Map<String, dynamic>?, Icons.category_rounded),
        budget: map['budget'] as num?,
      );
}

enum TransactionType { purchase, contribution }

class AppTransaction {
  AppTransaction({
    required this.id,
    required this.periodId,
    required this.type,
    required this.title,
    required this.amount,
    required this.date,
    this.categoryId,
    this.personId,
    this.contributionType = 'Regular',
    this.note = '',
    this.unit,
    this.quantity,
  });

  final String id;
  final String periodId;
  TransactionType type;
  String title;
  num amount;
  DateTime date;
  String? categoryId;
  String? personId;
  String contributionType;
  String note;
  String? unit;
  num? quantity;

  Map<String, dynamic> toMap() => {
        'id': id,
        'periodId': periodId,
        'type': type.name,
        'title': title,
        'amount': amount,
        'date': date.toIso8601String(),
        'categoryId': categoryId,
        'personId': personId,
        'contributionType': contributionType,
        'note': note,
        'unit': unit,
        'quantity': quantity,
      };

  factory AppTransaction.fromMap(Map<String, dynamic> map) => AppTransaction(
        id: map['id'] as String,
        periodId: map['periodId'] as String? ?? '',
        type: TransactionType.values.firstWhere(
          (v) => v.name == map['type'],
          orElse: () => TransactionType.purchase,
        ),
        title: map['title'] as String? ?? '',
        amount: (map['amount'] as num?) ?? 0,
        date: DateTime.tryParse(map['date'] as String? ?? '') ?? DateTime.now(),
        categoryId: map['categoryId'] as String?,
        personId: map['personId'] as String?,
        contributionType: map['contributionType'] as String? ?? 'Regular',
        note: map['note'] as String? ?? '',
        unit: map['unit'] as String?,
        quantity: map['quantity'] as num?,
      );
}

/// A unit of measure offered when logging a purchase quantity (kg, L, pcs…).
class Unit {
  const Unit({required this.id, required this.name, required this.abbr});

  final String id;
  final String name;
  final String abbr;

  Map<String, dynamic> toMap() => {'id': id, 'name': name, 'abbr': abbr};

  factory Unit.fromMap(Map<String, dynamic> map) => Unit(
        id: map['id'] as String,
        name: map['name'] as String? ?? '',
        abbr: map['abbr'] as String? ?? '',
      );
}

/// A way money physically moved (cash, bank transfer, mobile banking…).
class PaymentMethod {
  const PaymentMethod({required this.id, required this.name, required this.icon});

  final String id;
  final String name;
  final IconData icon;

  Map<String, dynamic> toMap() => {'id': id, 'name': name, 'icon': _iconToMap(icon)};

  factory PaymentMethod.fromMap(Map<String, dynamic> map) => PaymentMethod(
        id: map['id'] as String,
        name: map['name'] as String? ?? '',
        icon: _iconFromMap(map['icon'] as Map<String, dynamic>?, Icons.payments_outlined),
      );
}

/// A category of contribution (Regular, Extra, Occasion…) offered when
/// logging what a person paid in.
class ContributionType {
  const ContributionType({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
  });

  final String id;
  final String name;
  final String description;
  final IconData icon;

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'description': description,
        'icon': _iconToMap(icon),
      };

  factory ContributionType.fromMap(Map<String, dynamic> map) => ContributionType(
        id: map['id'] as String,
        name: map['name'] as String? ?? '',
        description: map['description'] as String? ?? '',
        icon: _iconFromMap(map['icon'] as Map<String, dynamic>?, Icons.label_rounded),
      );
}

/// Whether a kind of transaction (Purchase, Contribution, Transfer,
/// Refund…) is available for logging in this workspace.
class TxKindConfig {
  const TxKindConfig({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.enabled,
  });

  final String id;
  final String name;
  final String description;
  final IconData icon;
  final bool enabled;

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'description': description,
        'icon': _iconToMap(icon),
        'enabled': enabled,
      };

  factory TxKindConfig.fromMap(Map<String, dynamic> map) => TxKindConfig(
        id: map['id'] as String,
        name: map['name'] as String? ?? '',
        description: map['description'] as String? ?? '',
        icon: _iconFromMap(map['icon'] as Map<String, dynamic>?, Icons.receipt_long_rounded),
        enabled: map['enabled'] as bool? ?? true,
      );
}

/// A named fund/wallet a project's money can be tracked against.
class FundAccount {
  const FundAccount({
    required this.id,
    required this.name,
    required this.balance,
    required this.icon,
  });

  final String id;
  final String name;
  final num balance;
  final IconData icon;

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'balance': balance,
        'icon': _iconToMap(icon),
      };

  factory FundAccount.fromMap(Map<String, dynamic> map) => FundAccount(
        id: map['id'] as String,
        name: map['name'] as String? ?? '',
        balance: (map['balance'] as num?) ?? 0,
        icon: _iconFromMap(map['icon'] as Map<String, dynamic>?, Icons.account_balance_wallet_rounded),
      );
}

/// Where a custom field applies: every project in a workspace, or one project.
enum CustomFieldScope { workspace, project }

/// A user-defined extra field (e.g. "Preferred Unit", "Receipt Required")
/// attached to a workspace or a single project.
class CustomField {
  const CustomField({
    required this.id,
    required this.name,
    required this.type,
    required this.scope,
    this.detail = '',
    this.required = false,
    this.options = const [],
  });

  final String id;
  final String name;
  final String type; // Text / Number / Dropdown / Toggle / Date / Wallet / Calculated Total
  final CustomFieldScope scope;
  final String detail;
  final bool required;
  final List<String> options;

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'type': type,
        'scope': scope.name,
        'detail': detail,
        'required': required,
        'options': options,
      };

  factory CustomField.fromMap(Map<String, dynamic> map) => CustomField(
        id: map['id'] as String,
        name: map['name'] as String? ?? '',
        type: map['type'] as String? ?? 'Text',
        scope: CustomFieldScope.values.firstWhere(
          (v) => v.name == map['scope'],
          orElse: () => CustomFieldScope.project,
        ),
        detail: map['detail'] as String? ?? '',
        required: map['required'] as bool? ?? false,
        options: _stringList(map['options']),
      );
}

/// A recurring bill or contribution reminder (e.g. "Electricity bill,
/// monthly on the 5th"). Purely a reminder list in this build — enabling
/// one does not yet auto-create transactions each period.
class RecurringRule {
  const RecurringRule({
    required this.id,
    required this.title,
    required this.schedule,
    required this.amount,
    this.enabled = true,
  });

  final String id;
  final String title;
  final String schedule;
  final num amount;
  final bool enabled;

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'schedule': schedule,
        'amount': amount,
        'enabled': enabled,
      };

  factory RecurringRule.fromMap(Map<String, dynamic> map) => RecurringRule(
        id: map['id'] as String,
        title: map['title'] as String? ?? '',
        schedule: map['schedule'] as String? ?? '',
        amount: (map['amount'] as num?) ?? 0,
        enabled: map['enabled'] as bool? ?? true,
      );
}

/// An in-app notification shown in the notifications inbox.
class AppNotification {
  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.time,
    this.icon = Icons.notifications_rounded,
    this.read = false,
  });

  final String id;
  final String title;
  final String body;
  final DateTime time;
  final IconData icon;
  bool read;

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'body': body,
        'time': time.toIso8601String(),
        'icon': _iconToMap(icon),
        'read': read,
      };

  factory AppNotification.fromMap(Map<String, dynamic> map) => AppNotification(
        id: map['id'] as String,
        title: map['title'] as String? ?? '',
        body: map['body'] as String? ?? '',
        time: DateTime.tryParse(map['time'] as String? ?? '') ?? DateTime.now(),
        icon: _iconFromMap(map['icon'] as Map<String, dynamic>?, Icons.notifications_rounded),
        read: map['read'] as bool? ?? false,
      );
}
