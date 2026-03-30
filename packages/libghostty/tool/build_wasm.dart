import 'dart:io';

import 'package:libghostty/src/hook/ghostty_source.dart';

void main() async {
  final packageRoot = _findPackageRoot();
  final sourceDir = await resolveSource(
    packageRoot: packageRoot.uri,
    cacheBase: packageRoot.uri.resolve('.dart_tool/'),
  );

  stdout.writeln('Compiling libghostty for wasm32-freestanding...');
  _compileWithZig(sourceDir);

  final wasmSource = File('${sourceDir.path}/zig-out/bin/ghostty-vt.wasm');
  if (!wasmSource.existsSync()) {
    throw Exception('WASM binary not found at ${wasmSource.path} after build.');
  }

  final wasmTarget = File('${packageRoot.path}/lib/src/wasm/libghostty.wasm');
  wasmTarget.parent.createSync(recursive: true);
  wasmSource.copySync(wasmTarget.path);
  _patchTableMaximum(wasmTarget);

  final size = wasmTarget.lengthSync();
  stdout.writeln(
    'Copied libghostty.wasm to lib/src/wasm/ '
    '(${(size / 1024).toStringAsFixed(1)} KB)',
  );
}

/// Patches the WASM binary's indirect function table to allow runtime growth.
///
/// Zig's wasm-ld sets initial == maximum on the function table, which
/// prevents Table.grow() at runtime. Zig 0.15 does not expose a
/// --growable-table linker flag (tracked in ziglang/zig#23598), so we
/// patch the table section directly after compilation.
///
/// Locates the table section (id 4) in the binary, skips past the
/// initial size (LEB128), and raises the maximum to 127 (0x7F).
void _patchTableMaximum(File wasmFile) {
  final data = wasmFile.readAsBytesSync();
  var i = 8; // Skip WASM magic number and version.
  while (i < data.length) {
    final sectionId = data[i++];
    var size = 0;
    var shift = 0;
    while (true) {
      final byte = data[i++];
      size |= (byte & 0x7f) << shift;
      if (byte & 0x80 == 0) break;
      shift += 7;
    }
    if (sectionId != 4) {
      i += size;
      continue;
    }
    // Table section layout: count(1) + elemtype(1) + flags(1) +
    // initial(LEB128) + maximum(LEB128).
    var j = i + 3;
    while (data[j] & 0x80 != 0) {
      j++;
    }
    j++;
    data[j] = 0x7f;
    wasmFile.writeAsBytesSync(data);
    stdout.writeln('Patched function table maximum for callback support.');
    return;
  }
  throw Exception('Table section (id 4) not found in WASM binary.');
}

void _compileWithZig(Directory sourceDir) {
  final result = Process.runSync('zig', [
    'build',
    '-Demit-lib-vt=true',
    '-Dtarget=wasm32-freestanding',
    '-Doptimize=ReleaseSmall',
  ], workingDirectory: sourceDir.path);

  if (result.exitCode != 0) {
    throw Exception(
      'Zig compilation failed (exit code ${result.exitCode}):\n'
      'stdout: ${result.stdout}\n'
      'stderr: ${result.stderr}',
    );
  }
}

Directory _findPackageRoot() {
  final scriptUri = Platform.script;
  if (scriptUri.scheme == 'file') {
    return Directory(scriptUri.resolve('..').toFilePath());
  }
  return Directory.current;
}
