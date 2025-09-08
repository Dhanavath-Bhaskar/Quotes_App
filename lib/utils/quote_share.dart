import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:qns/utils/capture_quote_image.dart';

Future<Uint8List?> captureQuoteAsImage(QuoteShareView widget) async {
  final repaintKey = GlobalKey();
  final captureWidget = Material(
    color: Colors.transparent,
    child: Center(
      child: RepaintBoundary(
        key: repaintKey,
        child: SizedBox(
          width: 1080,
          height: 1920,
          child: widget,
        ),
      ),
    ),
  );

  final buildContext = WidgetsBinding.instance.renderViewElement;
  OverlayEntry? entry;
  final completer = Completer<Uint8List?>();

  entry = OverlayEntry(
    builder: (context) => captureWidget,
  );
  Overlay.of(buildContext!)?.insert(entry);

  await Future.delayed(const Duration(milliseconds: 300)); // Let it build
  final boundary = repaintKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
  if (boundary != null) {
    final image = await boundary.toImage(pixelRatio: 3.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    completer.complete(byteData?.buffer.asUint8List());
  } else {
    completer.complete(null);
  }

  entry.remove();
  return completer.future;
}
