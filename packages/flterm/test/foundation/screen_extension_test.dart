@Tags(['ffi'])
library;

import 'dart:convert';
import 'dart:typed_data';

import 'package:flterm/src/foundation/screen_extension.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:libghostty/libghostty.dart';

void main() {
  late Terminal terminal;

  setUp(() {
    terminal = Terminal(cols: 20, rows: 3);

    // Row 0: "AB日CD" → col 0:A, 1:B, 2:日(wide), 3:spacer, 4:C, 5:D
    terminal.write(
      Uint8List.fromList([
        ...utf8.encode('AB'),
        0xE6, 0x97, 0xA5, // 日 U+65E5
        ...utf8.encode('CD'),
      ]),
    );
    terminal.renderState.update();
  });

  tearDown(() => terminal.dispose());

  group('snapColToWideBoundary', () {
    test('narrow cell unchanged for both modes', () {
      expect(terminal.snapColToWideBoundary(0, 0, inclusive: true), 0);
      expect(terminal.snapColToWideBoundary(0, 0, inclusive: false), 0);
    });

    test('wide start: inclusive stays, exclusive jumps past', () {
      expect(terminal.snapColToWideBoundary(0, 2, inclusive: true), 2);
      expect(terminal.snapColToWideBoundary(0, 2, inclusive: false), 4);
    });

    test('spacer tail: inclusive snaps left, exclusive snaps right', () {
      expect(terminal.snapColToWideBoundary(0, 3, inclusive: true), 2);
      expect(terminal.snapColToWideBoundary(0, 3, inclusive: false), 4);
    });

    test('out-of-bounds returns col unchanged', () {
      expect(terminal.snapColToWideBoundary(-1, 3, inclusive: true), 3);
      expect(terminal.snapColToWideBoundary(99, 3, inclusive: true), 3);
      expect(terminal.snapColToWideBoundary(0, -1, inclusive: true), -1);
      expect(terminal.snapColToWideBoundary(0, 20, inclusive: true), 20);
    });
  });

  group('snapSelectionCols', () {
    test('rightward drag snaps start inclusive, end exclusive', () {
      final (start, end) = terminal.snapSelectionCols(0, 3, 0, 5);
      expect(start, 2);
      expect(end, 5);
    });

    test('leftward drag snaps start exclusive, end inclusive', () {
      final (start, end) = terminal.snapSelectionCols(0, 3, 0, 0);
      expect(start, 4);
      expect(end, 0);
    });

    test('multi-row uses row comparison for direction', () {
      final (start, end) = terminal.snapSelectionCols(0, 3, 1, 0);
      expect(start, 2);
      expect(end, 0);
    });
  });

  group('wordBoundaryAt', () {
    test('click on spacer tail selects wide char', () {
      final (start, end) = terminal.wordBoundaryAt(0, 3);
      expect(start, 2);
      expect(end, 4);
    });
  });

  group('lineBoundaryAt', () {
    test('non-wrapped row trims trailing empty cells', () {
      // "AB日CD" uses cols 0-5, rest are empty on a 20-col terminal
      final b = terminal.lineBoundaryAt(0);
      expect(b.startRow, 0);
      expect(b.endRow, 0);
      expect(b.endCol, 6);
    });

    test('wrapped line spans multiple rows with trimmed end', () {
      final t = Terminal(cols: 5, rows: 4);
      addTearDown(t.dispose);
      // "ABCDEFGH" wraps: row 0 "ABCDE" (wrapped) → row 1 "FGH  "
      t.write(Uint8List.fromList(utf8.encode('ABCDEFGH')));
      t.renderState.update();

      final b0 = t.lineBoundaryAt(0);
      expect(b0.startRow, 0);
      expect(b0.endRow, 1);
      expect(b0.endCol, 3);

      final b1 = t.lineBoundaryAt(1);
      expect(b1, b0);
    });

    test('separate lines have independent boundaries', () {
      final t = Terminal(cols: 5, rows: 4);
      addTearDown(t.dispose);
      t.write(Uint8List.fromList(utf8.encode('AB\r\nCD')));
      t.renderState.update();

      expect(t.lineBoundaryAt(0).endCol, 2);
      expect(t.lineBoundaryAt(1).endCol, 2);
      expect(t.lineBoundaryAt(1).startRow, 1);
    });

    test('out-of-bounds row returns safe default', () {
      expect(terminal.lineBoundaryAt(-1).endCol, 0);
      expect(terminal.lineBoundaryAt(99).endCol, 0);
    });
  });
}
