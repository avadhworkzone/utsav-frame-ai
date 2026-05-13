import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../core/widgets/app_button.dart';
import '../../core/widgets/toast.dart';

class ShareLinkDialog extends StatelessWidget {
  const ShareLinkDialog({super.key, required this.link});

  final String link;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 6),
        Text(
          'Share this link with your attendees. They will upload their photo + name and download the generated poster.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.75)),
        ),
        const SizedBox(height: 12),
        SelectableText(
          link,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: AppButton.ghost(
                label: 'Copy link',
                icon: Icons.copy,
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: link));
                  Toast.success('Copied', 'Link copied to clipboard.');
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: AppButton.primary(
                label: 'Done',
                icon: Icons.check,
                onPressed: Get.back,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

