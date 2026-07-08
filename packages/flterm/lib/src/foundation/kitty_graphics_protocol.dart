import 'dart:convert';
import 'dart:typed_data';

/// Image format identifiers for the Kitty graphics protocol.
///
/// Maps to the `f` parameter in transmit escapes.
enum KittyGraphicsFormat {
  /// 24-bit RGB, 3 bytes per pixel. Data: row-major RGB.
  rgb(24),

  /// 32-bit RGBA, 4 bytes per pixel. Data: row-major RGBA.
  rgba(32),

  /// PNG-compressed image. Data: valid PNG file bytes.
  png(100),

  /// WebP-compressed image. Data: valid WebP file bytes.
  webp(101),

  /// GIF-compressed image. Data: valid GIF file bytes.
  gif(102);

  final int code;
  const KittyGraphicsFormat(this.code);
}

/// Encodes Kitty graphics protocol escape sequences.
///
/// Generates APC escape sequences (`\e_G...\e\`) for the Kitty graphics
/// protocol. Supports transmit, display, delete, and query actions.
///
/// Large payloads are automatically split into chunked transmissions
/// when the payload size exceeds [defaultChunkSize].
class KittyGraphicsProtocol {
  /// Default chunk size for split transmissions (64 KiB).
  ///
  /// Payloads larger than this are split into `\e_G<params>;<chunk>\e\`
  /// sequences with `m=1` on intermediate chunks.
  static const int defaultChunkSize = 64 * 1024;

  KittyGraphicsProtocol._();

  /// Transmits (uploads) an image to the terminal without displaying it.
  ///
  /// The image is stored under [imageId] and can later be placed with
  /// [display]. The [format] specifies the encoding of [bytes]; for
  /// [KittyGraphicsFormat.png], the bytes must be a valid PNG file.
  ///
  /// Returns the encoded escape sequence bytes.
  static Uint8List transmit({
    required int imageId,
    required Uint8List bytes,
    KittyGraphicsFormat format = KittyGraphicsFormat.png,
    int? width,
    int? height,
    int chunkSize = defaultChunkSize,
  }) {
    return _encode(
      params: _transmitParams(
        imageId: imageId,
        format: format,
        width: width,
        height: height,
      )..add('a=t'),
      bytes: bytes,
      chunkSize: chunkSize,
    );
  }

  /// Transmits an image and places it in a single combined action.
  ///
  /// Equivalent to calling [transmit] followed by [display], but uses the
  /// combined `a=t,p` action to do both in one protocol exchange.
  static Uint8List transmitAndDisplay({
    required int placementId,
    required Uint8List bytes,
    KittyGraphicsFormat format = KittyGraphicsFormat.png,
    int? width,
    int? height,
    int chunkSize = defaultChunkSize,
  }) {
    return _encode(
      params: _transmitParams(
        imageId: placementId,
        format: format,
        width: width,
        height: height,
      )..add('a=t,p'),
      bytes: bytes,
      chunkSize: chunkSize,
    );
  }

  /// Places (displays) a previously transmitted image on the grid.
  ///
  /// The [imageId] must match an image previously transmitted with
  /// [transmit]. Set [col] and [row] for grid position, and [xOffset]/
  /// [yOffset] for pixel-level positioning. [z] controls paint order:
  /// negative values paint below text, non-negative above.
  ///
  /// Returns the encoded escape sequence bytes (no payload data).
  static Uint8List display({
    required int imageId,
    int? col,
    int? row,
    int xOffset = 0,
    int yOffset = 0,
    int? width,
    int? height,
    int? z,
    int? placementId,
  }) {
    final buf = StringBuffer()
      ..write('\x1b_Ga=p')
      ..write(',i=$imageId');
    if (placementId != null) buf.write(',id=$placementId');
    if (col != null) buf.write(',c=$col');
    if (row != null) buf.write(',r=$row');
    if (xOffset != 0) buf.write(',X=$xOffset');
    if (yOffset != 0) buf.write(',Y=$yOffset');
    if (width != null) buf.write(',w=$width');
    if (height != null) buf.write(',h=$height');
    if (z != null) buf.write(',z=$z');
    buf.write('\x1b\\');
    return Uint8List.fromList(utf8.encode(buf.toString()));
  }

  /// Deletes images or placements from the terminal.
  ///
  /// If [imageId] is specified, deletes that specific image (and all its
  /// placements). If [deleteAll] is true, deletes everything. If neither,
  /// deletes all placements but keeps the images.
  static Uint8List delete({int? imageId, bool deleteAll = false}) {
    final buf = StringBuffer()..write('\x1b_Ga=d');
    if (imageId != null) {
      buf.write(',i=$imageId');
    }
    if (deleteAll) {
      buf.write(',I=1');
    }
    buf.write('\x1b\\');
    return Uint8List.fromList(utf8.encode(buf.toString()));
  }

  /// Queries terminal for pixel dimensions.
  ///
  /// The terminal should respond with the pixel dimensions via the
  /// `\e[4;height;width;t` or kitty protocol response.
  static Uint8List queryPixelSize({int queryId = 1}) {
    return _query(queryId: queryId, stream: 1, verbose: 1);
  }

  /// Queries terminal for Kitty graphics capabilities.
  ///
  /// The terminal responds with its supported protocol version and features.
  static Uint8List queryCapabilities({int queryId = 1, bool verbose = false}) {
    return _query(
      queryId: queryId,
      verbose: verbose ? 1 : 0,
    );
  }

  /// Encodes the old-style combined transmit+display escape (legacy API).
  @Deprecated('Use transmitAndDisplay() instead')
  static Uint8List imageEscape({
    required int placementId,
    required Uint8List imageBytes,
    String format = 'png',
    int? width,
    int? height,
  }) {
    final fmt = switch (format.toLowerCase()) {
      'png' => KittyGraphicsFormat.png,
      _ => KittyGraphicsFormat.png,
    };
    return transmitAndDisplay(
      placementId: placementId,
      bytes: imageBytes,
      format: fmt,
      width: width,
      height: height,
    );
  }

  // ---------------------------------------------------------------------------
  // Internal helpers
  // ---------------------------------------------------------------------------

  static List<String> _transmitParams({
    required int imageId,
    required KittyGraphicsFormat format,
    int? width,
    int? height,
  }) {
    final w = width;
    final h = height;
    return [
      'f=${format.code}',
      's=${w ?? "_"}',
      'v=${h ?? "_"}',
      't=d',
      'i=$imageId',
    ];
  }

  static Uint8List _query({
    required int queryId,
    int stream = 0,
    int verbose = 0,
  }) {
    final buf = StringBuffer()
      ..write('\x1b_Gi=$queryId,a=q')
      ..write(',s=$stream')
      ..write(',v=$verbose')
      ..write('\x1b\\');
    return Uint8List.fromList(utf8.encode(buf.toString()));
  }

  /// Encodes the base64 payload into one or more APC escape sequences.
  ///
  /// Large payloads are split into chunks with `m=1` (more flag) set on
  /// intermediate chunks. The final chunk omits `m`.
  static Uint8List _encode({
    required List<String> params,
    required Uint8List bytes,
    int chunkSize = defaultChunkSize,
  }) {
    final base64data = base64.encode(bytes);
    final paramStr = params.join(',');

    if (base64data.length <= chunkSize) {
      // Single chunk
      return Uint8List.fromList(
        utf8.encode('\x1b_G$paramStr;$base64data\x1b\\'),
      );
    }

    // Multi-chunk transmission
    final result = BytesBuilder();
    var offset = 0;
    while (offset < base64data.length) {
      final end = (offset + chunkSize).clamp(0, base64data.length);
      final chunk = base64data.substring(offset, end);
      final isLast = end >= base64data.length;

      if (offset == 0) {
        // First chunk includes the parameters
        result.add(utf8.encode('\x1b_G$paramStr,m=1;$chunk\x1b\\'));
      } else if (!isLast) {
        // Intermediate chunk
        result.add(utf8.encode('\x1b_Gm=1;$chunk\x1b\\'));
      } else {
        // Final chunk
        result.add(utf8.encode('\x1b_G;$chunk\x1b\\'));
      }
      offset = end;
    }
    return result.toBytes();
  }
}
