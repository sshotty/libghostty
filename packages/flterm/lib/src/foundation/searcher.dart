import 'package:libghostty/libghostty.dart';
import 'package:meta/meta.dart';

@immutable
final class SearchHit {
  final int row;
  final int col;
  final int length;

  const SearchHit({
    required this.row,
    required this.col,
    required this.length,
  });

  @override
  bool operator ==(Object other) =>
      other is SearchHit &&
      other.row == row &&
      other.col == col &&
      other.length == length;

  @override
  int get hashCode => Object.hash(row, col, length);

  @override
  String toString() => 'SearchHit(row: $row, col: $col, length: $length)';
}

final class Searcher {
  final Terminal _terminal;

  Searcher(Terminal terminal) : _terminal = terminal;

  List<SearchHit> search(
    String pattern, {
    bool caseSensitive = true,
    bool regex = false,
  }) {
    if (pattern.isEmpty) return [];

    final renderState = RenderState();
    renderState.update(_terminal);
    final cols = renderState.cols;
    final totalRows = _terminal.totalRows;
    renderState.dispose();

    if (cols <= 0 || totalRows <= 0) return [];

    final startRef = GridRef.at(
      _terminal,
      const Position(row: 0, col: 0),
      pointTag: PointTag.screen,
    );
    final endRef = GridRef.at(
      _terminal,
      Position(row: totalRows - 1, col: cols - 1),
      pointTag: PointTag.screen,
    );
    final selection = Selection.fromRefs(start: startRef, end: endRef);

    final formatter = Formatter(
      terminal: _terminal,
      format: FormatterFormat.plain,
      selection: selection,
    );

    final String text;
    try {
      text = formatter.format();
    } finally {
      formatter.dispose();
    }

    return _searchText(
      text,
      pattern,
      caseSensitive: caseSensitive,
      regex: regex,
    );
  }

  List<SearchHit> _searchText(
    String text,
    String pattern, {
    required bool caseSensitive,
    required bool regex,
  }) {
    final results = <SearchHit>[];
    final lines = text.split('\n');

    if (text.endsWith('\n')) {
      lines.removeLast();
    }

    if (regex) {
      final regExp = RegExp(pattern, caseSensitive: caseSensitive);
      for (var row = 0; row < lines.length; row++) {
        for (final match in regExp.allMatches(lines[row])) {
          results.add(SearchHit(
            row: row,
            col: match.start,
            length: match.end - match.start,
          ));
        }
      }
    } else if (caseSensitive) {
      for (var row = 0; row < lines.length; row++) {
        final line = lines[row];
        var start = 0;
        while (true) {
          final idx = line.indexOf(pattern, start);
          if (idx == -1) break;
          results.add(SearchHit(row: row, col: idx, length: pattern.length));
          start = idx + 1;
        }
      }
    } else {
      final lowerPattern = pattern.toLowerCase();
      for (var row = 0; row < lines.length; row++) {
        final lowerLine = lines[row].toLowerCase();
        var start = 0;
        while (true) {
          final idx = lowerLine.indexOf(lowerPattern, start);
          if (idx == -1) break;
          results.add(SearchHit(row: row, col: idx, length: pattern.length));
          start = idx + 1;
        }
      }
    }

    return results;
  }
}
