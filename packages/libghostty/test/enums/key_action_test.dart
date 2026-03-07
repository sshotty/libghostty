import 'package:libghostty/src/enums/key_action.dart';
import 'package:test/test.dart';

void main() {
  group('KeyAction', () {
    test('fromNative round-trips for all values', () {
      for (final action in KeyAction.values) {
        expect(KeyActionNative.fromNative(action.nativeValue), action);
      }
    });

    test('fromNative defaults to press for unknown values', () {
      expect(KeyActionNative.fromNative(-1), KeyAction.press);
      expect(KeyActionNative.fromNative(3), KeyAction.press);
      expect(KeyActionNative.fromNative(999), KeyAction.press);
    });
  });
}
