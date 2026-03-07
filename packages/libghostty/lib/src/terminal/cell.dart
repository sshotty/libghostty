import 'package:meta/meta.dart';

import '../color.dart';
import '../enums/underline_style.dart' show UnderlineStyle;

/// An immutable snapshot of a single terminal cell.
@immutable
class Cell {
  static const empty = Cell();

  /// Unicode text content, or empty string for blank cells.
  final String content;
  final CellColor foreground;
  final CellColor background;
  final CellStyle style;
  final CellWidth wide;
  final SemanticContent semanticContent;

  /// Explicit underline color set by the application, or null for default.
  final CellColor? underlineColor;

  const Cell({
    this.content = '',
    this.foreground = const DefaultColor(),
    this.background = const DefaultColor(),
    this.style = const CellStyle(),
    this.wide = CellWidth.narrow,
    this.semanticContent = SemanticContent.output,
    this.underlineColor,
  });

  @override
  int get hashCode => Object.hash(
    content,
    foreground,
    background,
    style,
    wide,
    semanticContent,
    underlineColor,
  );

  bool get isEmpty => content.isEmpty;

  /// True for characters that occupy two columns (e.g. CJK).
  bool get isWide => wide == CellWidth.wide;

  @override
  bool operator ==(Object other) =>
      other is Cell &&
      other.content == content &&
      other.foreground == foreground &&
      other.background == background &&
      other.style == style &&
      other.wide == wide &&
      other.semanticContent == semanticContent &&
      other.underlineColor == underlineColor;

  @override
  String toString() => 'Cell($content)';
}

/// Text style attributes for a terminal cell.
@immutable
class CellStyle {
  final bool bold;
  final bool italic;
  final bool faint;
  final bool strikethrough;
  final bool blink;
  final bool inverse;
  final bool invisible;
  final bool overline;
  final UnderlineStyle underline;

  const CellStyle({
    this.bold = false,
    this.italic = false,
    this.faint = false,
    this.strikethrough = false,
    this.blink = false,
    this.inverse = false,
    this.invisible = false,
    this.overline = false,
    this.underline = UnderlineStyle.none,
  });

  @override
  int get hashCode => Object.hash(
    bold,
    italic,
    faint,
    strikethrough,
    blink,
    inverse,
    invisible,
    overline,
    underline,
  );

  @override
  bool operator ==(Object other) =>
      other is CellStyle &&
      other.bold == bold &&
      other.italic == italic &&
      other.faint == faint &&
      other.strikethrough == strikethrough &&
      other.blink == blink &&
      other.inverse == inverse &&
      other.invisible == invisible &&
      other.overline == overline &&
      other.underline == underline;

  CellStyle copyWith({
    bool? bold,
    bool? italic,
    bool? faint,
    bool? strikethrough,
    bool? blink,
    bool? inverse,
    bool? invisible,
    bool? overline,
    UnderlineStyle? underline,
  }) {
    return CellStyle(
      bold: bold ?? this.bold,
      italic: italic ?? this.italic,
      faint: faint ?? this.faint,
      strikethrough: strikethrough ?? this.strikethrough,
      blink: blink ?? this.blink,
      inverse: inverse ?? this.inverse,
      invisible: invisible ?? this.invisible,
      overline: overline ?? this.overline,
      underline: underline ?? this.underline,
    );
  }

  @override
  String toString() {
    final flags = <String>[];
    if (bold) flags.add('bold');
    if (italic) flags.add('italic');
    if (faint) flags.add('faint');
    if (strikethrough) flags.add('strikethrough');
    if (blink) flags.add('blink');
    if (inverse) flags.add('inverse');
    if (invisible) flags.add('invisible');
    if (overline) flags.add('overline');
    if (underline != UnderlineStyle.none) flags.add('underline: $underline');
    return 'CellStyle(${flags.join(', ')})';
  }
}

/// How a cell participates in wide-character rendering.
enum CellWidth {
  narrow(0),
  wide(1),

  /// Placeholder after a wide character.
  spacerTail(2),

  /// Placeholder before a wide character (used during reflow).
  spacerHead(3);

  static final _nativeMap = {for (final w in values) w.nativeValue: w};

  @internal
  final int nativeValue;

  const CellWidth(this.nativeValue);

  @internal
  static CellWidth fromNative(int value) => _nativeMap[value] ?? .narrow;
}

/// Semantic content type set by shell integration (OSC 133).
enum SemanticContent {
  output(0),
  input(1),
  prompt(2);

  static final _nativeMap = {for (final s in values) s.nativeValue: s};

  @internal
  final int nativeValue;

  const SemanticContent(this.nativeValue);

  @internal
  static SemanticContent fromNative(int value) => _nativeMap[value] ?? .output;
}
