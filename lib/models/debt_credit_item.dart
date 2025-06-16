import 'package:hive/hive.dart';

part 'debt_credit_item.g.dart';

@HiveType(typeId: 0)
class DebtCreditItem extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String personName;

  @HiveField(2)
  double amount;

  @HiveField(3)
  DateTime date;

  @HiveField(4)
  bool isRepaid;

  @HiveField(5)
  bool isDebt; // true = je dois, false = j'ai prêté

  @HiveField(6)
  List<HistoryEntry> history;

  @HiveField(7)
  DateTime? reminderDate;

  @HiveField(8)
  String? notes;

  @HiveField(9)
  String userId;

  DebtCreditItem({
    required this.id,
    required this.personName,
    required this.amount,
    required this.date,
    this.isRepaid = false,
    required this.isDebt,
    this.history = const [],
    this.reminderDate,
    this.notes,
    required this.userId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'personName': personName,
      'amount': amount,
      'date': date.millisecondsSinceEpoch,
      'isRepaid': isRepaid,
      'isDebt': isDebt,
      'history': history.map((h) => h.toMap()).toList(),
      'reminderDate': reminderDate?.millisecondsSinceEpoch,
      'notes': notes,
      'userId': userId,
    };
  }

  factory DebtCreditItem.fromMap(Map<String, dynamic> map) {
    return DebtCreditItem(
      id: map['id'] ?? '',
      personName: map['personName'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] ?? 0),
      isRepaid: map['isRepaid'] ?? false,
      isDebt: map['isDebt'] ?? true,
      history:
          (map['history'] as List<dynamic>?)
              ?.map((h) => HistoryEntry.fromMap(h))
              .toList() ??
          [],
      reminderDate:
          map['reminderDate'] != null
              ? DateTime.fromMillisecondsSinceEpoch(map['reminderDate'])
              : null,
      notes: map['notes'],
      userId: map['userId'] ?? '',
    );
  }
}

@HiveType(typeId: 1)
class HistoryEntry extends HiveObject {
  @HiveField(0)
  DateTime date;

  @HiveField(1)
  String action;

  @HiveField(2)
  String? oldValue;

  @HiveField(3)
  String? newValue;

  HistoryEntry({
    required this.date,
    required this.action,
    this.oldValue,
    this.newValue,
  });

  Map<String, dynamic> toMap() {
    return {
      'date': date.millisecondsSinceEpoch,
      'action': action,
      'oldValue': oldValue,
      'newValue': newValue,
    };
  }

  factory HistoryEntry.fromMap(Map<String, dynamic> map) {
    return HistoryEntry(
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] ?? 0),
      action: map['action'] ?? '',
      oldValue: map['oldValue'],
      newValue: map['newValue'],
    );
  }
}
