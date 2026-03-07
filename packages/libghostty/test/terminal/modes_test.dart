@Tags(['ffi'])
library;

import 'package:libghostty/libghostty.dart';
import 'package:test/test.dart';

void main() {
  group('TerminalModes', () {
    test('defaults are all false except autoWrap', () {
      const modes = TerminalModes();
      expect(modes.bracketedPaste, isFalse);
      expect(modes.alternateScreen, isFalse);
      expect(modes.cursorKeyApplication, isFalse);
      expect(modes.keypadApplication, isFalse);
      expect(modes.autoWrap, isTrue);
      expect(modes.originMode, isFalse);
      expect(modes.insertMode, isFalse);
      expect(modes.mouseTracking, MouseTracking.none);
    });

    test('equality with same values', () {
      const a = TerminalModes(bracketedPaste: true, autoWrap: false);
      const b = TerminalModes(bracketedPaste: true, autoWrap: false);
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('inequality with different values', () {
      const a = TerminalModes(bracketedPaste: true);
      const b = TerminalModes();
      expect(a, isNot(equals(b)));
    });

    test('copyWith preserves unchanged fields', () {
      const original = TerminalModes(bracketedPaste: true, autoWrap: false);
      final modified = original.copyWith(alternateScreen: true);
      expect(modified.bracketedPaste, isTrue);
      expect(modified.alternateScreen, isTrue);
      expect(modified.autoWrap, isFalse);
    });

    test('copyWith overrides specified fields', () {
      const original = TerminalModes(bracketedPaste: true);
      final modified = original.copyWith(bracketedPaste: false);
      expect(modified.bracketedPaste, isFalse);
    });

    test('equality includes mouseTracking', () {
      const a = TerminalModes(mouseTracking: MouseTracking.normal);
      const b = TerminalModes(mouseTracking: MouseTracking.normal);
      const c = TerminalModes(mouseTracking: MouseTracking.x10);
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
      expect(a, isNot(equals(c)));
    });

    test('copyWith mouseTracking', () {
      const original = TerminalModes();
      final modified = original.copyWith(mouseTracking: .any);
      expect(modified.mouseTracking, MouseTracking.any);
      expect(modified.autoWrap, isTrue);
    });

    test('toString reflects mouseTracking state', () {
      expect(
        const TerminalModes(mouseTracking: .button).toString(),
        contains('mouseTracking'),
      );
      expect(
        const TerminalModes().toString(),
        isNot(contains('mouseTracking')),
      );
    });
  });
}
