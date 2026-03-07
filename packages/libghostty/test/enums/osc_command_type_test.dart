import 'package:libghostty/src/enums/osc_command_type.dart';
import 'package:test/test.dart';

void main() {
  group('OscCommandType', () {
    test('fromNative round-trips for all values', () {
      for (final type in OscCommandType.values) {
        expect(OscCommandTypeNative.fromNative(type.nativeValue), type);
      }
    });

    test('fromNative returns invalid for out-of-bounds values', () {
      expect(OscCommandTypeNative.fromNative(-1), OscCommandType.invalid);
      expect(OscCommandTypeNative.fromNative(999), OscCommandType.invalid);
    });
  });
}
