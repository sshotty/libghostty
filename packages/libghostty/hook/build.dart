import 'dart:io';

import 'package:code_assets/code_assets.dart';
import 'package:hooks/hooks.dart';
import 'package:libghostty/src/hook/ghostty_source.dart' show pinnedCommit;
import 'package:libghostty/src/hook/library_provider.dart';

void main(List<String> args) async {
  await build(args, _build);
}

Future<void> _build(BuildInput input, BuildOutputBuilder output) async {
  if (!input.config.buildCodeAssets) return;

  output.dependencies.add(input.packageRoot.resolve('ghostty.version'));

  final targetOS = input.config.code.targetOS;
  final libFileName = targetOS.dylibFileName('ghostty');
  // A hook reruns when ghostty.version changes, but its output directory can
  // stay the same. Never reuse a binary built for the preceding Dart ABI.
  final installDir = input.outputDirectory.resolve(
    'ghostty-${pinnedCommit(input.packageRoot)}/',
  );
  final libFile = File.fromUri(installDir.resolve('lib/$libFileName'));

  if (!libFile.existsSync()) {
    final provider = LibraryProvider.resolve(input);
    await provider.provide(libFile);
  }

  if (!libFile.existsSync()) {
    throw Exception(
      'Native library not found at ${libFile.path} after build.\n'
      'Options:\n'
      '  - Install Zig (https://ziglang.org) to compile from source\n'
      '  - Ensure a GitHub Release exists for the current version',
    );
  }

  output.assets.code.add(
    CodeAsset(
      package: input.packageName,
      name: 'libghostty.dart',
      linkMode: DynamicLoadingBundled(),
      file: libFile.uri,
    ),
  );
}
