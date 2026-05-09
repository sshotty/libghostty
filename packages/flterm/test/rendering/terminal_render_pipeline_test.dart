@Tags(['ffi'])
library;

import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flterm/src/foundation/cell_metrics.dart';
import 'package:flterm/src/foundation/terminal_selection.dart';
import 'package:flterm/src/foundation/terminal_theme.dart';
import 'package:flterm/src/rendering/atlas/atlas.dart';
import 'package:flterm/src/rendering/paint_state.dart';
import 'package:flterm/src/rendering/terminal_render_pipeline.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:libghostty/libghostty.dart';

void main() {
  group('TerminalRenderPipeline', () {
    late Terminal terminal;
    late Atlas atlas;
    late TerminalPaintState state;
    late TerminalRenderPipeline pipeline;

    setUp(() {
      terminal = Terminal(cols: 8, rows: 2);
      atlas = Atlas(_config());
      state = TerminalPaintState(TerminalTheme.dark(), _metrics)
        ..cols = 8
        ..rows = 2;
      pipeline = TerminalRenderPipeline(
        atlas: atlas,
        state: state,
        onImageReady: () {},
      )..configureGrid(2, 8);
    });

    tearDown(() {
      pipeline.dispose();
      atlas.dispose();
      terminal.dispose();
    });

    test('sync resolves cursor glyph and paints current frame', () {
      terminal.writeUtf8('A\x1b[1;1H');

      pipeline.sync(terminal, terminalDirty: true);

      expect(state.cursor.visible, isTrue);
      expect(state.cursorAtlasEntry, isNotNull);
      _paint(pipeline);
    });

    test('bindAtlas keeps the frame pipeline configured', () {
      terminal.writeUtf8('A\x1b[1;1H');
      pipeline.sync(terminal, terminalDirty: true);

      final nextAtlas = Atlas(_config(fontSize: 16));
      addTearDown(nextAtlas.dispose);

      pipeline.bindAtlas(nextAtlas);
      pipeline.sync(terminal, terminalDirty: false);

      expect(state.cursorAtlasEntry, isNotNull);
      _paint(pipeline);
    });

    test('selection dirtying can repaint without terminal changes', () {
      terminal.writeUtf8('hello');
      pipeline.sync(terminal, terminalDirty: true);

      state.selection = const TerminalSelection(
        startRow: 0,
        startCol: 1,
        endRow: 0,
        endCol: 3,
      );
      pipeline.markSelectionRowsDirty(state.selection, viewportOffset: 0);

      pipeline.sync(terminal, terminalDirty: false);

      _paint(pipeline);
    });
  });
}

const _metrics = CellMetrics(cellWidth: 8, cellHeight: 16, baseline: 12);

AtlasConfig _config({double fontSize = 14}) {
  return AtlasConfig(
    fontSize: fontSize,
    fontWeight: FontWeight.normal,
    fontFamily: 'monospace',
    fontFamilyFallback: const [],
    metrics: _metrics,
    devicePixelRatio: 1.0,
  );
}

void _paint(TerminalRenderPipeline pipeline) {
  final recorder = PictureRecorder();
  final canvas = Canvas(recorder);
  pipeline.paint(canvas);
  recorder.endRecording().dispose();
}

extension on Terminal {
  void writeUtf8(String text) => write(Uint8List.fromList(utf8.encode(text)));
}
