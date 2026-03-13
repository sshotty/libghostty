@Tags(['ffi'])
library;

import 'package:libghostty/libghostty.dart';
import 'package:test/test.dart';

void main() {
  group('Scrollback', () {
    late Terminal terminal;

    setUp(() => terminal = Terminal(cols: 80, rows: 3));

    tearDown(() => terminal.dispose());

    test('created when output exceeds screen height', () {
      for (var i = 0; i < 4; i++) {
        terminal.write(.fromList('Line$i\r\n'.codeUnits));
      }
      expect(terminal.scrollback.length, 2);
    });

    test('preserves content in order', () {
      terminal.write(.fromList('AAA\r\nBBB\r\nCCC\r\nDDD\r\n'.codeUnits));
      expect(terminal.scrollback.length, 2);
      expect(terminal.scrollback.lineAt(0).text, startsWith('AAA'));
    });

    test('grows with continued output', () {
      for (var i = 0; i < 20; i++) {
        terminal.write(.fromList('Line$i\r\n'.codeUnits));
      }
      expect(terminal.scrollback.length, 18);
    });

    test('returns zero length on alternate screen', () {
      for (var i = 0; i < 10; i++) {
        terminal.write(.fromList('Line$i\r\n'.codeUnits));
      }
      final primaryLength = terminal.scrollback.length;
      expect(primaryLength, 8);

      terminal.write(.fromList('\x1b[?1049h'.codeUnits));
      expect(terminal.scrollback.length, 0);

      for (var i = 0; i < 10; i++) {
        terminal.write(.fromList('AltLine$i\r\n'.codeUnits));
      }
      expect(terminal.scrollback.length, 0);

      terminal.write(.fromList('\x1b[?1049l'.codeUnits));
      expect(terminal.scrollback.length, primaryLength);
    });

    test('lineAt returns correct content', () {
      final terminal = Terminal(cols: 10, rows: 2);
      addTearDown(terminal.dispose);
      terminal.write(.fromList('FIRST\r\nSECOND\r\nTHIRD\r\n'.codeUnits));
      expect(terminal.scrollback.length, 2);
      expect(terminal.scrollback.lineAt(0).text, startsWith('FIRST'));
    });

    test('lineAt throws for out-of-bounds index', () {
      for (var i = 0; i < 10; i++) {
        terminal.write(.fromList('Line$i\r\n'.codeUnits));
      }
      expect(() => terminal.scrollback.lineAt(-1), throwsRangeError);
      expect(
        () => terminal.scrollback.lineAt(terminal.scrollback.length),
        throwsRangeError,
      );
    });

    test('isRowWrapped true for soft-wrapped lines', () {
      final terminal = Terminal(cols: 5, rows: 3);
      addTearDown(terminal.dispose);
      terminal.write(.fromList('ABCDEFGHIJ\r\n'.codeUnits));
      terminal.write(.fromList('KLMNO\r\n'.codeUnits));
      terminal.write(.fromList('PQRST\r\n'.codeUnits));
      terminal.write(.fromList('UVWXY\r\n'.codeUnits));
      expect(terminal.scrollback.length, 3);
      expect(terminal.scrollback.isRowWrapped(0), isTrue);
    });

    test('isRowWrapped false for non-wrapped lines', () {
      for (var i = 0; i < 10; i++) {
        terminal.write(.fromList('Short\r\n'.codeUnits));
      }
      expect(terminal.scrollback.length, 8);
      expect(terminal.scrollback.isRowWrapped(0), isFalse);
    });

    test('linesInRange matches sequential lineAt calls', () {
      for (var i = 0; i < 10; i++) {
        terminal.write(.fromList('Line$i\r\n'.codeUnits));
      }
      expect(terminal.scrollback.length, 8);
      final lines = terminal.scrollback.linesInRange(0, 3);
      expect(lines.length, 3);
      for (var i = 0; i < 3; i++) {
        expect(lines[i].text, terminal.scrollback.lineAt(i).text);
      }
    });

    test('linesInRange with count zero returns empty list', () {
      expect(terminal.scrollback.linesInRange(0, 0), isEmpty);
    });
  });
}
