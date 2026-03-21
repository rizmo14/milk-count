import 'package:flutter_test/flutter_test.dart';
import 'package:milk_count/models/feeding.dart';

void main() {
  group('Feeding Model', () {
    test('should create a bottle feeding', () {
      final feeding = Feeding(
        id: '1',
        dateTime: DateTime(2024, 1, 1, 10, 0),
        type: FeedingType.bottle,
        amountMl: 60,
      );

      expect(feeding.type, FeedingType.bottle);
      expect(feeding.amountMl, 60);
      expect(feeding.durationMinutes, isNull);
    });

    test('should create a breast feeding', () {
      final feeding = Feeding(
        id: '2',
        dateTime: DateTime(2024, 1, 1, 12, 0),
        type: FeedingType.breast,
        durationMinutes: 15,
        side: BreastSide.left,
      );

      expect(feeding.type, FeedingType.breast);
      expect(feeding.durationMinutes, 15);
      expect(feeding.side, BreastSide.left);
      expect(feeding.amountMl, isNull);
    });

    test('should serialize and deserialize correctly', () {
      final feedings = [
        Feeding(
          id: '1',
          dateTime: DateTime(2024, 1, 1, 10, 0),
          type: FeedingType.bottle,
          amountMl: 90,
          notes: 'Test note',
        ),
        Feeding(
          id: '2',
          dateTime: DateTime(2024, 1, 1, 14, 0),
          type: FeedingType.breast,
          durationMinutes: 20,
          side: BreastSide.both,
        ),
      ];

      final encoded = Feeding.encode(feedings);
      final decoded = Feeding.decode(encoded);

      expect(decoded.length, 2);
      expect(decoded[0].amountMl, 90);
      expect(decoded[0].notes, 'Test note');
      expect(decoded[1].durationMinutes, 20);
      expect(decoded[1].side, BreastSide.both);
    });
  });
}
