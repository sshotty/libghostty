import 'dart:ui';

import 'package:flutter/painting.dart';

import '../paint_state.dart';
import 'terminal_painter.dart';

class SearchHighlightPainter implements TerminalPainter {
  static const _highlightColor = Color(0x4DFFFF00);

  final Paint _paint;
  final TerminalPaintState _state;

  SearchHighlightPainter(this._state)
    : _paint = Paint()..color = _highlightColor;

  @override
  void paint(Canvas canvas) {
    final hits = _state.searchHits;
    if (hits.isEmpty) return;

    final cellWidth = _state.metrics.cellWidth;
    final cellHeight = _state.metrics.cellHeight;
    final viewportOffset = _state.viewportOffset;

    for (final hit in hits) {
      final visibleRow = hit.row - viewportOffset;
      if (visibleRow < 0 || visibleRow >= _state.rows) continue;

      canvas.drawRect(
        Rect.fromLTWH(
          hit.col * cellWidth,
          visibleRow * cellHeight,
          hit.length * cellWidth,
          cellHeight,
        ),
        _paint,
      );
    }
  }
}
