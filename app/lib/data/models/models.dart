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
