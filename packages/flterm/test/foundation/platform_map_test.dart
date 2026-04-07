import 'package:flterm/src/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:libghostty/libghostty.dart' show Key;

void main() {
  group('keyFromPhysical', () {
    test('maps physical keys to libghostty Keys', () {
      expect(keyFromPhysical(.keyA), Key.a);
      expect(keyFromPhysical(.keyZ), Key.z);
      expect(keyFromPhysical(.digit0), Key.digit0);
      expect(keyFromPhysical(.digit9), Key.digit9);
      expect(keyFromPhysical(.arrowUp), Key.arrowUp);
      expect(keyFromPhysical(.arrowDown), Key.arrowDown);
      expect(keyFromPhysical(.f1), Key.f1);
      expect(keyFromPhysical(.f24), Key.f24);
      expect(keyFromPhysical(.shiftLeft), Key.shiftLeft);
      expect(keyFromPhysical(.controlLeft), Key.controlLeft);
      expect(keyFromPhysical(.altLeft), Key.altLeft);
      expect(keyFromPhysical(.metaLeft), Key.metaLeft);
      expect(keyFromPhysical(.enter), Key.enter);
      expect(keyFromPhysical(.backspace), Key.backspace);
      expect(keyFromPhysical(.tab), Key.tab);
      expect(keyFromPhysical(.space), Key.space);
      expect(keyFromPhysical(.escape), Key.escape);
      expect(keyFromPhysical(.home), Key.home);
      expect(keyFromPhysical(.end), Key.end);
      expect(keyFromPhysical(.pageUp), Key.pageUp);
      expect(keyFromPhysical(.delete), Key.delete);
      expect(keyFromPhysical(.numpad0), Key.numpad0);
      expect(keyFromPhysical(.numpadEnter), Key.numpadEnter);
      expect(keyFromPhysical(.comma), Key.comma);
      expect(keyFromPhysical(.semicolon), Key.semicolon);
      expect(keyFromPhysical(.backquote), Key.backquote);
    });

    test('unmapped key returns Key.unidentified', () {
      final unknown =
          PhysicalKeyboardKey.findKeyByCode(0x999999) ??
          const PhysicalKeyboardKey(0x999999);
      expect(keyFromPhysical(unknown), Key.unidentified);
    });
  });

  group('keyFromCodepoint', () {
    test('maps ASCII codepoints to Keys', () {
      expect(keyFromCodepoint(0x61), Key.a);
      expect(keyFromCodepoint(0x7a), Key.z);
      expect(keyFromCodepoint(0x41), Key.a);
      expect(keyFromCodepoint(0x5a), Key.z);
      expect(keyFromCodepoint(0x30), Key.digit0);
      expect(keyFromCodepoint(0x39), Key.digit9);
      expect(keyFromCodepoint(0x20), Key.space);
    });

    test('unmapped codepoints return null', () {
      expect(keyFromCodepoint(0x00), isNull);
      expect(keyFromCodepoint(0x1b), isNull);
      expect(keyFromCodepoint(0x7f), isNull);
      expect(keyFromCodepoint(0x100), isNull);
    });
  });

  group('unshiftedCodepointForKey', () {
    test('character keys return lowercase ASCII codepoint', () {
      expect(unshiftedCodepointForKey(Key.a), 0x61);
      expect(unshiftedCodepointForKey(Key.z), 0x7a);
      expect(unshiftedCodepointForKey(Key.digit0), 0x30);
      expect(unshiftedCodepointForKey(Key.digit9), 0x39);
    });

    test('non-character keys return 0', () {
      expect(unshiftedCodepointForKey(Key.enter), 0);
      expect(unshiftedCodepointForKey(Key.arrowUp), 0);
      expect(unshiftedCodepointForKey(Key.f1), 0);
    });
  });
}
