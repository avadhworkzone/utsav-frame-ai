import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';

enum EditorLayerType { text, image }

class EditorLayer {
  EditorLayer({
    required this.id,
    required this.type,
    required this.position,
    required this.size,
    this.rotation = 0,
    this.text = 'Name Here',
    this.textStyle,
    this.isPlaceholder = true,
    this.imageUrl,
    this.imageBytes,
    this.cornerRadius = 18,
  });

  final String id;
  final EditorLayerType type;

  Offset position;
  Size size;
  double rotation;

  // text
  String text;
  TextStyle? textStyle;
  bool isPlaceholder;

  // image
  String? imageUrl;
  Uint8List? imageBytes;
  double cornerRadius;

  Rect rect() => position & size;

  EditorLayer copy() => EditorLayer(
        id: id,
        type: type,
        position: position,
        size: size,
        rotation: rotation,
        text: text,
        textStyle: textStyle,
        isPlaceholder: isPlaceholder,
        imageUrl: imageUrl,
        imageBytes: imageBytes,
        cornerRadius: cornerRadius,
      );

  void rotateBy(double deltaDegrees) {
    rotation = (rotation + deltaDegrees) % 360;
  }

  double get rotationRadians => rotation * (math.pi / 180.0);
}
