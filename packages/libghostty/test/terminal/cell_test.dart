@Tags(['ffi'])
library;

import 'package:libghostty/libghostty.dart';
import 'package:test/test.dart';

void main() {
  group('CellColor', () {
    test('DefaultColor equality', () {
      expect(const DefaultColor(), equals(const DefaultColor()));
    });

    test('RgbColor equality', () {
      expect(const RgbColor(10, 20, 30), equals(const RgbColor(10, 20, 30)));
      expect(
        const RgbColor(10, 20, 30),
        isNot(equals(const RgbColor(10, 20, 31))),
      );
    });

    test('different subtypes are not equal', () {
      expect(const DefaultColor(), isNot(equals(const RgbColor(0, 0, 0))));
    });

    test('pattern matching works on sealed type', () {
      const CellColor color = RgbColor(100, 150, 200);
      final result = switch (color) {
        DefaultColor() => 'default',
        RgbColor(:final r, :final g, :final b) => 'rgb:$r,$g,$b',
      };
      expect(result, 'rgb:100,150,200');
    });
  });

  group('CellStyle', () {
    test('default style has no attributes set', () {
      const style = CellStyle();
      expect(style.bold, isFalse);
      expect(style.italic, isFalse);
      expect(style.faint, isFalse);
      expect(style.strikethrough, isFalse);
      expect(style.blink, isFalse);
      expect(style.inverse, isFalse);
      expect(style.invisible, isFalse);
      expect(style.overline, isFalse);
      expect(style.underline, UnderlineStyle.none);
    });

    test('equality with same attributes', () {
      const a = CellStyle(bold: true, italic: true);
      const b = CellStyle(bold: true, italic: true);
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('inequality with different attributes', () {
      const a = CellStyle(bold: true);
      const b = CellStyle(italic: true);
      expect(a, isNot(equals(b)));
    });

    test('copyWith preserves unchanged fields', () {
      const original = CellStyle(bold: true, italic: true);
      final modified = original.copyWith(faint: true);
      expect(modified.bold, isTrue);
      expect(modified.italic, isTrue);
      expect(modified.faint, isTrue);
    });

    test('copyWith overrides specified fields', () {
      const original = CellStyle(bold: true);
      final modified = original.copyWith(bold: false, italic: true);
      expect(modified.bold, isFalse);
      expect(modified.italic, isTrue);
    });

    test('all style flags', () {
      const style = CellStyle(
        bold: true,
        italic: true,
        faint: true,
        strikethrough: true,
        blink: true,
        inverse: true,
        invisible: true,
        overline: true,
        underline: UnderlineStyle.curly,
      );
      expect(style.bold, isTrue);
      expect(style.italic, isTrue);
      expect(style.faint, isTrue);
      expect(style.strikethrough, isTrue);
      expect(style.blink, isTrue);
      expect(style.inverse, isTrue);
      expect(style.invisible, isTrue);
      expect(style.overline, isTrue);
      expect(style.underline, UnderlineStyle.curly);
    });
  });

  group('Cell', () {
    test('empty cell', () {
      const cell = Cell.empty;
      expect(cell.content, '');
      expect(cell.isEmpty, isTrue);
      expect(cell.foreground, isA<DefaultColor>());
      expect(cell.background, isA<DefaultColor>());
      expect(cell.style, const CellStyle());
      expect(cell.isWide, isFalse);
    });

    test('cell with content', () {
      const cell = Cell(content: 'A');
      expect(cell.content, 'A');
      expect(cell.isEmpty, isFalse);
    });

    test('wide character cell', () {
      const cell = Cell(content: '\u{4e16}', wide: CellWidth.wide);
      expect(cell.isWide, isTrue);
      expect(cell.wide, CellWidth.wide);
      expect(cell.content, '\u{4e16}');
    });

    test('cell equality and hashCode', () {
      const a = Cell(
        content: 'A',
        foreground: RgbColor(255, 0, 0),
        underlineColor: RgbColor(0, 0, 255),
        style: CellStyle(bold: true),
      );
      const b = Cell(
        content: 'A',
        foreground: RgbColor(255, 0, 0),
        underlineColor: RgbColor(0, 0, 255),
        style: CellStyle(bold: true),
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('cell inequality across all properties', () {
      const base = Cell(content: 'A');
      expect(base, isNot(equals(const Cell(content: 'B'))));
      expect(
        base,
        isNot(equals(const Cell(content: 'A', style: CellStyle(bold: true)))),
      );
      expect(
        base,
        isNot(
          equals(const Cell(content: 'A', foreground: RgbColor(255, 0, 0))),
        ),
      );
      expect(
        base,
        isNot(
          equals(const Cell(content: 'A', underlineColor: RgbColor(255, 0, 0))),
        ),
      );
      expect(
        base,
        isNot(
          equals(
            const Cell(content: 'A', semanticContent: SemanticContent.input),
          ),
        ),
      );
      expect(
        base,
        isNot(equals(const Cell(content: 'A', wide: CellWidth.wide))),
      );
    });

    test('defaults', () {
      expect(Cell.empty.semanticContent, SemanticContent.output);
      expect(Cell.empty.wide, CellWidth.narrow);
    });
  });

  group('CellWidth', () {
    test('fromNative maps all values', () {
      expect(CellWidth.fromNative(0), CellWidth.narrow);
      expect(CellWidth.fromNative(1), CellWidth.wide);
      expect(CellWidth.fromNative(2), CellWidth.spacerTail);
      expect(CellWidth.fromNative(3), CellWidth.spacerHead);
    });

    test('fromNative defaults to narrow for unknown', () {
      expect(CellWidth.fromNative(99), CellWidth.narrow);
    });
  });

  group('SemanticContent', () {
    test('fromNative maps all values', () {
      expect(SemanticContent.fromNative(0), SemanticContent.output);
      expect(SemanticContent.fromNative(1), SemanticContent.input);
      expect(SemanticContent.fromNative(2), SemanticContent.prompt);
    });

    test('fromNative defaults to output for unknown', () {
      expect(SemanticContent.fromNative(99), SemanticContent.output);
    });
  });
}
