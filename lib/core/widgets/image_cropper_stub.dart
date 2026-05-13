import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'app_button.dart';

class ImageCropperStub extends StatelessWidget {
  const ImageCropperStub({super.key, required this.bytes});

  final Uint8List bytes;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Crop (UI Stub)',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: AspectRatio(
            aspectRatio: 1,
            child: Stack(
              children: [
                Positioned.fill(child: Image.memory(bytes, fit: BoxFit.cover)),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white.withOpacity(0.7), width: 2),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Replace this stub with a real cropper later (e.g. extended_image or a dedicated cropper plugin).',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.75)),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: AppButton.ghost(label: 'Cancel', icon: Icons.close, onPressed: () => Get.back(result: null))),
            const SizedBox(width: 10),
            Expanded(child: AppButton.primary(label: 'Use image', icon: Icons.check, onPressed: () => Get.back(result: bytes))),
          ],
        ),
      ],
    );
  }
}

