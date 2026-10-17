import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flterm/src/foundation.dart';
import 'package:libghostty/libghostty.dart';

late String _fontsDir;

/// Raw bytes of JetBrains Mono Regular, available after [loadBundledFonts].
///
/// Used to pass to [measureCellMetrics]'s `fontData` parameter so that
/// exact font table metrics (underline/strikethrough position and thickness)
/// are read from the binary tables rather than estimated.
Uint8List? jetBrainsMonoBytes;

/// Applies the Flutter theme's terminal colors before rendering directly.
///
/// Renderer goldens bypass the mounted view, so they initialize the
/// terminal-facing colors explicitly at the direct-renderer test seam.
void applyTerminalTheme(Terminal terminal, TerminalTheme theme) {
  terminal
    ..foreground = _rgb(theme.foreground)
    ..background = _rgb(theme.background)
    ..cursorColor = theme.cursor.color?.fixedColor == null
        ? null
        : _rgb(theme.cursor.color!.fixedColor!)
    ..palette = [for (var i = 0; i < 256; i++) _rgb(theme.palette[i])];
}

/// Font family fallback list for golden tests. References only the fonts
/// loaded by [loadBundledFonts] so glyph rendering does not depend on any
/// platform-installed font (e.g. Apple Color Emoji), keeping output
/// deterministic across macOS minor versions and CPU architectures.
const bundledFontFamilyFallback = <String>[
  'Noto Color Emoji',
  'Noto Emoji',
  'Noto Sans JP',
];

/// Font family fallback list for deterministic Nerd Font golden tests.
const bundledNerdFontFamilyFallback = <String>[
  'Symbols Nerd Font',
  ...bundledFontFamilyFallback,
];

Future<void> loadBundledFonts() async {
  // Flutter's test isolate does not support Isolate.resolvePackageUri. Resolve
  // through the caller's package map so embedding apps can run these tests too.
  final localFonts = Directory('test/fixtures/fonts');
  if (localFonts.existsSync()) {
    _fontsDir = localFonts.absolute.path;
  } else {
    final configFile = File('.dart_tool/package_config.json').absolute;
    final config =
        jsonDecode(configFile.readAsStringSync()) as Map<String, dynamic>;
    final packages = config['packages'] as List<dynamic>;
    final package = packages.cast<Map<String, dynamic>>().firstWhere(
      (entry) => entry['name'] == 'flterm',
    );
    // rootUri lacks a trailing slash, so it must be appended before resolving
    // a relative path, or the last segment ('flterm') gets replaced instead of
    // extended.
    var rootUri = package['rootUri'] as String;
    if (!rootUri.endsWith('/')) rootUri = '$rootUri/';
    final root = configFile.uri.resolve(rootUri);
    _fontsDir = Directory.fromUri(root.resolve('test/fixtures/fonts/')).path;
  }
  // DirectWrite leaves the COLRv1 and SVG fixture blank, so Windows uses the
  // equivalent CBDT subset for deterministic pixel bounds.
  final colorEmojiFilename = Platform.isWindows
      ? 'NotoColorEmoji-WindowsSubset.ttf'
      : 'NotoColorEmoji-Regular.ttf';
  jetBrainsMonoBytes = await _load(
    'JetBrainsMono-Regular.ttf',
    'JetBrains Mono',
  );
  await _load('JetBrainsMono-Bold.ttf', 'JetBrains Mono');
  await _load(colorEmojiFilename, 'Noto Color Emoji');
  await _load('NotoEmoji-Regular.ttf', 'Noto Emoji');
  await _load('NotoSansJP-Regular.ttf', 'Noto Sans JP');
  await _load('SymbolsNerdFont-Regular-subset.ttf', 'Symbols Nerd Font');
}

Future<Uint8List> _load(String filename, String family) async {
  final path = '$_fontsDir${Platform.pathSeparator}$filename';
  final bytes = File(path).readAsBytesSync();
  await ui.loadFontFromList(Uint8List.fromList(bytes), fontFamily: family);
  return Uint8List.fromList(bytes);
}

RgbColor _rgb(ui.Color color) => RgbColor(
  (color.r * 255).round().clamp(0, 255),
  (color.g * 255).round().clamp(0, 255),
  (color.b * 255).round().clamp(0, 255),
);
