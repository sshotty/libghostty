part of 'terminal.dart';

/// A range of terminal content between two cell positions.
///
/// Endpoints are resolved against the terminal's current page state at
/// [Terminal.createFormatter]. Subsequent mutating operations on the
/// terminal (write, reset, resize) may invalidate those endpoints;
/// create a fresh formatter with a new [Selection] after such operations.
///
/// ```dart
/// final selection = Selection(
///   startCol: 0, startRow: 0,
///   endCol: 10, endRow: 0,
/// );
/// final formatter = terminal.createFormatter(
///   format: FormatterFormat.plain,
///   selection: selection,
/// );
/// ```
@immutable
class Selection {
  /// Zero-based column of the selection start (inclusive).
  final int startCol;

  /// Zero-based row of the selection start (inclusive).
  final int startRow;

  /// Zero-based column of the selection end (inclusive).
  final int endCol;

  /// Zero-based row of the selection end (inclusive).
  final int endRow;

  /// Whether the selection covers a rectangular (block) region rather
  /// than a linear text range.
  final bool rectangle;

  const Selection({
    required this.startCol,
    required this.startRow,
    required this.endCol,
    required this.endRow,
    this.rectangle = false,
  });

  @override
  int get hashCode =>
      Object.hash(Selection, startCol, startRow, endCol, endRow, rectangle);

  @override
  bool operator ==(Object other) =>
      other is Selection &&
      other.startCol == startCol &&
      other.startRow == startRow &&
      other.endCol == endCol &&
      other.endRow == endRow &&
      other.rectangle == rectangle;

  @override
  String toString() =>
      'Selection($startCol,$startRow -> $endCol,$endRow'
      '${rectangle ? ', rectangle' : ''})';
}
