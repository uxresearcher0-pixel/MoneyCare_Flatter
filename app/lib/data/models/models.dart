import 'package:flutter/material.dart';

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
}

/// A unit of measure offered when logging a purchase quantity (kg, L, pcs…).
class Unit {
  const Unit({required this.id, required this.name, required this.abbr});

  final String id;
  final String name;
  final String abbr;
}

/// A way money physically moved (cash, bank transfer, mobile banking…).
class PaymentMethod {
  const PaymentMethod({required this.id, required this.name, required this.icon});

  final String id;
  final String name;
  final IconData icon;
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
}
