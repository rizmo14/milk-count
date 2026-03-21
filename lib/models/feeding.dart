import 'dart:convert';

enum FeedingType { bottle, breast }

enum BreastSide { left, right, both }

class Feeding {
  final String id;
  final DateTime dateTime;
  final FeedingType type;
  final double? amountMl; // for bottle feeding
  final int? durationMinutes; // for breast feeding
  final BreastSide? side; // for breast feeding
  final String? notes;

  Feeding({
    required this.id,
    required this.dateTime,
    required this.type,
    this.amountMl,
    this.durationMinutes,
    this.side,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'dateTime': dateTime.toIso8601String(),
        'type': type.index,
        'amountMl': amountMl,
        'durationMinutes': durationMinutes,
        'side': side?.index,
        'notes': notes,
      };

  factory Feeding.fromJson(Map<String, dynamic> json) => Feeding(
        id: json['id'] as String,
        dateTime: DateTime.parse(json['dateTime'] as String),
        type: FeedingType.values[json['type'] as int],
        amountMl: (json['amountMl'] as num?)?.toDouble(),
        durationMinutes: json['durationMinutes'] as int?,
        side: json['side'] != null
            ? BreastSide.values[json['side'] as int]
            : null,
        notes: json['notes'] as String?,
      );

  static String encode(List<Feeding> feedings) =>
      json.encode(feedings.map((f) => f.toJson()).toList());

  static List<Feeding> decode(String feedingsString) =>
      (json.decode(feedingsString) as List)
          .map((item) => Feeding.fromJson(item as Map<String, dynamic>))
          .toList();
}
