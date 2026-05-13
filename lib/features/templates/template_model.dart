import 'dart:convert';

import 'package:flutter/material.dart';

import '../editor/models/editor_layer.dart';

class TemplateModel {
  TemplateModel({
    required this.id,
    required this.ownerUid,
    required this.ownerName,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    required this.backgroundUrl,
    required this.backgroundFit,
    required this.backgroundMatrix,
    required this.backgroundRotationDeg,
    required this.backgroundGradient,
    required this.isPublic,
    required this.category,
    required this.layers,
  });

  final String id;
  final String ownerUid;
  final String ownerName;
  final String title;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? backgroundUrl;
  final String backgroundFit;
  final List<double> backgroundMatrix;
  final double backgroundRotationDeg;
  final BackgroundGradient backgroundGradient;
  final bool isPublic;
  final String? category;
  final List<EditorLayer> layers;

  Map<String, dynamic> toMap() => {
        'ownerUid': ownerUid,
        'ownerName': ownerName,
        'title': title,
        'createdAt': createdAt.toUtc().toIso8601String(),
        'updatedAt': updatedAt.toUtc().toIso8601String(),
        'backgroundUrl': backgroundUrl,
        'backgroundFit': backgroundFit,
        'backgroundMatrix': backgroundMatrix,
        'backgroundRotationDeg': backgroundRotationDeg,
        'backgroundGradient': backgroundGradient.toMap(),
        'isPublic': isPublic,
        'category': category,
        'layers': layers.map(layerToMap).toList(),
      };

  static TemplateModel fromMap(String id, Map<String, dynamic> map) {
    final layers = (map['layers'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(_layerFromMap)
        .toList();
    final fallbackIdentity = <double>[
      1, 0, 0, 0,
      0, 1, 0, 0,
      0, 0, 1, 0,
      0, 0, 0, 1,
    ];
    final matrix = (map['backgroundMatrix'] as List<dynamic>?)
        ?.whereType<num>()
        .map((e) => e.toDouble())
        .toList();
    final normalizedMatrix = (matrix != null && matrix.length == 16) ? matrix : fallbackIdentity;
    return TemplateModel(
      id: id,
      ownerUid: (map['ownerUid'] as String?) ?? '',
      ownerName: (map['ownerName'] as String?) ?? '',
      title: (map['title'] as String?) ?? '',
      createdAt: DateTime.tryParse((map['createdAt'] as String?) ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse((map['updatedAt'] as String?) ?? '') ?? DateTime.now(),
      backgroundUrl: map['backgroundUrl'] as String?,
      backgroundFit: (map['backgroundFit'] as String?) ?? 'contain',
      backgroundMatrix: normalizedMatrix,
      backgroundRotationDeg: ((map['backgroundRotationDeg'] as num?)?.toDouble()) ?? 0,
      backgroundGradient: BackgroundGradient.fromMap((map['backgroundGradient'] as Map?)?.cast<String, dynamic>()),
      isPublic: (map['isPublic'] as bool?) ?? false,
      category: map['category'] as String?,
      layers: layers,
    );
  }

  static Map<String, dynamic> layerToMap(EditorLayer l) {
    return {
      'id': l.id,
      'type': l.type.name,
      'x': l.position.dx,
      'y': l.position.dy,
      'w': l.size.width,
      'h': l.size.height,
      'rotation': l.rotation,
      'text': l.text,
      'isPlaceholder': l.isPlaceholder,
      'cornerRadius': l.cornerRadius,
      'imageUrl': l.imageUrl,
      'textStyle': _textStyleToMap(l.textStyle),
    };
  }

  static EditorLayer _layerFromMap(Map<String, dynamic> m) {
    final type = (m['type'] as String?) == 'image' ? EditorLayerType.image : EditorLayerType.text;
    return EditorLayer(
      id: (m['id'] as String?) ?? '',
      type: type,
      position: Offset(
        (m['x'] as num?)?.toDouble() ?? 0,
        (m['y'] as num?)?.toDouble() ?? 0,
      ),
      size: Size(
        (m['w'] as num?)?.toDouble() ?? 100,
        (m['h'] as num?)?.toDouble() ?? 60,
      ),
      rotation: (m['rotation'] as num?)?.toDouble() ?? 0,
      text: (m['text'] as String?) ?? '',
      isPlaceholder: (m['isPlaceholder'] as bool?) ?? false,
      cornerRadius: (m['cornerRadius'] as num?)?.toDouble() ?? 18,
      imageUrl: (m['imageUrl'] as String?),
      textStyle: _textStyleFromMap((m['textStyle'] as Map?)?.cast<String, dynamic>()),
    );
  }

  static Map<String, dynamic>? _textStyleToMap(TextStyle? s) {
    if (s == null) return null;
    return {
      'fontSize': s.fontSize,
      'fontWeight': s.fontWeight?.index,
      'color': s.color?.value,
    };
  }

  static TextStyle? _textStyleFromMap(Map<String, dynamic>? m) {
    if (m == null) return null;
    final int? fw = (m['fontWeight'] as num?)?.toInt();
    return TextStyle(
      fontSize: (m['fontSize'] as num?)?.toDouble(),
      fontWeight: fw == null ? null : FontWeight.values[fw.clamp(0, FontWeight.values.length - 1)],
      color: (m['color'] as num?) == null ? null : Color((m['color'] as num).toInt()),
    );
  }

  String toJson() => jsonEncode(toMap());
}

class BackgroundGradient {
  const BackgroundGradient({
    required this.enabled,
    required this.color1,
    required this.color2,
    required this.angleDeg,
  });

  final bool enabled;
  final Color color1;
  final Color color2;
  final double angleDeg;

  Map<String, dynamic> toMap() => {
        'enabled': enabled,
        'color1': color1.value,
        'color2': color2.value,
        'angleDeg': angleDeg,
      };

  static BackgroundGradient fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return const BackgroundGradient(
        enabled: false,
        color1: Color(0xFF6C63FF),
        color2: Color(0xFF0F172A),
        angleDeg: 45,
      );
    }
    return BackgroundGradient(
      enabled: (map['enabled'] as bool?) ?? false,
      color1: Color(((map['color1'] as num?)?.toInt()) ?? 0xFF6C63FF),
      color2: Color(((map['color2'] as num?)?.toInt()) ?? 0xFF0F172A),
      angleDeg: ((map['angleDeg'] as num?)?.toDouble()) ?? 45,
    );
  }
}
