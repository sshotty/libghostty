@Tags(['ffi'])
library;

import 'dart:io';

import 'package:code_assets/code_assets.dart';
import 'package:hooks/hooks.dart';
import 'package:libghostty/src/hook/library_provider.dart';
import 'package:test/test.dart';

void main() {
  group('LibraryProvider', () {
    group('zigAvailable', () {
      test('returns a boolean', () {
        expect(LibraryProvider.zigAvailable(), isA<bool>());
      });
    });

    group('subtypes', () {
      test('are exhaustive in pattern matching', () {
        expect(
          _describeProvider(DownloadPrebuilt(createTestBuildInput())),
          'download',
        );
      });

      test('reads legacy package-scoped user-defines', () {
        final input = createTestBuildInput(
          packageName: 'libghostty',
          userDefines: {
            'libghostty': {'source': 'compile'},
          },
        );

        expect(_describeProvider(LibraryProvider.resolve(input)), 'compile');
      });

      test('implement LibraryProvider', () {
        expect(
          DownloadPrebuilt(createTestBuildInput()),
          isA<LibraryProvider>(),
        );
      });
    });

    group('libraryExtension', () {
      test('maps OS to native library file extension', () {
        expect(libraryExtension(OS.macOS), 'dylib');
        expect(libraryExtension(OS.iOS), 'dylib');
        expect(libraryExtension(OS.windows), 'dll');
        expect(libraryExtension(OS.linux), 'so');
        expect(libraryExtension(OS.android), 'so');
      });
    });
  });
}

BuildInput createTestBuildInput({
  String packageName = 'test_package',
  OS os = OS.macOS,
  Architecture arch = Architecture.arm64,
  Map<String, Object?> userDefines = const {},
}) {
  final tmp = Directory.systemTemp.createTempSync('build_input_test_');
  addTearDown(() => tmp.deleteSync(recursive: true));

  return BuildInput(<String, dynamic>{
    'package_name': packageName,
    'package_root': tmp.path,
    'out_dir': '${tmp.path}/out',
    'out_dir_shared': '${tmp.path}/shared',
    'user_defines': userDefines,
    'config': <String, dynamic>{
      'build_code_assets': true,
      'build_asset_types': <String>['code_assets/code'],
      'extensions': <String, dynamic>{
        'code_assets': <String, dynamic>{
          'target_os': os.name,
          'target_architecture': arch.name,
          'ios': <String, dynamic>{'target_sdk': 'iphoneos'},
        },
      },
    },
  });
}

String _describeProvider(LibraryProvider provider) {
  return switch (provider) {
    CompileFromSource() => 'compile',
    DownloadPrebuilt() => 'download',
  };
}
