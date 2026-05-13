import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'glass_card.dart';

class AppModal {
  static Future<T?> show<T>({
    required Widget child,
    String? title,
    bool barrierDismissible = true,
    double maxWidth = 560,
  }) {
    return Get.dialog<T>(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(18),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: GlassCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    if (title != null)
                      Expanded(
                        child: Text(
                          title,
                          style: Get.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    IconButton(onPressed: Get.back, icon: const Icon(Icons.close)),
                  ],
                ),
                child,
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: barrierDismissible,
    );
  }
}

