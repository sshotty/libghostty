import 'package:libghostty/input.dart';
import 'package:test/test.dart';

void main() {
  group('KittyKeyFlags', () {
    test('disabled has value 0', () {
      expect(KittyKeyFlags.disabled.isDisabled, isTrue);
    });

    test('all combines all flags', () {
      expect(KittyKeyFlags.all.isDisabled, isFalse);
    });

    test('| operator combines flags', () {
      final combined = KittyKeyFlags.disambiguate | KittyKeyFlags.reportEvents;
      expect(combined.isDisabled, isFalse);
    });

    test('isDisabled returns false for non-zero flags', () {
      expect(KittyKeyFlags.disambiguate.isDisabled, isFalse);
      expect(KittyKeyFlags.all.isDisabled, isFalse);
    });

    test('equality compares by value', () {
      final a = KittyKeyFlags.disambiguate | KittyKeyFlags.reportEvents;
      final b = KittyKeyFlags.reportEvents | KittyKeyFlags.disambiguate;
      expect(a, equals(b));
    });

    test('inequality for different values', () {
      expect(
        KittyKeyFlags.disambiguate,
        isNot(equals(KittyKeyFlags.reportEvents)),
      );
    });

    test('hashCode is consistent with equality', () {
      final a = KittyKeyFlags.disambiguate | KittyKeyFlags.reportAll;
      final b = KittyKeyFlags.reportAll | KittyKeyFlags.disambiguate;
      expect(a.hashCode, equals(b.hashCode));
    });

    test('toString contains hex value', () {
      expect(KittyKeyFlags.disambiguate.toString(), 'KittyKeyFlags(0x1)');
      expect(KittyKeyFlags.all.toString(), 'KittyKeyFlags(0x1f)');
    });
  });
}
