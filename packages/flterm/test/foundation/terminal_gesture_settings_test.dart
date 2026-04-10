import 'package:flterm/src/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TerminalGestureSettings', () {
    test('default constructor uses expected defaults', () {
      const settings = TerminalGestureSettings();
      expect(settings.enabledSelections, equals(SelectionGesture.all));
      expect(settings.blockSelectionModifier, GestureModifier.alt);
      expect(settings.longPressSelectionMode, TerminalSelectionMode.normal);
      expect(settings.lineSelectMode, LineSelectMode.content);
    });

    test('empty enabledSelections disables all selection', () {
      const settings = TerminalGestureSettings(enabledSelections: {});
      expect(settings.enabledSelections, isEmpty);
    });

    test('equality compares all fields', () {
      const a = TerminalGestureSettings();
      const b = TerminalGestureSettings();
      const differentSelections = TerminalGestureSettings(
        enabledSelections: {},
      );
      const differentModifier = TerminalGestureSettings(
        blockSelectionModifier: GestureModifier.meta,
      );
      const differentLongPress = TerminalGestureSettings(
        longPressSelectionMode: TerminalSelectionMode.block,
      );
      const differentLineSelect = TerminalGestureSettings(
        lineSelectMode: LineSelectMode.full,
      );

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
      expect(a, isNot(equals(differentSelections)));
      expect(a, isNot(equals(differentModifier)));
      expect(a, isNot(equals(differentLongPress)));
      expect(a, isNot(equals(differentLineSelect)));
    });

    test('equality ignores set order', () {
      const a = TerminalGestureSettings(
        enabledSelections: {SelectionGesture.word, SelectionGesture.line},
      );
      const b = TerminalGestureSettings(
        enabledSelections: {SelectionGesture.line, SelectionGesture.word},
      );

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('blockSelectionModifier null disables block selection', () {
      const settings = TerminalGestureSettings(blockSelectionModifier: null);
      expect(settings.blockSelectionModifier, isNull);
    });
  });
}
